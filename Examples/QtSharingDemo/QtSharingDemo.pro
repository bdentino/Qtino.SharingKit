TEMPLATE = app

QT += qml quick svg

SOURCES += main.cpp

RESOURCES += qml.qrc

OTHER_FILES += main.qml

ios {
    QMAKE_IOS_DEPLOYMENT_TARGET = 6.0
    QMAKE_INFO_PLIST = iOS/Info.plist
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/Android

    OTHER_FILES += \
        Android/AndroidManifest.xml

    ANDROID_TARGET_VERSION = android-16
}

include($$PWD/../../QtSharingKit/QtSharingKit.pri)
