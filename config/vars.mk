PRODUCT_SOONG_NAMESPACES += \
    vendor/rising/vars

##### vars #####

## Art

# Always preopt extracted APKs to prevent extracting out of the APK for gms
# modules.
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true

# Do not generate libartd.
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Speed profile services and wifi-service to reduce RAM and storage.
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Use a profile based boot image for this device. Note that this is currently a
# generic profile and not Android Go optimized.
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := art/build/boot/boot-image-profile.txt

# Do not spin up a separate process for the network stack on go devices, use an in-process APK.
PRODUCT_PACKAGES += com.android.tethering.inprocess

# Disable dex2oat debug
USE_DEX2OAT_DEBUG := false

## Java

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Optimize java for system processes
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

## Scudo

# Use 32-bit libc variant by default
MALLOC_SVELTE_FOR_LIBC32 ?= true

## Vendor
PRODUCT_RESTRICT_VENDOR_FILES := false
