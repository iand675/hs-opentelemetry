#include <stdint.h>
#include <time.h>

/*
 * Fast wall-clock timestamp as nanoseconds since Unix epoch.
 *
 * Returns a single uint64_t, matching the OTLP wire format directly.
 * Platform-specific fast paths:
 *   - macOS: clock_gettime_nsec_np avoids struct timespec entirely
 *   - Linux: clock_gettime via vDSO (no syscall); one imul+add
 *   - Windows: GetSystemTimePreciseAsFileTime, scaled from 100ns ticks
 *   - Other: portable clock_gettime fallback
 *
 * CLOCK_REALTIME never fails, so we skip errno checks.
 */

#if defined(__APPLE__)

uint64_t hs_otel_gettime_ns(void) {
    return clock_gettime_nsec_np(CLOCK_REALTIME);
}

#elif defined(_WIN32) || defined(_WIN64)

/* mingw-w64 only declares clock_gettime through winpthreads, so read the Win32
 * clock directly. FILETIME counts 100ns ticks from 1601-01-01. */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#define HS_OTEL_FILETIME_TO_UNIX 116444736000000000ULL

uint64_t hs_otel_gettime_ns(void) {
    FILETIME ft;
    ULARGE_INTEGER ticks;
    GetSystemTimePreciseAsFileTime(&ft);
    ticks.LowPart  = ft.dwLowDateTime;
    ticks.HighPart = ft.dwHighDateTime;
    return (ticks.QuadPart - HS_OTEL_FILETIME_TO_UNIX) * 100ULL;
}

#else

uint64_t hs_otel_gettime_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

#endif
