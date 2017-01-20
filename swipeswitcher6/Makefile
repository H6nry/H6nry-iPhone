TARGET := iphone:clang

TARGET_SDK_VERSION := 6.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.0
ARCHS := armv7

include theos/makefiles/common.mk

TWEAK_NAME = SwipeSwitcher6
SwipeSwitcher6_FILES = Tweak.xm
#SwipeSwitcher6_FRAMEWORKS = CoreGraphics UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
