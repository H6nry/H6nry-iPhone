TARGET := iphone:clang

TARGET_SDK_VERSION := 9.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = ncfprefs
ncfprefs_FILES = ncfprefs.mm
ncfprefs_INSTALL_PATH = /Library/PreferenceBundles
ncfprefs_FRAMEWORKS = UIKit
ncfprefs_PRIVATE_FRAMEWORKS = Preferences

NCForward_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ncfprefs.plist$(ECHO_END)
