include theos/makefiles/common.mk

BUNDLE_NAME = snapperprefs
snapperprefs_FILES = snapperprefs.mm
snapperprefs_INSTALL_PATH = /Library/PreferenceBundles
snapperprefs_FRAMEWORKS = UIKit
snapperprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/snapperprefs.plist$(ECHO_END)
