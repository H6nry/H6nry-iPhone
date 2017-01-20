TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7 armv7s arm64

tcprefs_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

include theos/makefiles/common.mk

BUNDLE_NAME = tcprefs
tcprefs_FILES = tcprefs.mm
tcprefs_INSTALL_PATH = /Library/PreferenceBundles
tcprefs_FRAMEWORKS = UIKit
tcprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/tcprefs.plist$(ECHO_END)
