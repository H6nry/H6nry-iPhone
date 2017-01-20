TARGET := iphone:clang

TARGET_SDK_VERSION := 8.4
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7

include theos/makefiles/common.mk

TWEAK_NAME = 4camera
4camera_FILES = Tweak.xm
4camera_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Camera"
SUBPROJECTS += fourcameraprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
