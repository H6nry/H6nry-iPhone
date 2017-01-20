TARGET := iphone:clang

TARGET_SDK_VERSION := latest
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = RSSPeek
RSSPeek_FILES = RSSPeekController.m $(wildcard MWFeedParser/*.m)
RSSPeek_INSTALL_PATH = /Library/WeeLoader/Plugins
RSSPeek_FRAMEWORKS = UIKit CoreGraphics

RSSPeek_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

ADDITIONAL_OBJCFLAGS = -fobjc-arc -O2
DEBUG := 0

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += rsspeekprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
