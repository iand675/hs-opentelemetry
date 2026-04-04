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

/* ── RNG for ID generation ───────────────────────────────────────────── */

/* Generate 16 cryptographically random bytes (TraceId). Returns 0. */
int hs_otel_gen_trace_id(uint8_t *dst);

/* Generate 8 cryptographically random bytes (SpanId). Returns 0. */
int hs_otel_gen_span_id(uint8_t *dst);

/* Generate trace (16) + span (8) = 24 bytes in one call. Returns 0. */
int hs_otel_gen_trace_and_span_id(uint8_t *dst);

#endif /* HS_OTEL_HEX_H */
