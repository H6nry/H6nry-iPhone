TARGET := iphone:clang

TARGET_SDK_VERSION := latest
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = rsspeekprefs
rsspeekprefs_FILES = rsspeekprefs.mm
rsspeekprefs_INSTALL_PATH = /Library/PreferenceBundles
rsspeekprefs_FRAMEWORKS = UIKit
rsspeekprefs_PRIVATE_FRAMEWORKS = Preferences

rsspeekprefs_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

ADDITIONAL_OBJCFLAGS = -fobjc-arc -O2
DEBUG := 0

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/rsspeekprefs.plist$(ECHO_END)
