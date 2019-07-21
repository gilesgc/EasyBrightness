TARGET = iphone:clang
ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EasyBrightness

EasyBrightness_FILES = Tweak.xm
EasyBrightness_FRAMEWORKS = UIKit
EasyBrightness_PRIVATE_FRAMEWORKS = BackBoardServices
EasyBrightness_CFLAGS = -fobjc-arc

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += easybrightnessprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
