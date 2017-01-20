TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = adprefs
adprefs_FILES = adprefs.mm
adprefs_INSTALL_PATH = /Library/PreferenceBundles
adprefs_FRAMEWORKS = UIKit
adprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/adprefs.plist$(ECHO_END)
