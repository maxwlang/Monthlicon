# SDKVERSION = 11.2
# TARGET = iphone:11.2
TWEAK_NAME = Monthlicon
Monthlicon_FILES = Tweak.xm
Monthlicon_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
