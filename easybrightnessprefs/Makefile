include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = EasyBrightness

EasyBrightness_FILES = EZBRootListController.m
EasyBrightness_INSTALL_PATH = /Library/PreferenceBundles
EasyBrightness_FRAMEWORKS = UIKit
EasyBrightness_PRIVATE_FRAMEWORKS = Preferences
EasyBrightness_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EasyBrightness.plist$(ECHO_END)
