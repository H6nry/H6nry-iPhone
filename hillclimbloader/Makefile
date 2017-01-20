TARGET := iphone:clang

TARGET_SDK_VERSION := 7.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = HillClimbLoader
HillClimbLoader_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 'Hill Climb Racing'"
SUBPROJECTS += hclpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
