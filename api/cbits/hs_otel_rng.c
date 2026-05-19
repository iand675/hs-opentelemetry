/*
 * RNG for OpenTelemetry trace and span ID generation.
 *
 * xoshiro256++ per OS thread, seeded once from the platform CSPRNG.
 * ~2-3x faster than a CSPRNG pool path because there is no shared
 * state, no atomics, and no syscalls after initial seed.
 * Fork-safe via pthread_atfork (reseeds in child).
 *
 * Platform CSPRNG (used only for seeding):
 *   macOS/BSD  — arc4random_buf  (userspace ChaCha20, lock-free)
 *   Linux      — getrandom(2)    (kernel CSPRNG, no fd needed)
 *   Windows    — BCryptGenRandom (CNG, no provider handle needed)
 *   fallback   — /dev/urandom
 */

#include <stdint.h>
#include <stddef.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
  #define USE_BCRYPT 1
  #define WIN32_LEAN_AND_MEAN
  #include <windows.h>
  #include <bcrypt.h>
#elif defined(__APPLE__) || defined(__FreeBSD__) || defined(__OpenBSD__) || defined(__NetBSD__)
  #define USE_ARC4RANDOM 1
  #include <stdlib.h>
#elif defined(__linux__)
  #define USE_GETRANDOM 1
  #include <sys/random.h>
  #include <errno.h>
#else
  #define USE_DEVURANDOM 1
  #include <stdio.h>
#endif

#if defined(_MSC_VER)
  #define THREAD_LOCAL __declspec(thread)
#else
  #define THREAD_LOCAL __thread
  #include <pthread.h>
#endif

/* ── Platform CSPRNG (seed source only) ──────────────────────────────── */

static int fill_random_platform(uint8_t *buf, size_t n) {
#if defined(USE_BCRYPT)
    NTSTATUS status = BCryptGenRandom(
        NULL, buf, (ULONG)n, BCRYPT_USE_SYSTEM_PREFERRED_RNG);
    return BCRYPT_SUCCESS(status) ? 0 : -1;
#elif defined(USE_ARC4RANDOM)
    arc4random_buf(buf, n);
    return 0;
#elif defined(USE_GETRANDOM)
    while (n > 0) {
        ssize_t got = getrandom(buf, n, 0);
        if (got < 0) {
            if (errno == EINTR) continue;
            return -1;
        }
        buf += got;
        n   -= (size_t)got;
    }
    return 0;
#elif defined(USE_DEVURANDOM)
    FILE *f = fopen("/dev/urandom", "rb");
    if (!f) return -1;
    size_t r = fread(buf, 1, n, f);
    fclose(f);
    return (r == n) ? 0 : -1;
#endif
}

/* ── xoshiro256++ (thread-local fast PRNG) ───────────────────────────── */
/*
 * Reference: https://prng.di.unimi.it/xoshiro256plusplus.c
 * by David Blackman and Sebastiano Vigna (vigna@acm.org), public domain.
 *
 * 256-bit state, 64-bit output, period 2^256-1.  Passes BigCrush and
 * PractRand.  Each OS thread gets its own state seeded from the platform
 * CSPRNG, so there is zero contention between threads.
 */

static inline uint64_t rotl64(uint64_t x, int k) {
    return (x << k) | (x >> (64 - k));
}

static THREAD_LOCAL uint64_t xoshiro_s[4];
static THREAD_LOCAL int       xoshiro_init;

static void xoshiro_seed(void) {
    fill_random_platform((uint8_t *)xoshiro_s, sizeof(xoshiro_s));
    if (xoshiro_s[0] == 0 && xoshiro_s[1] == 0 &&
        xoshiro_s[2] == 0 && xoshiro_s[3] == 0) {
        xoshiro_s[0] = 1;
    }
    xoshiro_init = 1;
}

static inline uint64_t xoshiro256pp(void) {
    if (__builtin_expect(!xoshiro_init, 0)) xoshiro_seed();

    const uint64_t result = rotl64(xoshiro_s[0] + xoshiro_s[3], 23) + xoshiro_s[0];
    const uint64_t t = xoshiro_s[1] << 17;

    xoshiro_s[2] ^= xoshiro_s[0];
    xoshiro_s[3] ^= xoshiro_s[1];
    xoshiro_s[1] ^= xoshiro_s[2];
    xoshiro_s[0] ^= xoshiro_s[3];
    xoshiro_s[2] ^= t;
    xoshiro_s[3]  = rotl64(xoshiro_s[3], 45);

    return result;
}

/* Fork safety: force reseed in child process so parent and child don't
 * share PRNG state (which would produce duplicate IDs). */
#if !defined(_WIN32) && !defined(_WIN64)
static void xoshiro_atfork_child(void) {
    xoshiro_init = 0;
}

__attribute__((constructor))
static void xoshiro_register_atfork(void) {
    pthread_atfork(NULL, NULL, xoshiro_atfork_child);
}
#endif

uint64_t hs_otel_xoshiro_next(void) {
    return xoshiro256pp();
}

/* Generate TraceId (2 words) + SpanId (1 word) in a single FFI call.
 * Used for root spans where both IDs need generating. Saves 2 FFI
 * round-trips vs 3 separate hs_otel_xoshiro_next calls. */
void hs_otel_xoshiro_trace_and_span(uint64_t *trace_hi, uint64_t *trace_lo, uint64_t *span_id) {
    *trace_hi = xoshiro256pp();
    *trace_lo = xoshiro256pp();
    *span_id  = xoshiro256pp();
}
