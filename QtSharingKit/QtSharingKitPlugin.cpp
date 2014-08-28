#include "QtSharingKitPlugin.h"

#include "QtSharingKitApi.h"
#include "FBAppCredentials.h"
#include "FacebookContent.h"
#include "MicroblogContent.h"
#include "SmsContent.h"
#include "EmailContent.h"
#include "UrlShortener.h"

#include <qqml.h>

void QtSharingKitPlugin::registerTypes(const char *uri)
{
    // @uri Qtino.SharingKit
    qmlRegisterType<QtSharingKitApi>(uri, 1, 0, "SharingKitView");
    qmlRegisterType<FBAppCredentials>(uri, 1, 0, "FacebookAppCredentials");
    qmlRegisterType<FacebookContent>(uri, 1, 0, "FacebookContent");
    qmlRegisterType<MicroblogContent>(uri, 1, 0, "MicroblogContent");
    qmlRegisterType<SmsContent>(uri, 1, 0, "SmsContent");
    qmlRegisterType<EmailContent>(uri, 1, 0, "EmailContent");
    qmlRegisterType<UrlShortener>(uri, 1, 0, "UrlShortener");
}


