#ifndef HS_OTEL_HEX_H
#define HS_OTEL_HEX_H

#include <stddef.h>
#include <stdint.h>

/* Platform detection for SIMD paths */
#if defined(__x86_64__) || defined(_M_X64)
#define HEX_ARCH_X86_64 1
#include <immintrin.h>
#elif defined(__aarch64__) || defined(_M_ARM64)
#define HEX_ARCH_AARCH64 1
#include <arm_neon.h>
#endif

/* Encode exactly 16 bytes (TraceId) → 32 hex chars. SIMD where available. */
void hs_otel_encode_trace_id(const uint8_t *src, uint8_t *dst);

/* Encode exactly 8 bytes (SpanId) → 16 hex chars. SIMD where available. */
void hs_otel_encode_span_id(const uint8_t *src, uint8_t *dst);

/* Encode arbitrary length (scalar fallback). */
void hs_otel_encode_hex(const uint8_t *src, uint8_t *dst, size_t src_len);

/* Decode 32 hex chars → 16 bytes. Returns 0 on success, -1 on invalid hex. */
int hs_otel_decode_trace_id(const uint8_t *src, uint8_t *dst);

/* Decode 16 hex chars → 8 bytes. Returns 0 on success, -1 on invalid hex. */
int hs_otel_decode_span_id(const uint8_t *src, uint8_t *dst);

/* Decode 2*dst_len hex chars → dst_len bytes. Returns 0 or -1. */
int hs_otel_decode_hex(const uint8_t *src, uint8_t *dst, size_t dst_len);

/* ── W3C traceparent codec ───────────────────────────────────────────── */

/* Parse "VV-{32hex}-{16hex}-FF" into an aligned uint64_t[4]:
 *   out[0] = trace_hi, out[1] = trace_lo, out[2] = span_id,
 *   out[3] = (version << 8) | flags
 * Returns: 0=ok, -1=format, -2=zero-trace, -3=zero-span */
int hs_otel_parse_traceparent(const uint8_t *src, size_t len, uint64_t out[4]);

/* Encode 55-byte traceparent from Word64 trace/span + version/flags. */
void hs_otel_encode_traceparent(
    uint64_t trace_hi, uint64_t trace_lo,
    uint64_t span_w,
    uint8_t version, uint8_t flags,
    uint8_t *dst);

/* ── Fast PRNG (xoshiro256++, thread-local) ──────────────────────────── */

/* Generate 16 bytes via thread-local xoshiro256++. NOT crypto-secure.
 * Seeded from the platform CSPRNG on first use per OS thread. Returns 0. */
int hs_otel_gen_trace_id_fast(uint8_t *dst);

/* Generate 8 bytes via thread-local xoshiro256++. Returns 0. */
int hs_otel_gen_span_id_fast(uint8_t *dst);

/* Return a single xoshiro256++ output (64 bits). Ensures lazy init. */
uint64_t hs_otel_xoshiro_next(void);

/* Fill n bytes via thread-local xoshiro256++. Returns 0. */
int hs_otel_fill_fast_random(uint8_t *dst, size_t n);

#endif /* HS_OTEL_HEX_H */
