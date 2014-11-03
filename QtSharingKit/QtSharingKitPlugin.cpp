#include "QtSharingKitPlugin.h"

#include "QtSharingKitApi.h"
#include "FBAppCredentials.h"
#include "FacebookContent.h"
#include "TwitterContent.h"
#include "SmsContent.h"
#include "EmailContent.h"
#include "DefaultContent.h"

#include "ShareableImageItem.h"
#include "ImageItem.h"
#include "ScreenShotItem.h"
#include "TextItem.h"

#include "OpenGraphAction.h"
#include "OpenGraphObject.h"
#include "GraphObjectProperty.h"
#include "OpenGraphStory.h"
#include "GraphObjectRef.h"

#include <qqml.h>

void QtSharingKitPlugin::registerTypes(const char *uri)
{
    // @uri Qtino.SharingKit
    qmlRegisterType<QtSharingKitApi>(uri, 1, 0, "SharingKitView");
    qmlRegisterType<FBAppCredentials>(uri, 1, 0, "FacebookAppCredentials");

    //  The *Content classes represent a specific avenue for sharing content
    //
    //  For example, FacebookContent contains content that will be posted if the
    //  user chooses to share on Facebook. EmailContent data will be exported if
    //  the app chosen is an email application. Data from SmsContent will be shared
    //  if the user selects an app for sending SMS/MMS, etc. This allows you to
    //  tailor the shared data depending on the abilities/limitations of the app
    //  or platform the user wants to share with.
    //
    //  In order to not limit users' choices, however, DefaultContent allows you to
    //  specify generic content that will be shared by any app that can handle the
    //  provided *Item types but may not have a corresponding custom *Content
    //  implementation.

    qmlRegisterType<FacebookContent>(uri, 1, 0, "FacebookContent");
    qmlRegisterType<TwitterContent>(uri, 1, 0, "TwitterContent");
    qmlRegisterType<SmsContent>(uri, 1, 0, "SmsContent");
    qmlRegisterType<EmailContent>(uri, 1, 0, "EmailContent");
    qmlRegisterType<DefaultContent>(uri, 1, 0, "DefaultContent");

    //  The *Item classes represent a container for a particular type of content
    qmlRegisterUncreatableType<ShareableItem>(uri, 1, 0, "ShareableItem", "ShareableItem is an abstract class");
    qmlRegisterUncreatableType<ShareableImageItem>(uri, 1, 0, "ShareableImageItem", "ShareableImageItem is an abstract class");
    qmlRegisterType<ScreenShotItem>(uri, 1, 0, "ScreenShotItem");
    qmlRegisterType<ImageItem>(uri, 1, 0, "ImageItem");
    qmlRegisterType<TextItem>(uri, 1, 0, "TextItem");

    //  Facebook API Objects
    qmlRegisterType<OpenGraphStory>(uri, 1, 0, "OpenGraphStory");
    qmlRegisterType<OpenGraphAction>(uri, 1, 0, "OpenGraphAction");
    qmlRegisterType<OpenGraphObject>(uri, 1, 0, "OpenGraphObject");
    qmlRegisterType<GraphObjectProperty>(uri, 1, 0, "GraphObjectProperty");
    qmlRegisterType<GraphObjectRef>(uri, 1, 0, "GraphObjectRef");

}
