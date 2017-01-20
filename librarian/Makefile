TARGET := iphone:clang

TARGET_SDK_VERSION := 7.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = librarian
librarian_FILES = Tweak.xm
librarian_FRAMEWORKS = Foundation
librarian_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Notes"
