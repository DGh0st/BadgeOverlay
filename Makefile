export ARCHS = armv7 arm64 arm64e
export TARGET = iphone:clang:13.0:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BadgeOverlay
BadgeOverlay_FILES = Tweak.xm
BadgeOverlay_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += badgeoverlay
include $(THEOS_MAKE_PATH)/aggregate.mk
