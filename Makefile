ARCHS = arm64 arm64e
TARGET = iphone:clang:13.5:11.2

INSTALL_TARGET_PROCESSES = Coinbase

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CoinDark
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
