#if defined(__APPLE__)
#include <mach/mach.h>
#include <stdint.h>

int64_t hs_otel_get_rss(void) {
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kr = task_info(mach_task_self(),
                                MACH_TASK_BASIC_INFO,
                                (task_info_t)&info,
                                &count);
    if (kr != KERN_SUCCESS) return 0;
    return (int64_t)info.resident_size;
}
#endif
