TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7 armv7s arm64

Tapcounterd_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support

include theos/makefiles/common.mk

TOOL_NAME = Tapcounterd
Tapcounterd_FILES = main.mm
Tapcounterd_FRAMEWORKS = CoreFoundation

include $(THEOS_MAKE_PATH)/tool.mk
