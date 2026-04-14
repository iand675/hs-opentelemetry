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

/* ── Platform-specific SIMD decode ───────────────────────────────────── */

/*
 * Lemire/Muła-style SIMD hex decode.
 *
 * Decodes 16 hex ASCII chars → 8 raw bytes in one SIMD pass:
 *   1. Force lowercase via OR 0x20 (digits unchanged, upper→lower)
 *   2. Compute digit (input - '0') and alpha ((input|0x20) - 'a' + 10)
 *   3. Validate ranges: digit in [0,9] OR alpha in [10,15]
 *   4. Pack nibble pairs via multiply-add: (hi_nib << 4) | lo_nib
 */

#if defined(HEX_ARCH_X86_64)

__attribute__((target("ssse3")))
static int decode_hex_ssse3_16(const uint8_t *src, uint8_t *dst) {
    __m128i input = _mm_loadu_si128((const __m128i *)src);

    __m128i lower = _mm_or_si128(input, _mm_set1_epi8(0x20));

    __m128i digit = _mm_sub_epi8(input, _mm_set1_epi8(0x30));
    __m128i alpha = _mm_sub_epi8(lower, _mm_set1_epi8(0x57));

    __m128i nine    = _mm_set1_epi8(9);
    __m128i ten     = _mm_set1_epi8(10);
    __m128i fifteen = _mm_set1_epi8(15);

    __m128i is_digit = _mm_cmpeq_epi8(_mm_min_epu8(digit, nine), digit);
    __m128i is_alpha = _mm_and_si128(
        _mm_cmpeq_epi8(_mm_max_epu8(alpha, ten), alpha),
        _mm_cmpeq_epi8(_mm_min_epu8(alpha, fifteen), alpha));

    if (_mm_movemask_epi8(_mm_or_si128(is_digit, is_alpha)) != 0xFFFF)
        return -1;

    __m128i nibbles = _mm_or_si128(
        _mm_and_si128(is_digit, digit),
        _mm_andnot_si128(is_digit, alpha));

    /* Pack pairs: _mm_maddubs_epi16 with [16,1,16,1,...] */
    __m128i packed16 = _mm_maddubs_epi16(nibbles, _mm_set1_epi16(0x0110));
    __m128i packed8  = _mm_packus_epi16(packed16, _mm_setzero_si128());

    _mm_storel_epi64((__m128i *)dst, packed8);
    return 0;
}

#elif defined(HEX_ARCH_AARCH64)

static int decode_hex_neon_16(const uint8_t *src, uint8_t *dst) {
    uint8x16_t input = vld1q_u8(src);

    uint8x16_t lower = vorrq_u8(input, vdupq_n_u8(0x20));

    uint8x16_t digit = vsubq_u8(input, vdupq_n_u8(0x30));
    uint8x16_t alpha = vsubq_u8(lower, vdupq_n_u8(0x57));

    uint8x16_t is_digit = vcleq_u8(digit, vdupq_n_u8(9));
    uint8x16_t is_alpha = vandq_u8(
        vcgeq_u8(alpha, vdupq_n_u8(10)),
        vcleq_u8(alpha, vdupq_n_u8(15)));

    if (vminvq_u8(vorrq_u8(is_digit, is_alpha)) != 0xFF)
        return -1;

    uint8x16_t nibbles = vbslq_u8(is_digit, digit, alpha);

    /* Pack nibble pairs: separate even/odd, shift-or */
    uint8x16x2_t uzp = vuzpq_u8(nibbles, nibbles);
    uint8x8_t hi = vget_low_u8(uzp.val[0]);
    uint8x8_t lo = vget_low_u8(uzp.val[1]);

    vst1_u8(dst, vorr_u8(vshl_n_u8(hi, 4), lo));
    return 0;
}

#endif

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
#if defined(HEX_ARCH_X86_64)
    if (decode_hex_ssse3_16(src, dst) != 0) return -1;
    return decode_hex_ssse3_16(src + 16, dst + 8);
#elif defined(HEX_ARCH_AARCH64)
    if (decode_hex_neon_16(src, dst) != 0) return -1;
    return decode_hex_neon_16(src + 16, dst + 8);
#else
    return decode_hex_scalar(src, dst, 16);
#endif
}

int hs_otel_decode_span_id(const uint8_t *src, uint8_t *dst) {
#if defined(HEX_ARCH_X86_64)
    return decode_hex_ssse3_16(src, dst);
#elif defined(HEX_ARCH_AARCH64)
    return decode_hex_neon_16(src, dst);
#else
    return decode_hex_scalar(src, dst, 8);
#endif
}

int hs_otel_decode_hex(const uint8_t *src, uint8_t *dst, size_t dst_len) {
    return decode_hex_scalar(src, dst, dst_len);
}

/* ── Traceparent parser ─────────────────────────────────────────────── */

/*
 * Parse W3C traceparent: "VV-{32hex}-{16hex}-FF" (55 bytes for v00).
 *
 * Output is an aligned uint64_t[4]:
 *   out[0] = trace_id high Word64 (native byte order)
 *   out[1] = trace_id low  Word64 (native byte order)
 *   out[2] = span_id Word64 (native byte order)
 *   out[3] = (version << 8) | flags
 *
 * Returns: 0 = success, -1 = format error, -2 = all-zero trace,
 *          -3 = all-zero span
 */

/* W3C TC2: traceparent hex fields must use HEXDIGLC (lowercase only) */
static inline int is_lowercase_hex(const uint8_t *src, size_t len) {
    for (size_t i = 0; i < len; i++) {
        uint8_t c = src[i];
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')) continue;
        return -1;
    }
    return 0;
}

int hs_otel_parse_traceparent(const uint8_t *src, size_t len, uint64_t out[4]) {
    if (len < 55) return -1;

    /* Validate dashes */
    if (src[2] != '-' || src[35] != '-' || src[52] != '-') return -1;

    /* W3C TC2: all hex fields must be lowercase (HEXDIGLC) */
    if (is_lowercase_hex(src, 2) != 0) return -1;       /* version */
    if (is_lowercase_hex(src + 3, 32) != 0) return -1;  /* trace-id */
    if (is_lowercase_hex(src + 36, 16) != 0) return -1; /* span-id */
    if (is_lowercase_hex(src + 53, 2) != 0) return -1;  /* flags */

    /* Decode version (2 hex → 1 byte) */
    uint8_t ver;
    if (decode_hex_scalar(src, &ver, 1) != 0) return -1;

    /* W3C TC2: version ff is invalid */
    if (ver == 0xFF) return -1;

    /* Version 00 requires exactly 55 bytes */
    if (ver == 0 && len != 55) return -1;

    /* Decode trace_id (32 hex → 16 bytes) */
    uint8_t trace_buf[16] __attribute__((aligned(16)));
#if defined(HEX_ARCH_X86_64)
    if (decode_hex_ssse3_16(src + 3, trace_buf) != 0) return -1;
    if (decode_hex_ssse3_16(src + 3 + 16, trace_buf + 8) != 0) return -1;
#elif defined(HEX_ARCH_AARCH64)
    if (decode_hex_neon_16(src + 3, trace_buf) != 0) return -1;
    if (decode_hex_neon_16(src + 3 + 16, trace_buf + 8) != 0) return -1;
#else
    if (decode_hex_scalar(src + 3, trace_buf, 16) != 0) return -1;
#endif

    uint64_t hi, lo;
    memcpy(&hi, trace_buf, 8);
    memcpy(&lo, trace_buf + 8, 8);
    if (hi == 0 && lo == 0) return -2;

    /* Decode span_id (16 hex → 8 bytes) */
    uint8_t span_buf[8] __attribute__((aligned(8)));
#if defined(HEX_ARCH_X86_64)
    if (decode_hex_ssse3_16(src + 36, span_buf) != 0) return -1;
#elif defined(HEX_ARCH_AARCH64)
    if (decode_hex_neon_16(src + 36, span_buf) != 0) return -1;
#else
    if (decode_hex_scalar(src + 36, span_buf, 8) != 0) return -1;
#endif

    uint64_t sid;
    memcpy(&sid, span_buf, 8);
    if (sid == 0) return -3;

    /* Decode flags (2 hex → 1 byte) */
    uint8_t fl;
    if (decode_hex_scalar(src + 53, &fl, 1) != 0) return -1;

    out[0] = hi;
    out[1] = lo;
    out[2] = sid;
    out[3] = ((uint64_t)ver << 8) | (uint64_t)fl;
    return 0;
}

/* ── Traceparent encoder ────────────────────────────────────────────── */

/*
 * Encode traceparent: writes exactly 55 bytes to dst.
 * Format: "VV-{32hex}-{16hex}-FF"
 *
 * Input: trace_hi, trace_lo, span_id as native-order Word64;
 *        version and flags as bytes.
 */
void hs_otel_encode_traceparent(
    uint64_t trace_hi, uint64_t trace_lo,
    uint64_t span_w,
    uint8_t version, uint8_t flags,
    uint8_t *dst)
{
    /* "VV-" */
    encode_hex_scalar(&version, dst, 1);
    dst[2] = '-';

    /* "{32hex}-" */
    uint8_t trace_buf[16];
    memcpy(trace_buf,     &trace_hi, 8);
    memcpy(trace_buf + 8, &trace_lo, 8);
#if defined(HEX_ARCH_X86_64)
    encode_hex_ssse3_16(trace_buf, dst + 3);
#elif defined(HEX_ARCH_AARCH64)
    encode_hex_neon_16(trace_buf, dst + 3);
#else
    encode_hex_scalar(trace_buf, dst + 3, 16);
#endif
    dst[35] = '-';

    /* "{16hex}-" */
    uint8_t span_buf[8];
    memcpy(span_buf, &span_w, 8);
#if defined(HEX_ARCH_X86_64)
    encode_hex_ssse3_8(span_buf, dst + 36);
#elif defined(HEX_ARCH_AARCH64)
    encode_hex_neon_8(span_buf, dst + 36);
#else
    encode_hex_scalar(span_buf, dst + 36, 8);
#endif
    dst[52] = '-';

    /* "FF" */
    encode_hex_scalar(&flags, dst + 53, 1);
}
