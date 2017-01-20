TARGET := iphone:clang

TARGET_SDK_VERSION := 6.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7

include theos/makefiles/common.mk

APPLICATION_NAME = Bottle
Bottle_FILES = main.m BottleApplication.mm RootViewController.mm BrowserViewClass.mm
Bottle_FRAMEWORKS = UIKit CoreGraphics AVFoundation

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 Bottle"
