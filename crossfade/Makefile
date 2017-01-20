TARGET := iphone:clang

TARGET_SDK_VERSION := 8.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 arm64

DEBUG := 0

include theos/makefiles/common.mk

TWEAK_NAME = crossfade
crossfade_FILES = Tweak.xm
crossfade_FRAMEWORKS = CoreMedia AVFoundation AudioToolbox

crossfade_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support
ADDITIONAL_OBJCFLAGS = -fobjc-arc -O2

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Music~iphone; killall -9 Preferences"
SUBPROJECTS += crossfademusicprefshook
include $(THEOS_MAKE_PATH)/aggregate.mk
