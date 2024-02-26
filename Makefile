# Configuration
APP_NAME = seed
APP_PKG = com.heaveless
APP_SDK = 33
APP_PWD = password

# Keystore
KS_FILE = $(APP_NAME).ks
KS_ALIAS = $(APP_NAME).alias
KS_PWD = $(APP_PWD)
KS_DNAME = "CN=heaveless.com, O=$(APP_NAME)"

# Android
ANDROID_VER = $(APP_SDK)
ANDROID_SDK = $(HOME)/Android/Sdk
ANDROID_NDK = $(wildcard $(ANDROID_SDK)/ndk/*)
ANDROID_TLS = $(lastword $(wildcard $(ANDROID_SDK)/build-tools/*))
ANDROID_CLC = $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$(ANDROID_VER)-clang

# Processing
CSRCS = main.c android_native_app_glue.c
CTARGETS = build/lib/arm64-v8a/lib$(APP_NAME).so

# CC Flags
CFLAGS = -ffunction-sections -Os -fdata-sections -Wall -fvisibility=hidden
CFLAGS += -Os -DANDROID -DAPPNAME=\"$(APP)\" -DANDROID_FULLSCREEN
CFLAGS += -Irawdraw -I$(ANDROID_NDK)/sysroot/usr/include -I$(ANDROID_NDK)/sysroot/usr/include/android -I$(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include -I$(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/android -fPIC -I. -DANDROIDVERSION=$(ANDROID_VER)
LDFLAGS = -Wl,--gc-sections -Wl,-Map=output.map -s
LDFLAGS += -lm -landroid -llog -lOpenSLES -lGLESv3 -lEGL
LDFLAGS += -shared -uANativeActivity_onCreate
LDFLAGS += -m64

$(CTARGETS): $(CSRCS)
	mkdir -p build/lib/arm64-v8a
	$(ANDROID_CLC) $(CFLAGS) -o $@ $^ \
	-L$(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/$(ANDROID_VER) \
	$(LDFLAGS)

mktmp.apk: $(CTARGETS) AndroidManifest.xml
	$(ANDROID_TLS)/aapt package -f -F tmp.apk \
	-I $(ANDROID_SDK)/platforms/android-$(ANDROID_VER)/android.jar \
	-M AndroidManifest.xml -S res -v --target-sdk-version $(ANDROID_VER)
	unzip -o tmp.apk -d build
	cd build && zip -D4r ../mktmp.apk . \
	&& zip -D0r ../mktmp.apk ./resources.arsc ./AndroidManifest.xml
	$(ANDROID_TLS)/zipalign -v 4 mktmp.apk $(APP_NAME).apk
	$(ANDROID_TLS)/apksigner sign --key-pass pass:$(KS_PWD) \
	--ks-pass pass:$(KS_PWD) --ks $(KS_FILE) $(APP_NAME).apk

$(KS_FILE):
	keytool -genkey -v -keystore $(KS_FILE) \
	-alias $(KS_ALIAS) -keyalg RSA -keysize 2048 \
	-validity 10000 -storepass $(KS_PWD) \
	-keypass $(KS_PWD) -dname $(KS_DNAME)

run: clean mktmp.apk
	adb install -r $(APP_NAME).apk
	adb shell am start -n com.heaveless.seed/android.app.NativeActivity

keystore: $(KS_FILE)

clean:
	rm -rf tmp.apk
	rm -rf mktmp.apk
	rm -rf build
	rm -rf output.map
	rm -rf $(APP_NAME).apk
	rm -rf $(APP_NAME).apk.idsig

.PHONY: all clean keystore run