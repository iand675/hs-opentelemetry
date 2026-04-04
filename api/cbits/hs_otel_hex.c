#include "hs_otel_hex.h"

#include <stdint.h>
#include <string.h>

/*
 * Hex encode/decode specialized for OpenTelemetry trace & span IDs.
 *
 * TraceId: 16 bytes <-> 32 hex chars
 * SpanId:   8 bytes <-> 16 hex chars
 *
 * Encoding hot path uses SIMD where available:
 *   x86_64 — SSSE3 (pshufb), available on all x86_64 since ~2006
 *   aarch64 — NEON (vtbl), always available
 *   fallback — scalar with lookup table
 *
 * Decoding uses a branchless scalar loop with a 256-byte lookup table.
 * The loop accumulates an error flag via bitwise OR, producing a single
 * branch at the end.
 */

/* ── Encode lookup table ─────────────────────────────────────────────── */

static const char enc_lut[] = "0123456789abcdef";

/* ── Decode lookup table ─────────────────────────────────────────────── */

static const int8_t dec_lut[256] = {
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x00-0x0f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x10-0x1f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x20-0x2f */
     0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1, /* 0x30-0x3f */
    -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x40-0x4f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x50-0x5f */
    -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x60-0x6f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x70-0x7f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x80-0x8f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0x90-0x9f */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0xa0-0xaf */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0xb0-0xbf */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0xc0-0xcf */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0xd0-0xdf */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, /* 0xe0-0xef */
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1  /* 0xf0-0xff */
};

/* ── Scalar encode ───────────────────────────────────────────────────── */

static inline void encode_hex_scalar(const uint8_t *src, uint8_t *dst, size_t n) {
    for (size_t i = 0; i < n; i++) {
        dst[2 * i    ] = enc_lut[src[i] >> 4];
        dst[2 * i + 1] = enc_lut[src[i] & 0x0f];
    }
}

/* ── Branchless scalar decode ────────────────────────────────────────── */

static inline int decode_hex_scalar(const uint8_t *src, uint8_t *dst,
                                    size_t dst_len) {
    int8_t err = 0;
    for (size_t i = 0; i < dst_len; i++) {
        int8_t hi = dec_lut[src[2 * i    ]];
        int8_t lo = dec_lut[src[2 * i + 1]];
        err |= (hi | lo);
        dst[i] = (uint8_t)((hi << 4) | lo);
    }
    return err < 0 ? -1 : 0;
}

/* ── Platform-specific SIMD encode ───────────────────────────────────── */

#if defined(HEX_ARCH_X86_64)

/*
 * SSSE3 encode: pshufb as a 4-bit → ASCII lookup.
 *
 * For 16-byte TraceId, one 128-bit load covers the entire input.
 * Split each byte into high/low nibbles, look up hex chars, interleave,
 * store 32 bytes.
 */
__attribute__((target("ssse3")))
static void encode_hex_ssse3_16(const uint8_t *src, uint8_t *dst) {
    __m128i input   = _mm_loadu_si128((const __m128i *)src);
    __m128i hex_lut = _mm_setr_epi8('0','1','2','3','4','5','6','7',
                                     '8','9','a','b','c','d','e','f');
    __m128i mask_lo = _mm_set1_epi8(0x0f);

    __m128i lo     = _mm_and_si128(input, mask_lo);
    __m128i hi     = _mm_and_si128(_mm_srli_epi16(input, 4), mask_lo);

    __m128i hex_lo = _mm_shuffle_epi8(hex_lut, lo);
    __m128i hex_hi = _mm_shuffle_epi8(hex_lut, hi);

    _mm_storeu_si128((__m128i *)(dst     ), _mm_unpacklo_epi8(hex_hi, hex_lo));
    _mm_storeu_si128((__m128i *)(dst + 16), _mm_unpackhi_epi8(hex_hi, hex_lo));
}

/*
 * SpanId: load 8 bytes into the low half of an XMM register.
 * After nibble split + pshufb, unpacklo gives 16 output bytes.
 */
__attribute__((target("ssse3")))
static void encode_hex_ssse3_8(const uint8_t *src, uint8_t *dst) {
    __m128i input   = _mm_loadl_epi64((const __m128i *)src);
    __m128i hex_lut = _mm_setr_epi8('0','1','2','3','4','5','6','7',
                                     '8','9','a','b','c','d','e','f');
    __m128i mask_lo = _mm_set1_epi8(0x0f);

    __m128i lo     = _mm_and_si128(input, mask_lo);
    __m128i hi     = _mm_and_si128(_mm_srli_epi16(input, 4), mask_lo);

    __m128i hex_lo = _mm_shuffle_epi8(hex_lut, lo);
    __m128i hex_hi = _mm_shuffle_epi8(hex_lut, hi);

    _mm_storeu_si128((__m128i *)dst, _mm_unpacklo_epi8(hex_hi, hex_lo));
}

#elif defined(HEX_ARCH_AARCH64)

/*
 * NEON encode: vqtbl1q_u8 as a 4-bit → ASCII lookup (same idea as pshufb).
 */
static void encode_hex_neon_16(const uint8_t *src, uint8_t *dst) {
    uint8x16_t input   = vld1q_u8(src);
    static const uint8_t lut_data[16] = {
        '0','1','2','3','4','5','6','7',
        '8','9','a','b','c','d','e','f'
    };
    uint8x16_t hex_lut = vld1q_u8(lut_data);

    uint8x16_t lo     = vandq_u8(input, vdupq_n_u8(0x0f));
    uint8x16_t hi     = vshrq_n_u8(input, 4);

    uint8x16_t hex_lo = vqtbl1q_u8(hex_lut, lo);
    uint8x16_t hex_hi = vqtbl1q_u8(hex_lut, hi);

    uint8x16x2_t zipped = vzipq_u8(hex_hi, hex_lo);
    vst1q_u8(dst,      zipped.val[0]);
    vst1q_u8(dst + 16, zipped.val[1]);
}

static void encode_hex_neon_8(const uint8_t *src, uint8_t *dst) {
    uint8x8_t input = vld1_u8(src);
    static const uint8_t lut_data[16] = {
        '0','1','2','3','4','5','6','7',
        '8','9','a','b','c','d','e','f'
    };
    uint8x16_t hex_lut = vld1q_u8(lut_data);

    uint8x8_t lo     = vand_u8(input, vdup_n_u8(0x0f));
    uint8x8_t hi     = vshr_n_u8(input, 4);

    uint8x8_t hex_lo = vqtbl1_u8(hex_lut, lo);
    uint8x8_t hex_hi = vqtbl1_u8(hex_lut, hi);

    uint8x8x2_t zipped = vzip_u8(hex_hi, hex_lo);
    vst1_u8(dst,     zipped.val[0]);
    vst1_u8(dst + 8, zipped.val[1]);
}

#endif

/* ── Public API ──────────────────────────────────────────────────────── */

void hs_otel_encode_trace_id(const uint8_t *src, uint8_t *dst) {
#if defined(HEX_ARCH_X86_64)
    encode_hex_ssse3_16(src, dst);
#elif defined(HEX_ARCH_AARCH64)
    encode_hex_neon_16(src, dst);
#else
    encode_hex_scalar(src, dst, 16);
#endif
}

void hs_otel_encode_span_id(const uint8_t *src, uint8_t *dst) {
#if defined(HEX_ARCH_X86_64)
    encode_hex_ssse3_8(src, dst);
#elif defined(HEX_ARCH_AARCH64)
    encode_hex_neon_8(src, dst);
#else
    encode_hex_scalar(src, dst, 8);
#endif
}

void hs_otel_encode_hex(const uint8_t *src, uint8_t *dst, size_t src_len) {
    encode_hex_scalar(src, dst, src_len);
}

int hs_otel_decode_trace_id(const uint8_t *src, uint8_t *dst) {
    return decode_hex_scalar(src, dst, 16);
}

int hs_otel_decode_span_id(const uint8_t *src, uint8_t *dst) {
    return decode_hex_scalar(src, dst, 8);
}

int hs_otel_decode_hex(const uint8_t *src, uint8_t *dst, size_t dst_len) {
    return decode_hex_scalar(src, dst, dst_len);
}
