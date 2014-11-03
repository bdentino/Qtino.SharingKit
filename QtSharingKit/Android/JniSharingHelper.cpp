#include "JniSharingHelper.h"
#include "ScreenShotItem.h"
#include "TextItem.h"
#include "DefaultContent.h"
#include "ShareableItem.h"

#include <QtAndroidExtras>
#include <QQuickItemGrabResult>
#include <QQuickWindow>
#include <QMetaType>

jclass JniSharingHelper::jqObjectClass;
jclass JniSharingHelper::sharingActivityClass;
jmethodID JniSharingHelper::jqObjectConstructor;

JniSharingHelper::JniSharingHelper(QtSharingKitApi* parent)
    : QObject(parent)
{
    sharingKit = parent;
}

void JniSharingHelper::launchShareActivity()
{
    QAndroidJniEnvironment environment;

    jobject contentObjects = prepareContentObjects(environment);
    QAndroidJniObject title(QAndroidJniObject::fromString(sharingKit->title()));
    QAndroidJniObject::callStaticMethod<void>(
        "qtino/sharingkit/AndroidSharingActivity",
        "launchSharingSelection",
        "(Ljava/lang/String;Lqtino/sharingkit/JavaQObject;J)V",
        title.object<jstring>(),
        contentObjects,
        (jlong)this);

    environment->DeleteLocalRef(contentObjects);
}

jobject JniSharingHelper::prepareContentObjects(QAndroidJniEnvironment& environment)
{
    QVariantMap objectsMap;
    if (QAndroidJniObject::isClassAvailable("qtino/sharingkit/AndroidSharingActivity"))
    {
        foreach (QObject* child, sharingKit->children())
        {
            //collect *Content classes
            if (!qobject_cast<DefaultContent*>(child)) continue;
            QString className = QString(child->metaObject()->className());
            objectsMap.insert(className, QVariant::fromValue<QObject*>(child));
        }
    }
    return QVariantToJObject(QVariant(objectsMap), environment);
}

// *** WARNING ***
// This function will run recursively, and is not yet smart enough to detect circular
// references, which means you'll get stuck in an infinite loop if two objects have
// properties that point to each other.
//
// Also note that you are responsible for releasing the local reference to the jobject
// returned from this call
jobject JniSharingHelper::QVariantToJObject(QVariant value, QAndroidJniEnvironment& environment)
{
    QMetaType::Type type = (QMetaType::Type)(value.type());

    jobject jvalue = 0;
    if (type == QMetaType::Bool) {
        static const jclass boolClass = environment->FindClass("java/lang/Boolean");
        static const jmethodID boolConstructor =
                environment->GetMethodID(boolClass, "<init>", "(Z)V");
        jvalue = environment->NewObject(boolClass,
                                        boolConstructor,
                                        (jboolean)(value.toBool()));
    }
    else if (type == QMetaType::Int) {
        static const jclass intClass = environment->FindClass("java/lang/Integer");
        static const jmethodID intConstructor
                = environment->GetMethodID(intClass, "<init>", "(I)V");
        jvalue = environment->NewObject(intClass,
                                        intConstructor,
                                        (jint)(value.toInt()));
    }
    else if (type == QMetaType::Double) {
        static const jclass doubleClass = environment->FindClass("java/lang/Double");
        static const jmethodID doubleConstructor
                = environment->GetMethodID(doubleClass, "<init>", "(D)V");
        jvalue = environment->NewObject(doubleClass,
                                        doubleConstructor,
                                        (jdouble)(value.toDouble()));
    }
    else if (type == QMetaType::Float) {
        static const jclass floatClass = environment->FindClass("java/lang/Float");
        static const jmethodID floatConstructor
                = environment->GetMethodID(floatClass, "<init>", "(F)V");
        jvalue = environment->NewObject(floatClass,
                                        floatConstructor,
                                        (jfloat)(value.toFloat()));
    }
    else if (type == QMetaType::QString) {
        jstring jString = environment->NewStringUTF(value.toString().toUtf8().data());
        jvalue = jString;
    }
    else if (type == QMetaType::QUrl) {
        jstring jString = environment->NewStringUTF(value.toString().toUtf8().data());
        jvalue = jString;
    }
    else if (type == QMetaType::QStringList) {
        QStringList values = value.toStringList();
        static const jclass alClass = environment->FindClass("java/util/ArrayList");
        static const jmethodID alConstructor = environment->GetMethodID(alClass, "<init>", "()V");
        jvalue = environment->NewObject(alClass, alConstructor);
        QAndroidJniObject arrayList(jvalue);
        foreach (QString listItem, values)
        {
            jobject listValue = QVariantToJObject(QVariant(listItem), environment);
            arrayList.callMethod<jboolean>("add", "(Ljava/lang/Object;)Z", listValue);
            environment->DeleteLocalRef(listValue);
        }
    }
    else if (type == QMetaType::QVariantList) {
        QVariantList values = value.toList();
        static const jclass vlClass = environment->FindClass("java/util/ArrayList");
        static const jmethodID vlConstructor = environment->GetMethodID(vlClass, "<init>", "()V");
        jvalue = environment->NewObject(vlClass, vlConstructor);
        QAndroidJniObject arrayList(jvalue);
        foreach (QVariant listItem, values)
        {
            jobject listValue = QVariantToJObject(listItem, environment);
            arrayList.callMethod<jboolean>("add", "(Ljava/lang/Object;)Z", listValue);
            environment->DeleteLocalRef(listValue);
        }
    }
    else if (type == QMetaType::QVariantMap) {
        QVariantMap valueMap = value.toMap();
        jobject objRef = environment->NewObject(jqObjectClass, jqObjectConstructor);
        QAndroidJniObject jObject(objRef);
        foreach (QString name, valueMap.keys())
        {
            QVariant mapItem = valueMap.value(name);
            jobject mapValue = QVariantToJObject(mapItem, environment);
            if (mapValue) {
                jObject.callMethod<void>("setProperty",
                                         "(Ljava/lang/String;Ljava/lang/Object;)V",
                                         QAndroidJniObject::fromString(name).object(),
                                         mapValue);
                environment->DeleteLocalRef(mapValue);
            }
        }
        jvalue = objRef;
    }
    else if (value.canConvert(QMetaType::QVariantList)) {
        static const jclass vlClass = environment->FindClass("java/util/ArrayList");
        static const jmethodID vlConstructor = environment->GetMethodID(vlClass, "<init>", "()V");
        jvalue = environment->NewObject(vlClass, vlConstructor);
        QAndroidJniObject arrayList(jvalue);
        QSequentialIterable iterable = value.value<QSequentialIterable>();
        foreach (QVariant listItem, iterable)
        {
            jobject listValue = QVariantToJObject(listItem, environment);
            arrayList.callMethod<jboolean>("add", "(Ljava/lang/Object;)Z", listValue);
            environment->DeleteLocalRef(listValue);
        }
    }
    else if (value.canConvert(QMetaType::QObjectStar)) {
        QObject* object = qvariant_cast<QObject*>(value);
        jvalue = JavaQObject(object, environment);
    }
    else {
        qWarning("JniSharingHelper warning: Conversion of MetaType %s to JavaQObject property is not yet supported",
               qPrintable(value.typeName()));
    }

    return jvalue;
}

// Note that the caller is responsible for releasing the local reference to the jobject
// returned by this function
jobject JniSharingHelper::JavaQObject(QObject* object, QAndroidJniEnvironment& environment)
{
    jobject objRef = environment->NewObject(jqObjectClass, jqObjectConstructor);
    QAndroidJniObject jObject(objRef);
    if (!object) return objRef;

    const QMetaObject* metaObj = object->metaObject();
    QStringList classHierarchy;
    while (metaObj) {
        classHierarchy.insert(0, QString(metaObj->className()));
        metaObj = metaObj->superClass();
    }

    jobject metatype = QVariantToJObject(QVariant::fromValue(classHierarchy), environment);
    jObject.callMethod<void>("setProperty",
                             "(Ljava/lang/String;Ljava/lang/Object;)V",
                             QAndroidJniObject::fromString("meta.type").object(),
                             metatype);
    environment->DeleteLocalRef(metatype);

    jobject jvalue;
    metaObj = object->metaObject();
    for (int i = 0; i < metaObj->propertyCount(); i++)
    {
        QMetaProperty property = metaObj->property(i);
        QString name = QString(property.name());
        QVariant value = property.read(object);
        jvalue = QVariantToJObject(value, environment);
        if (jvalue) {
            jObject.callMethod<void>("setProperty",
                                     "(Ljava/lang/String;Ljava/lang/Object;)V",
                                     QAndroidJniObject::fromString(name).object(),
                                     jvalue);
            environment->DeleteLocalRef(jvalue);
        }
    }
    foreach (QByteArray propName, object->dynamicPropertyNames())
    {
        QString name = QString(propName);
        QVariant value = object->property(name.toLocal8Bit().data());
        jvalue = QVariantToJObject(value, environment);
        if (jvalue) {
            jObject.callMethod<void>("setProperty",
                                     "(Ljava/lang/String;Ljava/lang/Object;)V",
                                     QAndroidJniObject::fromString(name).object(),
                                     jvalue);
            environment->DeleteLocalRef(jvalue);
        }
    }
    return objRef;
}
