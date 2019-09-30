include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CallSlicerPrefs
CallSlicerPrefs_FILES = Preferences.m
CallSlicerPrefs_INSTALL_PATH = /Library/PreferenceBundles
CallSlicerPrefs_FRAMEWORKS = UIKit
CallSlicerPrefs_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
CallSlicerPrefs_CFLAGS = -fobjc-arc

ARCHS = armv7 arm64 arm64e

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CallSlicerPrefs.plist$(ECHO_END)
