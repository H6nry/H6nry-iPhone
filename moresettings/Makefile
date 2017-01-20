TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7

include theos/makefiles/common.mk

APPLICATION_NAME = MoreSettings
MoreSettings_FILES = main.m MoreSettingsApplication.mm RootViewController.mm
MoreSettings_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "chown mobile:mobile /etc/hosts; killall -9 MoreSettings;"
