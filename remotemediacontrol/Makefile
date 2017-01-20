TARGET := iphone:clang

TARGET_SDK_VERSION := 9.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1
ARCHS := armv7 armv7s arm64


DEBUG := 1

include theos/makefiles/common.mk

TOOL_NAME = RemoteMediaControl
RemoteMediaControl_FILES = src/main.mm src/RCController.mm src/Network/RCNetworkManager.mm src/Playback/RCPlaybackManager.mm
RemoteMediaControl_FRAMEWORKS = Foundation CoreFoundation CFNetwork
RemoteMediaControl_PRIVATE_FRAMEWORKS = MediaRemote

RemoteMediaControl_LDFLAGS += -Wl,-segalign,4000 #iOS 9 support
RemoteMediaControl_CODESIGN_FLAGS = -Sentitlements.xml

ADDITIONAL_OBJCFLAGS = -fobjc-arc
CFLAGS += -include src/debug.h

include $(THEOS_MAKE_PATH)/tool.mk

after-install::
	install.exec "chown root:wheel /Library/LaunchDaemons/team.fanboyfanboy-h6nry.remotemediacontrol.plist; launchctl unload /Library/LaunchDaemons/team.fanboyfanboy-h6nry.remotemediacontrol.plist; launchctl load /Library/LaunchDaemons/team.fanboyfanboy-h6nry.remotemediacontrol.plist"
#chown and launchctl in install.exec and other package scripts is not recommended. TODO: Find a replacement.
