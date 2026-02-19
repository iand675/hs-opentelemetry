#include <stdint.h>
#include <stddef.h>
#include <string.h>

/* ── 256-entry lookup table: each byte maps to 2 hex chars packed into uint16 ── */

static const uint16_t hex_encode_lut[256] = {
#define H(x) ( (uint16_t)("0123456789abcdef"[(x)>>4]) | ((uint16_t)("0123456789abcdef"[(x)&0xf]) << 8) )
    H(0x00),H(0x01),H(0x02),H(0x03),H(0x04),H(0x05),H(0x06),H(0x07),
    H(0x08),H(0x09),H(0x0a),H(0x0b),H(0x0c),H(0x0d),H(0x0e),H(0x0f),
    H(0x10),H(0x11),H(0x12),H(0x13),H(0x14),H(0x15),H(0x16),H(0x17),
    H(0x18),H(0x19),H(0x1a),H(0x1b),H(0x1c),H(0x1d),H(0x1e),H(0x1f),
    H(0x20),H(0x21),H(0x22),H(0x23),H(0x24),H(0x25),H(0x26),H(0x27),
    H(0x28),H(0x29),H(0x2a),H(0x2b),H(0x2c),H(0x2d),H(0x2e),H(0x2f),
    H(0x30),H(0x31),H(0x32),H(0x33),H(0x34),H(0x35),H(0x36),H(0x37),
    H(0x38),H(0x39),H(0x3a),H(0x3b),H(0x3c),H(0x3d),H(0x3e),H(0x3f),
    H(0x40),H(0x41),H(0x42),H(0x43),H(0x44),H(0x45),H(0x46),H(0x47),
    H(0x48),H(0x49),H(0x4a),H(0x4b),H(0x4c),H(0x4d),H(0x4e),H(0x4f),
    H(0x50),H(0x51),H(0x52),H(0x53),H(0x54),H(0x55),H(0x56),H(0x57),
    H(0x58),H(0x59),H(0x5a),H(0x5b),H(0x5c),H(0x5d),H(0x5e),H(0x5f),
    H(0x60),H(0x61),H(0x62),H(0x63),H(0x64),H(0x65),H(0x66),H(0x67),
    H(0x68),H(0x69),H(0x6a),H(0x6b),H(0x6c),H(0x6d),H(0x6e),H(0x6f),
    H(0x70),H(0x71),H(0x72),H(0x73),H(0x74),H(0x75),H(0x76),H(0x77),
    H(0x78),H(0x79),H(0x7a),H(0x7b),H(0x7c),H(0x7d),H(0x7e),H(0x7f),
    H(0x80),H(0x81),H(0x82),H(0x83),H(0x84),H(0x85),H(0x86),H(0x87),
    H(0x88),H(0x89),H(0x8a),H(0x8b),H(0x8c),H(0x8d),H(0x8e),H(0x8f),
    H(0x90),H(0x91),H(0x92),H(0x93),H(0x94),H(0x95),H(0x96),H(0x97),
    H(0x98),H(0x99),H(0x9a),H(0x9b),H(0x9c),H(0x9d),H(0x9e),H(0x9f),
    H(0xa0),H(0xa1),H(0xa2),H(0xa3),H(0xa4),H(0xa5),H(0xa6),H(0xa7),
    H(0xa8),H(0xa9),H(0xaa),H(0xab),H(0xac),H(0xad),H(0xae),H(0xaf),
    H(0xb0),H(0xb1),H(0xb2),H(0xb3),H(0xb4),H(0xb5),H(0xb6),H(0xb7),
    H(0xb8),H(0xb9),H(0xba),H(0xbb),H(0xbc),H(0xbd),H(0xbe),H(0xbf),
    H(0xc0),H(0xc1),H(0xc2),H(0xc3),H(0xc4),H(0xc5),H(0xc6),H(0xc7),
    H(0xc8),H(0xc9),H(0xca),H(0xcb),H(0xcc),H(0xcd),H(0xce),H(0xcf),
    H(0xd0),H(0xd1),H(0xd2),H(0xd3),H(0xd4),H(0xd5),H(0xd6),H(0xd7),
    H(0xd8),H(0xd9),H(0xda),H(0xdb),H(0xdc),H(0xdd),H(0xde),H(0xdf),
    H(0xe0),H(0xe1),H(0xe2),H(0xe3),H(0xe4),H(0xe5),H(0xe6),H(0xe7),
    H(0xe8),H(0xe9),H(0xea),H(0xeb),H(0xec),H(0xed),H(0xee),H(0xef),
    H(0xf0),H(0xf1),H(0xf2),H(0xf3),H(0xf4),H(0xf5),H(0xf6),H(0xf7),
    H(0xf8),H(0xf9),H(0xfa),H(0xfb),H(0xfc),H(0xfd),H(0xfe),H(0xff),
#undef H
};


/* ── Strategy 1: scalar loop with 256-entry LUT (one 16-bit write per byte) ── */

void hs_hex_encode_lut(const uint8_t *src, size_t len, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    for (size_t i = 0; i < len; i++) {
        out[i] = lut[src[i]];
    }
}


/* ── Strategy 2: unrolled 8-byte loop (processes 8 input bytes at a time) ── */

void hs_hex_encode_lut_unrolled(const uint8_t *src, size_t len, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    size_t i = 0;

    for (; i + 8 <= len; i += 8) {
        out[i+0] = lut[src[i+0]];
        out[i+1] = lut[src[i+1]];
        out[i+2] = lut[src[i+2]];
        out[i+3] = lut[src[i+3]];
        out[i+4] = lut[src[i+4]];
        out[i+5] = lut[src[i+5]];
        out[i+6] = lut[src[i+6]];
        out[i+7] = lut[src[i+7]];
    }
    for (; i < len; i++) {
        out[i] = lut[src[i]];
    }
}


/* ── Strategy 3: arithmetic (branchless, no table) ── */

static inline void encode_byte_arith(uint8_t b, uint8_t *out) {
    uint8_t hi = b >> 4;
    uint8_t lo = b & 0x0f;
    /* branchless: if nibble < 10 then '0'+nibble else 'a'+nibble-10 */
    out[0] = hi + (hi < 10 ? '0' : 'a' - 10);
    out[1] = lo + (lo < 10 ? '0' : 'a' - 10);
}

void hs_hex_encode_arith(const uint8_t *src, size_t len, uint8_t *dst) {
    for (size_t i = 0; i < len; i++) {
        encode_byte_arith(src[i], dst + i * 2);
    }
}


/* ── Strategy 4: hardcoded 16-byte (TraceId) encode ── */

void hs_hex_encode_16(const uint8_t *src, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    out[ 0] = lut[src[ 0]];
    out[ 1] = lut[src[ 1]];
    out[ 2] = lut[src[ 2]];
    out[ 3] = lut[src[ 3]];
    out[ 4] = lut[src[ 4]];
    out[ 5] = lut[src[ 5]];
    out[ 6] = lut[src[ 6]];
    out[ 7] = lut[src[ 7]];
    out[ 8] = lut[src[ 8]];
    out[ 9] = lut[src[ 9]];
    out[10] = lut[src[10]];
    out[11] = lut[src[11]];
    out[12] = lut[src[12]];
    out[13] = lut[src[13]];
    out[14] = lut[src[14]];
    out[15] = lut[src[15]];
}


/* ── Strategy 5: hardcoded 8-byte (SpanId) encode ── */

void hs_hex_encode_8(const uint8_t *src, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    out[0] = lut[src[0]];
    out[1] = lut[src[1]];
    out[2] = lut[src[2]];
    out[3] = lut[src[3]];
    out[4] = lut[src[4]];
    out[5] = lut[src[5]];
    out[6] = lut[src[6]];
    out[7] = lut[src[7]];
}


/* ── Strategy 6: process 4 bytes at a time using LUT but with fewer loop iterations ── */

void hs_hex_encode_wide(const uint8_t *src, size_t len, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    size_t i = 0;
    for (; i + 4 <= len; i += 4) {
        out[i+0] = lut[src[i+0]];
        out[i+1] = lut[src[i+1]];
        out[i+2] = lut[src[i+2]];
        out[i+3] = lut[src[i+3]];
    }
    for (; i < len; i++) {
        out[i] = lut[src[i]];
    }
}


/* ── Decode: 256-byte LUT (shared) ── */

static const uint8_t hex_decode_lut[256] = {
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
      0,  1,  2,  3,  4,  5,  6,  7,  8,  9,255,255,255,255,255,255,
    255, 10, 11, 12, 13, 14, 15,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255, 10, 11, 12, 13, 14, 15,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
};

/* ── Strategy 7: encode from raw pointer (for pinned or temporarily-stable memory) ── */
/* Identical to hs_hex_encode_16 but named distinctly for clarity */

void hs_hex_encode_16_raw(const uint8_t *src, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    out[ 0] = lut[src[ 0]]; out[ 1] = lut[src[ 1]];
    out[ 2] = lut[src[ 2]]; out[ 3] = lut[src[ 3]];
    out[ 4] = lut[src[ 4]]; out[ 5] = lut[src[ 5]];
    out[ 6] = lut[src[ 6]]; out[ 7] = lut[src[ 7]];
    out[ 8] = lut[src[ 8]]; out[ 9] = lut[src[ 9]];
    out[10] = lut[src[10]]; out[11] = lut[src[11]];
    out[12] = lut[src[12]]; out[13] = lut[src[13]];
    out[14] = lut[src[14]]; out[15] = lut[src[15]];
}

void hs_hex_encode_8_raw(const uint8_t *src, uint8_t *dst) {
    const uint16_t *lut = hex_encode_lut;
    uint16_t *out = (uint16_t *)dst;
    out[0] = lut[src[0]]; out[1] = lut[src[1]];
    out[2] = lut[src[2]]; out[3] = lut[src[3]];
    out[4] = lut[src[4]]; out[5] = lut[src[5]];
    out[6] = lut[src[6]]; out[7] = lut[src[7]];
}


/* Returns 0 on success, -1 on invalid input */
int hs_hex_decode(const uint8_t *src, size_t len, uint8_t *dst) {
    for (size_t i = 0; i < len; i += 2) {
        uint8_t hi = hex_decode_lut[src[i]];
        uint8_t lo = hex_decode_lut[src[i+1]];
        if ((hi | lo) & 0x80) return -1;
        dst[i/2] = (hi << 4) | lo;
    }
    return 0;
}
