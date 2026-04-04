/*
 * Fast CSPRNG for OpenTelemetry trace and span ID generation.
 *
 *   macOS/BSD  — arc4random_buf  (userspace ChaCha20, lock-free)
 *   Linux      — getrandom(2)    (kernel CSPRNG, no fd needed)
 *   Windows    — BCryptGenRandom (CNG, no provider handle needed)
 *   fallback   — /dev/urandom
 */

#include <stdint.h>
#include <stddef.h>

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

static int fill_random(uint8_t *buf, size_t n) {
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

int hs_otel_gen_trace_id(uint8_t *dst) {
    return fill_random(dst, 16);
}

int hs_otel_gen_span_id(uint8_t *dst) {
    return fill_random(dst, 8);
}

int hs_otel_gen_trace_and_span_id(uint8_t *dst) {
    return fill_random(dst, 24);
}
