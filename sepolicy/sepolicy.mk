#
# This policy configuration will be used by all products that
# inherit from CD
#

BOARD_SEPOLICY_DIRS += \
    vendor/cyandream/sepolicy

BOARD_SEPOLICY_UNION += \
    file.te \
    file_contexts \
    fs_use \
    genfs_contexts \
    installd.te \
    seapp_contexts \
    mac_permissions.xml
