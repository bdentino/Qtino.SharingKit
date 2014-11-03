#include "QtSharingKitApi.h"
#include <QtAndroidExtras>
#include <QGuiApplication>
#include <QQuickItemGrabResult>
#include <QQuickWindow>
#include <QTimer>

#include "JniSharingHelper.h"
#include "FacebookContent.h"
#include "ScreenShotItem.h"

struct QtSharingKitPrivate {
    JniSharingHelper* helper = NULL;
    QtSharingKitApi* api = NULL;
};

static void signalSharingComplete(JNIEnv* env, jobject thiz, jlong apiPtr)
{

}

QtSharingKitApi::QtSharingKitApi(QQuickItem *parent):
    QQuickItem(parent),
    m_privateData(NULL)
{
    m_privateData = new QtSharingKitPrivate();
    m_privateData->helper = new JniSharingHelper(this);
    m_privateData->api = this;
}

QtSharingKitApi::~QtSharingKitApi()
{
}

void QtSharingKitApi::launchShareActivity()
{
    m_privateData->helper->launchShareActivity();
}

Q_SHARING_EXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    Q_UNUSED(reserved)

    typedef union {
        JNIEnv *nenv;
        void *venv;
    } _JNIEnv;

    _JNIEnv uenv;
    uenv.venv = Q_NULLPTR;

    if (vm->GetEnv(&uenv.venv, JNI_VERSION_1_6) != JNI_OK)
        return JNI_ERR;

    QAndroidJniEnvironment environment;
    if (QAndroidJniObject::isClassAvailable("qtino/sharingkit/AndroidSharingActivity")) {
        JniSharingHelper::sharingActivityClass = environment->FindClass("qtino/sharingkit/JavaQObject");

        QAndroidJniObject sharingActivity("qtino/sharingkit/AndroidSharingActivity");
        QAndroidJniObject mainActivity = QtAndroid::androidActivity();
        sharingActivity.callMethod<void>("setupActivity",
                                         "(Landroid/app/Activity;)V",
                                         mainActivity.object<jobject>());
    }
    if (QAndroidJniObject::isClassAvailable("qtino/sharingkit/JavaQObject")) {
        JniSharingHelper::jqObjectClass = environment->FindClass("qtino/sharingkit/JavaQObject");
        JniSharingHelper::jqObjectConstructor = environment->GetMethodID(JniSharingHelper::jqObjectClass, "<init>", "()V");
    }

    JniSharingHelper::jqObjectClass = (jclass)(environment->NewGlobalRef(JniSharingHelper::jqObjectClass));
    JniSharingHelper::sharingActivityClass = (jclass)(environment->NewGlobalRef(JniSharingHelper::sharingActivityClass));



    qDebug() << "Loaded QtSharingKitApi_Android plugin";
    return JNI_VERSION_1_6;
}

