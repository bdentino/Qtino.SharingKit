TEMPLATE = app

QT += qml quick

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

ios {
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

    QMAKE_LFLAGS += -F$$PWD/../../QtSharingKit/iOS/Dependencies/Google -ObjC
    LIBS += -framework GooglePlus \
            -framework GoogleOpenSource

    OTHER_FILES += $$PWD/../../QtSharingKit/iOS/Dependencies/OvershareKit/Resources/*

    xibs = $$system(ls $$$$PWD/../../QtSharingKit/iOS/Dependencies/OvershareKit/Resources/*.xib)
    for(file, xibs) {
        bundleRes.files += $$file
    }
    pngs = $$system(ls $$$$PWD/../../QtSharingKit/iOS/Dependencies/OvershareKit/Resources/*.png)
    for(file, pngs) {
        bundleRes.files += $$file
    }
    message($$bundleRes.files)
    QMAKE_BUNDLE_DATA += bundleRes

    googleBundle.files = $$PWD/../../QtSharingKit/iOS/Dependencies/Google/GooglePlus.bundle

    QMAKE_CXXFLAGS += -fmodules
}
