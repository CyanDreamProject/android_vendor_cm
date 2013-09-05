# GSM APN list
PRODUCT_COPY_FILES += \
    vendor/cyandream/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

# GSM SPN overrides list
PRODUCT_COPY_FILES += \
    vendor/cyandream/prebuilt/common/etc/spn-conf.xml:system/etc/spn-conf.xml

# SIM Toolkit
PRODUCT_PACKAGES += \
    Stk

# Default ringtone
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=Orion.ogg \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Hassium.ogg

PRODUCT_PACKAGES += \
  Mms

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/cyandream/prebuilt/common/bootanimation/480.zip:system/media/bootanimation.zip
endif

# Bring in all audio files
include frameworks/base/data/sounds/NewAudio.mk

# Extra Ringtones
include frameworks/base/data/sounds/AudioPackageNewWave.mk

# Include CM audio files
include vendor/cyandream/config/cm_audio.mk

# Optional CM packages
PRODUCT_PACKAGES += \
    HoloSpiralWallpaper \
    LiveWallpapers \
    LiveWallpapersPicker \
    PhaseBeam
    
