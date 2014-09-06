#Sharing Kit Dependencies
ios {
    QTSHARINGKIT_HOME = $$PWD

    QMAKE_IOS_DEPLOYMENT_TARGET = 6.0

    LIBS += -weak_framework CoreMotion \
            -weak_framework CoreLocation \
            -weak_framework AddressBook \
            -weak_framework Social \
            -weak_framework SystemConfiguration \
            -weak_framework Accounts \
            -weak_framework MessageUI \
            -weak_framework Security \
            -weak_framework SafariServices \
            -weak_framework StoreKit \
            -weak_framework MediaPlayer

    QMAKE_LFLAGS += -F$${QTSHARINGKIT_HOME}/iOS/Dependencies/Google -ObjC
    LIBS += -weak_framework GooglePlus \
            -weak_framework GoogleOpenSource

    OTHER_FILES += $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*

    xibs = $$system(ls $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*.xib)
    for(file, xibs) {
        bundleRes.files += $$file
    }
    pngs = $$system(ls $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*.png)
    for(file, pngs) {
        bundleRes.files += $$file
    }
    QMAKE_BUNDLE_DATA += bundleRes

    googleBundle.files = $${QTSHARINGKIT_HOME}/iOS/Dependencies/Google/GooglePlus.bundle
    #QMAKE_BUNDLE_DATA += googleBundle

    QMAKE_CXXFLAGS += -fmodules
}
