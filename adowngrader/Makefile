TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Adowngrader
Adowngrader_FILES = Tweak.xm
Adowngrader_FRAMEWORKS = CoreFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 itunesstored"

SUBPROJECTS += adprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
