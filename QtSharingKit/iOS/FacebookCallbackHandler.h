#ifndef FACEBOOKCALLBACKHANDLER_H
#define FACEBOOKCALLBACKHANDLER_H

#include "UIKit/UIKit.h"

@interface NSObject (QtSharingKitPlugin)

+ (void) load;

- (BOOL) qtSharingKitApplication: (UIApplication*) application
         openURL: (NSURL*) url
         sourceApplication: (NSString*) sourceApplication
         annotation: (id) annotation;

@end

#endif // FACEBOOKCALLBACKHANDLER_H
