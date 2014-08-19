#ifndef QTSHARINGOSKCUSTOMIZATIONS_H
#define QTSHARINGOSKCUSTOMIZATIONS_H

#include <UIKit/UIKit.h>

#include <OSKActivityCustomizations.h>
#include <OSKApplicationCredential.h>

#include "FBAppCredentials.h"

@interface QtSharingOSKCustomizations : NSObject <OSKActivityCustomizations>

- (void) setFacebookCredentials: (FBAppCredentials*) credentials;

- (OSKApplicationCredential*) applicationCredentialForActivityType:
        (NSString*) activityType;

@end

#endif // QTSHARINGOSKCUSTOMIZATIONS_H
