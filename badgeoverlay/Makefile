export TARGET = iphone:clang:8.1:latest

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BadgeOverlay
BadgeOverlay_FILES = BORootListController.m
BadgeOverlay_INSTALL_PATH = /Library/PreferenceBundles
BadgeOverlay_FRAMEWORKS = UIKit MessageUI
BadgeOverlay_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BadgeOverlay.plist$(ECHO_END)
