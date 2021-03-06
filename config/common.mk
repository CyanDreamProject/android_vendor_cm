PRODUCT_BRAND ?= cyanogenmod

SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.cyanogenmod.superuser

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/cyandream/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/cyandream/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/cyandream/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

ifdef CD_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmodnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1 \
    persist.sys.root_access=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/cyandream/CHANGELOG.mkdn:system/etc/CHANGELOG-CM.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/cyandream/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/cyandream/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/cyandream/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/cyandream/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cyandream/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cyandream/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/cyandream/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/cyandream/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/cyandream/proprietary/Term.apk:system/app/Term.apk \
    vendor/cyandream/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/cyandream/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/cyandream/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cyandream/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# T-Mobile theme engine
include vendor/cyandream/config/themes_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    Development \
    LatinIME \
    Superuser \
    BluetoothExt \
    su

# CyanDream packages
PRODUCT_PACKAGES += \
    ControlCenter \
    CyanDreamWallpapers \
    WWPF \
    xdelta3

# Optional CM packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji

# Custom CM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    CMAccount \
    CMWallpapers \
    Apollo \
    CMFileManager \
    LockClock \
    CMFota \
    CMAccount

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    procmem \
    procrank \
    Superuser \
    su

# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/cyandream/proprietary/Term.apk:system/app/Term.apk \
    vendor/cyandream/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/cyandream/overlay/common

PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = KK
PRODUCT_VERSION_MAINTENANCE = 0

# Set CD_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef CD_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "CD_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^CD_||g')
        CD_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(CD_BUILDTYPE)),)
    CD_BUILDTYPE :=
endif

ifdef CD_BUILDTYPE
    ifneq ($(CD_BUILDTYPE), SNAPSHOT)
        ifdef CD_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            CD_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from CD_EXTRAVERSION
            CD_EXTRAVERSION := $(shell echo $(CD_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CD_EXTRAVERSION
            CD_EXTRAVERSION := -$(CD_EXTRAVERSION)
        endif
    else
        ifndef CD_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            CD_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from CD_EXTRAVERSION
            CD_EXTRAVERSION := $(shell echo $(CD_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CD_EXTRAVERSION
            CD_EXTRAVERSION := -$(CD_EXTRAVERSION)
        endif
    endif
else
    # If CD_BUILDTYPE is not defined, set to UNOFFICIAL
    CD_BUILDTYPE := UNOFFICIAL
    CD_EXTRAVERSION :=
endif

ifeq ($(CD_BUILDTYPE), RELEASE)
    CD_VERSION := $(PRODUCT_VERSION_MAJOR)_$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CD_BUILD)
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        CD_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(CD_BUILDTYPE)$(CD_EXTRAVERSION)-$(CD_BUILD)
    else
        CD_VERSION := $(PRODUCT_VERSION_MAJOR)_$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(CD_BUILDTYPE)$(CD_EXTRAVERSION)-$(CD_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.version=$(CD_VERSION) \
  ro.modversion=$(CD_VERSION) \
  ro.cmlegal.url=http://www.cyanogenmod.org/docs/privacy

-include vendor/cd-priv/keys/keys.mk

CD_DISPLAY_VERSION := $(CD_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(CD_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(CD_EXTRAVERSION),)
        # Remove leading dash from CD_EXTRAVERSION
        CD_EXTRAVERSION := $(shell echo $(CD_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(CD_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    CD_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.display.version=$(CD_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk
