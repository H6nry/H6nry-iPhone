TARGET := iphone:clang

TARGET_SDK_VERSION := latest
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Dockplay
Dockplay_FILES = Tweak.xm
Dockplay_FRAMEWORKS = UIKit MediaPlayer

Dockplay_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

ADDITIONAL_OBJCFLAGS = -fobjc-arc -O2
DEBUG := 0

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
