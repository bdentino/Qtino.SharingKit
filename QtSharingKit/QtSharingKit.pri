#Sharing Kit Dependencies

QTSHARINGKIT_HOME = $$PWD

ios {
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

    LIBS += -F/Users/bdentino/FacebookSDK/iOS
    LIBS += -weak_framework FacebookSDK
    LIBS += -ObjC

#    -------------------------------------------------------------------------------------
#    No longer used, but a good example of how to include dependencies from 3rd-party libs
#    -------------------------------------------------------------------------------------
#
#    OTHER_FILES += $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*
#    xibs = $$system(ls $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*.nib)
#    for(file, xibs) {
#        bundleRes.files += $$file
#    }
#    pngs = $$system(ls $${QTSHARINGKIT_HOME}/iOS/Dependencies/OvershareKit/Resources/*.png)
#    for(file, pngs) {
#        bundleRes.files += $$file
#    }
#    QMAKE_BUNDLE_DATA += bundleRes
#    googleBundle.files = $${QTSHARINGKIT_HOME}/iOS/Dependencies/Google/GooglePlus.bundle
#    QMAKE_BUNDLE_DATA += googleBundle

    QMAKE_CXXFLAGS += -fmodules
}

android {
    QT += androidextras
    ANDROID_EXTRA_LIBS += $$[QT_INSTALL_QML]/Qtino/SharingKit/libSharingKit.so
    ANDROID_EXTRA_LIBS += $$[QT_INSTALL_PREFIX]/lib/libQt5AndroidExtras.so

    equals(ANDROID_PACKAGE_SOURCE_DIR,) {
        error(You must define ANDROID_PACKAGE_SOURCE_DIR for your project before including QtSharingKit.pri)
    }
    equals(ANDROID_TARGET_VERSION,) {
        ANDROID_TARGET_VERSION = $$(ANDROID_API_VERSION)
        equals(ANDROID_TARGET_VERSION,) {
            error(You must either define ANDROID_TARGET_VERSION in your project file before including QtSharingKit.pri or define the environment variable ANDROID_API_VERSION)
        }
    }
    # Create directory for library in project $$ANDROID_PACKAGE_SOURCE_DIR
    sharingkit-android-mkdir.commands = $$QMAKE_MKDIR $$ANDROID_PACKAGE_SOURCE_DIR/qtino/sharingkit/
    QMAKE_EXTRA_TARGETS += sharingkit-android-mkdir

    # Copy library into project android directory
    sharingkit-android-copy.commands = $$QMAKE_COPY_DIR $$PWD/Android/java/* $$ANDROID_PACKAGE_SOURCE_DIR/qtino/sharingkit
    sharingkit-android-copy.depends = sharingkit-android-mkdir
    QMAKE_EXTRA_TARGETS += sharingkit-android-copy

    # Add reference to the project including this library if it hasn't already been added
    # TODO: Make a Windows version of this command for devs in a Windows build environment
    equals(QMAKE_HOST.os, Darwin) {
        sharingkit-android-addref.commands = \
            touch $$ANDROID_PACKAGE_SOURCE_DIR/project.properties; \
            grep -xq "^android\.library\.reference\.[1-9][0-9]*=qtino/sharingkit[\ ]*" $$ANDROID_PACKAGE_SOURCE_DIR/project.properties \
            || $(ANDROID_SDK_ROOT)/tools/android update project --name $$TARGET --target $$ANDROID_TARGET_VERSION --path $$ANDROID_PACKAGE_SOURCE_DIR --library qtino/sharingkit
    } else {
        error(Please define a non-darwin equivalent for sharingkit-android-addref.commands)
    }
    sharingkit-android-addref.depends = sharingkit-android-copy
    QMAKE_EXTRA_TARGETS += sharingkit-android-addref

    first.depends += $(first) sharingkit-android-addref
    QMAKE_EXTRA_TARGETS += first

    export(first.depends)
    export(sharingkit-android-mkdir.commands)
    export(sharingkit-android-copy.commands)
    export(sharingkit-android-addref.commands)
}
