#include <stdint.h>
#include <stddef.h>
#include <string.h>

/* ── Strategy A: RDRAND (Intel hardware RNG) ────────────────────────── */

#if defined(__x86_64__) && defined(__RDRND__)
#include <immintrin.h>

static int rdrand64(uint64_t *val) {
    /* _rdrand64_step returns 1 on success. Retry a few times on transient failure. */
    for (int i = 0; i < 10; i++) {
        if (_rdrand64_step((unsigned long long *)val)) return 1;
    }
    return 0;
}

int hs_rng_rdrand_span(uint8_t *dst) {
    uint64_t v;
    if (!rdrand64(&v)) return -1;
    memcpy(dst, &v, 8);
    return 0;
}

int hs_rng_rdrand_trace(uint8_t *dst) {
    uint64_t v1, v2;
    if (!rdrand64(&v1)) return -1;
    if (!rdrand64(&v2)) return -1;
    memcpy(dst, &v1, 8);
    memcpy(dst + 8, &v2, 8);
    return 0;
}
#else
int hs_rng_rdrand_span(uint8_t *dst)  { (void)dst; return -1; }
int hs_rng_rdrand_trace(uint8_t *dst) { (void)dst; return -1; }
#endif


/* ── Strategy B: getrandom(2) syscall ───────────────────────────────── */

#if defined(__linux__)
#include <sys/random.h>

int hs_rng_getrandom_span(uint8_t *dst) {
    ssize_t r = getrandom(dst, 8, GRND_NONBLOCK);
    return (r == 8) ? 0 : -1;
}

int hs_rng_getrandom_trace(uint8_t *dst) {
    ssize_t r = getrandom(dst, 16, GRND_NONBLOCK);
    return (r == 16) ? 0 : -1;
}
#else
int hs_rng_getrandom_span(uint8_t *dst)  { (void)dst; return -1; }
int hs_rng_getrandom_trace(uint8_t *dst) { (void)dst; return -1; }
#endif


/* ── Strategy C: SplitMix64 with __thread storage ───────────────────── */
/* Same algorithm as Haskell's System.Random (SplitMix). Fast, good
   statistical quality, no contention between threads.                   */

static __thread uint64_t splitmix_state = 0;
static __thread int      splitmix_initialized = 0;

static void splitmix_seed(void) {
    /* Seed from RDRAND if available, fall back to address-based entropy */
#if defined(__x86_64__) && defined(__RDRND__)
    if (_rdrand64_step((unsigned long long *)&splitmix_state)) {
        splitmix_initialized = 1;
        return;
    }
#endif
#if defined(__linux__)
    if (getrandom(&splitmix_state, 8, GRND_NONBLOCK) == 8) {
        splitmix_initialized = 1;
        return;
    }
#endif
    /* Last resort: mix stack address + a constant */
    uint64_t addr = (uint64_t)(uintptr_t)&splitmix_state;
    splitmix_state = addr ^ 0x9e3779b97f4a7c15ULL;
    splitmix_initialized = 1;
}

static inline uint64_t splitmix64_next(void) {
    if (__builtin_expect(!splitmix_initialized, 0)) {
        splitmix_seed();
    }
    splitmix_state += 0x9e3779b97f4a7c15ULL;
    uint64_t z = splitmix_state;
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
    z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
    return z ^ (z >> 31);
}

void hs_rng_splitmix_span(uint8_t *dst) {
    uint64_t v = splitmix64_next();
    memcpy(dst, &v, 8);
}

void hs_rng_splitmix_trace(uint8_t *dst) {
    uint64_t v1 = splitmix64_next();
    uint64_t v2 = splitmix64_next();
    memcpy(dst, &v1, 8);
    memcpy(dst + 8, &v2, 8);
}


/* ── Strategy D: xoshiro256** with __thread storage ─────────────────── */
/* Excellent statistical quality, very fast, 256 bits of state.          */

static __thread uint64_t xoshiro_s[4] = {0};
static __thread int      xoshiro_initialized = 0;

static inline uint64_t rotl(const uint64_t x, int k) {
    return (x << k) | (x >> (64 - k));
}

static void xoshiro_seed(void) {
    /* Use splitmix to seed xoshiro state */
    if (!splitmix_initialized) splitmix_seed();
    xoshiro_s[0] = splitmix64_next();
    xoshiro_s[1] = splitmix64_next();
    xoshiro_s[2] = splitmix64_next();
    xoshiro_s[3] = splitmix64_next();
    xoshiro_initialized = 1;
}

static inline uint64_t xoshiro256ss_next(void) {
    if (__builtin_expect(!xoshiro_initialized, 0)) {
        xoshiro_seed();
    }
    const uint64_t result = rotl(xoshiro_s[1] * 5, 7) * 9;
    const uint64_t t = xoshiro_s[1] << 17;

    xoshiro_s[2] ^= xoshiro_s[0];
    xoshiro_s[3] ^= xoshiro_s[1];
    xoshiro_s[1] ^= xoshiro_s[2];
    xoshiro_s[0] ^= xoshiro_s[3];

    xoshiro_s[2] ^= t;
    xoshiro_s[3] = rotl(xoshiro_s[3], 45);

    return result;
}

void hs_rng_xoshiro_span(uint8_t *dst) {
    uint64_t v = xoshiro256ss_next();
    memcpy(dst, &v, 8);
}

void hs_rng_xoshiro_trace(uint8_t *dst) {
    uint64_t v1 = xoshiro256ss_next();
    uint64_t v2 = xoshiro256ss_next();
    memcpy(dst, &v1, 8);
    memcpy(dst + 8, &v2, 8);
}
