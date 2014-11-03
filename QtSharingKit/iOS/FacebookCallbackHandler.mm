#include "UIKit/UIKit.h"

#include "FacebookCallbackHandler.h"
#include "FBAppCall.h"
#import "QtSharingSwizzle.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (QtSharingKitPlugin)

+ (void) load
{
    //TODO: Need to verify that this is "safe." Is this class guaranteed to be loaded?
    //      Also, what happens if the app isn't using Qt's default app delegate?
    //      (Not a likely scenario, but should try to have some fallback check after app
    //      finishes launching to check the class of the delegate)
    NSLog(@"Swizzling!");
    Class appDelegateClass = objc_getClass("QIOSApplicationDelegate");
    if (appDelegateClass != nil)
    {
        NSError* error = nil;
        [appDelegateClass
                qtsharing_swizzleMethod:@selector(application:openURL:sourceApplication:annotation:)
                withMethod:@selector(qtSharingKitApplication:openURL:sourceApplication:annotation:)
                error: &error ];
        if (error)
            NSLog(@"[WARN] Cannot swizzle application:openURL:sourceApplication:annotation: - %@", error);
    }
    else
    {
        NSLog(@"[WARN] Cannot swizzle application:openURL:sourceApplication:annotation: - App Delegate Class not found!");
    }
}

- (BOOL) qtSharingKitApplication: (UIApplication*) application
         openURL: (NSURL*) url
         sourceApplication: (NSString*) sourceApplication
         annotation: (id) annotation
{
    NSLog(@"Handling OpenURL");
    BOOL rval = [self qtSharingKitApplication: application
                      openURL: url
                      sourceApplication: sourceApplication
                      annotation: annotation];

    BOOL fbHandled = [FBAppCall handleOpenURL: url sourceApplication: sourceApplication];

    return rval && fbHandled;
}

@end
