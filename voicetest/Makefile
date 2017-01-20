TARGET := iphone:clang

TARGET_SDK_VERSION := 6.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7

include theos/makefiles/common.mk

BUNDLE_NAME = voicetest
voicetest_INSTALL_PATH = /System/Library/VoiceServices/PlugIns
voicetest_BUNDLE_EXTENSION = vsplugin
voicetest_FILES = RecognitionResultHandlers.mm
voicetest_PRIVATE_FRAMEWORKS = VoiceServices

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "rm -rf /var/mobile/Library/Caches/VoiceServices; killall -9 SpringBoard"
