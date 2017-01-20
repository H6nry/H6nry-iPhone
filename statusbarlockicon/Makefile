TARGET := iphone:clang

TARGET_SDK_VERSION := 9.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = StatusBarLockIcon
StatusBarLockIcon_FILES = Tweak.xm
StatusBarLockIcon_FRAMEWORKS = UIKit CoreGraphics

StatusBarLockIcon_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
