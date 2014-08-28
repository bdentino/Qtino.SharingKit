TEMPLATE = lib
TARGET = SharingKit
QT += qml quick gui gui-private
CONFIG += qt plugin

TARGET = $$qtLibraryTarget($$TARGET)
uri = Qtino.SharingKit
latest_version = 1.0

# Input
SOURCES += \
    FBAppCredentials.cpp \
    QtSharingKitPlugin.cpp \
    FacebookContent.cpp \
    MicroblogContent.cpp \
    SmsContent.cpp \
    EmailContent.cpp

HEADERS += \
    FBAppCredentials.h \
    QtSharingKitPlugin.h \
    QtSharingKitApi.h \
    FacebookContent.h \
    MicroblogContent.h \
    SmsContent.h \
    EmailContent.h \
    UrlShortener.h

OTHER_FILES = qmldir QtSharingKit.pri

ios {
    CONFIG += static
    HEADERS += \
               iOS/QtSharingOSKCustomizations.h \
               iOS/QtSharingViewController.h

    OBJECTIVE_SOURCES += \
                         iOS/QtSharingOSKCustomizations.mm \
                         iOS/QtSharingViewController.mm \
                         iOS/QtSharingKitApi_iOS.mm \
                         iOS/UrlShortener.mm

    INCLUDEPATH += $$PWD/iOS/Dependencies/OvershareKit \
                   $$PWD/iOS/Dependencies/OvershareKit/OvershareKit

    LIBS += -L$$PWD/iOS/Dependencies/OvershareKit
    LIBS += -lOvershareKit

    QMAKE_LFLAGS += -ObjC

    QMAKE_POST_LINK += "libtool -static -o lib$${TARGET}.a lib$${TARGET}.a $$PWD/iOS/Dependencies/OvershareKit/libOvershareKit.a;"
    QMAKE_CXXFLAGS += -fmodules
}

macx {
    SOURCES += \
               OSX/QtSharingKitApi_OSX.cpp
               OSX/UrlShortener.cpp
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
macx|win32|linux: INSTALLS += plugindump
INSTALLS += qmltypes

QMAKE_POST_LINK += make install
