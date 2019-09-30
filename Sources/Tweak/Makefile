include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CallSlicer
export ARCHS = armv7 arm64 arm64e

CallSlicer_FILES = Tweak.x
SDKVERSION = 11.2

# cf: https://github.com/theos/sdks
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = BulletinBoard
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei WebKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Springboard"
