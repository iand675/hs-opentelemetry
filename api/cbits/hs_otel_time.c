#include <stdint.h>
#include <time.h>

/*
 * Fast wall-clock timestamp as nanoseconds since Unix epoch.
 *
 * Returns a single uint64_t, matching the OTLP wire format directly.
 * Platform-specific fast paths:
 *   - macOS: clock_gettime_nsec_np avoids struct timespec entirely
 *   - Linux: clock_gettime via vDSO (no syscall); one imul+add
 *   - Other: portable clock_gettime fallback
 *
 * CLOCK_REALTIME never fails, so we skip errno checks.
 */

#if defined(__APPLE__)

uint64_t hs_otel_gettime_ns(void) {
    return clock_gettime_nsec_np(CLOCK_REALTIME);
}

#else

uint64_t hs_otel_gettime_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

#endif
