TEMPLATE = lib
TARGET = SharingKit

QT += qml quick gui gui-private
android {
    QT += androidextras
    ANDROID_PACKAGE_SOURCE_DIR += $$PWD/Android/java
    CONFIG -= android_install
}

CONFIG += qt plugin

DEFINES += QT_BUILD_SHARING_LIB

TARGET = $$qtLibraryTarget($$TARGET)
uri = Qtino.SharingKit
latest_version = 1.0

# Input
SOURCES += \
    FBAppCredentials.cpp \
    QtSharingKitPlugin.cpp \
    FacebookContent.cpp \
    TwitterContent.cpp \
    SmsContent.cpp \
    EmailContent.cpp \
    ScreenShotItem.cpp \
    TextItem.cpp \
    DefaultContent.cpp \
    OpenGraphObject.cpp \
    OpenGraphAction.cpp \
    GraphObjectRef.cpp \
    GraphObjectProperty.cpp \
    OpenGraphStory.cpp \
    ShareableImageItem.cpp \
    ImageItem.cpp \
    ShareableItem.cpp

HEADERS += \
    FBAppCredentials.h \
    QtSharingKitPlugin.h \
    QtSharingKitApi.h \
    FacebookContent.h \
    TwitterContent.h \
    SmsContent.h \
    EmailContent.h \
    ScreenShotItem.h \
    TextItem.h \
    DefaultContent.h \
    OpenGraphObject.h \
    OpenGraphAction.h \
    GraphObjectRef.h \
    GraphObjectProperty.h \
    OpenGraphStory.h \
    ShareableImageItem.h \
    ImageItem.h \
    ShareableItem.h

OTHER_FILES = qmldir QtSharingKit.pri

ios {
    CONFIG += static
    HEADERS += \
               iOS/QtSharingActivityItemProvider.h \
               iOS/FacebookCallbackHandler.h \
               iOS/QtSharingSwizzle.h \
               iOS/QtSharingActivityViewController.h \
               iOS/QtSharingActivityViewControllerDelegate.h

    OBJECTIVE_SOURCES += \
                         iOS/QtSharingKitApi_iOS.mm \
                         iOS/QtSharingActivityItemProvider.mm \
                         iOS/FacebookCallbackHandler.mm \
                         iOS/QtSharingSwizzle.mm \
                         iOS/QtSharingActivityViewController.mm

    INCLUDEPATH += /Users/bdentino/FacebookSDK/iOS/FacebookSDK.framework/Headers
    LIBS += -F/Users/bdentino/FacebookSDK/iOS
    LIBS += -framework FacebookSDK

    LIBS += -ObjC
    QMAKE_CXXFLAGS += -fmodules
}

macx {
    SOURCES += \
               OSX/QtSharingKitApi_OSX.cpp
}

android {
    HEADERS += \
               Android/JniSharingHelper.h
    SOURCES += \
               Android/QtSharingKitApi_Android.cpp \
               Android/JniSharingHelper.cpp

    OTHER_FILES += \
                   Android/java/src/qtino/sharingkit/* \
                   Android/java/AndroidManifest.xml
}

# Generic Plugin Project Settings
QMAKE_MOC_OPTIONS += -Muri=$$uri

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)

unix: { libprefix = lib }
win32: { libprefix = }

CONFIG(static, static|shared) {
    macx|ios|unix: { libsuffix = a }
    win32: { libsuffix = lib }
}
else {
    macx: { libsuffix = dylib }
    unix:!macx: { libsuffix = so }
    win32: { libsuffix = lib }
}

cleanTarget.files +=
cleanTarget.path += $$installPath
macx|ios|unix: cleanTarget.extra = rm -rf $$installPath/qmldir $$installPath/plugins.qmltypes $$installPath/$$libprefix$$TARGET$${qtPlatformTargetSuffix}.$$libsuffix

qmldir.files = qmldir
qmldir.path = $$installPath
target.path = $$installPath

plugindump.files +=
plugindump.path = $$installPath
plugindump.extra = qmlplugindump $$uri $$latest_version > $$_PRO_FILE_PWD_/plugins.qmltypes

qmltypes.files += $$_PRO_FILE_PWD_/plugins.qmltypes
qmltypes.path = $$installPath

INSTALLS += cleanTarget target qmldir
macx|win32|linux:!android { INSTALLS += plugindump }
INSTALLS += qmltypes

QMAKE_POST_LINK += make install
