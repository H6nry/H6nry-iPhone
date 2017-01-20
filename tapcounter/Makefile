TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7 armv7s arm64

Tapcounter_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

include theos/makefiles/common.mk

TWEAK_NAME = Tapcounter
Tapcounter_FILES = Tweak.xm
Tapcounter_FRAMEWORKS = CoreFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "chown root:wheel /Library/LaunchDaemons/org.h6nry.tapcounterd.plist; chown root:wheel /usr/bin/Tapcounterd; killall Tapcounterd; launchctl unload /Library/LaunchDaemons/org.h6nry.tapcounterd.plist; launchctl load /Library/LaunchDaemons/org.h6nry.tapcounterd.plist; killall -9 SpringBoard;"

SUBPROJECTS += tcprefs
SUBPROJECTS += tapcounterd
include $(THEOS_MAKE_PATH)/aggregate.mk
