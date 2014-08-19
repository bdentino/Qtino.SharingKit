#include "QtSharingOSKCustomizations.h"
#include "OSKActivity.h"

@implementation QtSharingOSKCustomizations {
    FBAppCredentials* fbAppCredentials;
}

-(id)init {
    if ( self = [super init] ) {
        fbAppCredentials = nil;
    }
    return self;
}

- (void) setFacebookCredentials: (FBAppCredentials*) credentials
{
    fbAppCredentials = credentials;
}

- (OSKApplicationCredential*) applicationCredentialForActivityType:
        (NSString*) activityType
{
    OSKApplicationCredential* appCredential = nil;

    if ([activityType isEqualToString:OSKActivityType_iOS_Facebook]) {
        if (fbAppCredentials == nil) return appCredential;
        appCredential = [[OSKApplicationCredential alloc]
                          initWithOvershareApplicationKey: fbAppCredentials->appID().toNSString()
                          applicationSecret:nil
                          appName: fbAppCredentials->appName().toNSString()];
    }

    return appCredential;
}

@end
