TARGET := iphone:clang

TARGET_SDK_VERSION := 6.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.0
ARCHS := armv7

DEBUG := 1

include theos/makefiles/common.mk

TWEAK_NAME = watchscreen
watchscreen_FILES = Tweak.xm
watchscreen_FRAMEWORKS = UIKit CoreGraphics

ADDITIONAL_OBJCFLAGS = -fobjc-arc

SUBPROJECTS += watchscreenpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
