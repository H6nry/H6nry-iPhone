TARGET := iphone:clang

TARGET_SDK_VERSION := 9.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

DEBUG := 1

include theos/makefiles/common.mk

TWEAK_NAME = NCForward
NCForward_FILES = Tweak.xm
NCForward_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ncfprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
