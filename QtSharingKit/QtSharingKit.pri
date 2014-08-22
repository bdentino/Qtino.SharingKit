#Sharing Kit Dependencies
QTSHARINGKIT_HOME = $$PWD

QMAKE_IOS_DEPLOYMENT_TARGET = 7.0

LIBS += -framework CoreMotion \
        -framework CoreLocation \
        -framework AddressBook \
        -framework Social \
        -framework SystemConfiguration \
        -framework Accounts \
        -framework MessageUI \
        -framework Security \
        -framework SafariServices \
        -framework StoreKit \
        -framework MediaPlayer

QMAKE_LFLAGS += -F$${QTSHARINGKIT_HOME}/iOS/Dependencies/Google -ObjC
LIBS += -framework GooglePlus \
        -framework GoogleOpenSource

OTHER_FILES += $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*

xibs = $$system(ls $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*.xib)
for(file, xibs) {
    bundleRes.files += $$file
}
pngs = $$system(ls $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*.png)
for(file, pngs) {
    bundleRes.files += $$file
}
message($$bundleRes.files)
QMAKE_BUNDLE_DATA += bundleRes

googleBundle.files = $${QTSHARINGKIT_HOME}/iOS/Dependencies/Google/GooglePlus.bundle
#QMAKE_BUNDLE_DATA += googleBundle

QMAKE_CXXFLAGS += -fmodules
