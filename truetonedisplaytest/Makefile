include theos/makefiles/common.mk

APPLICATION_NAME = TrueToneDisplayTest
TrueToneDisplayTest_FILES = main.m TrueToneDisplayTestApplication.mm RootViewController.mm
TrueToneDisplayTest_FRAMEWORKS = UIKit CoreGraphics AVFoundation

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall TrueToneDisplayTest"
