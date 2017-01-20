TARGET := iphone:clang

TARGET_SDK_VERSION := 7.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = SnapPer
SnapPer_FILES = Tweak.xm
SnapPer_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Snapchat"
SUBPROJECTS += snapperprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
