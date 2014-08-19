#include "QtSharingKitPlugin.h"
#include "QtSharingKitApi.h"
#include "FBAppCredentials.h"

#include <qqml.h>

void QtSharingKitPlugin::registerTypes(const char *uri)
{
    // @uri Qtino.SharingKit
    qmlRegisterType<QtSharingKitApi>(uri, 1, 0, "SharingKitView");
    qmlRegisterType<FBAppCredentials>(uri, 1, 0, "FacebookAppCredentials");
}


