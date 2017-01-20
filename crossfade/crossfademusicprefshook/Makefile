TARGET := iphone:clang

TARGET_SDK_VERSION := 9.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 arm64

DEBUG := 0

include theos/makefiles/common.mk

TWEAK_NAME = crossfademusicprefshook
crossfademusicprefshook_FILES = Tweak.xm
crossfademusicprefshook_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
