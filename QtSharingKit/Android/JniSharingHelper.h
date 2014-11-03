#ifndef JNISHARINGHELPER_H
#define JNISHARINGHELPER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QtAndroidExtras>
#include "QtSharingKitApi.h"

class JniSharingHelper : public QObject
{
    Q_OBJECT

public:
    JniSharingHelper(QtSharingKitApi* parent);

    static jclass jqObjectClass;
    static jclass sharingActivityClass;
    static jmethodID jqObjectConstructor;

    void launchShareActivity();

    jobject QVariantToJObject(QVariant variant, QAndroidJniEnvironment& env);
    jobject JavaQObject(QObject* object, QAndroidJniEnvironment& env);

private:
    jobject prepareContentObjects(QAndroidJniEnvironment& env);

private:
    QtSharingKitApi* sharingKit;

};

#endif // JNISHARINGHELPER_H
