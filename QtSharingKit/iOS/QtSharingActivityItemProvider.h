#ifndef QTSHARINGACTIVITYITEMPROVIDER_H
#define QTSHARINGACTIVITYITEMPROVIDER_H

#import <UIKit/UIKit.h>
#include <QHash>
#include "DefaultContent.h"
#include "QtSharingActivityViewControllerDelegate.h"
#include "QtSharingKitApi.h"

@interface QtSharingActivityItemProvider : NSObject <QtSharingActivityViewControllerDelegate>

+ (void) load;

- (id) initWithContent: (QHash<QString, DefaultContent*>) content api: (QtSharingKitApi*) api;

- (NSArray*) activityViewController: (UIActivityViewController*) activityViewController
             itemsForActivityType: (NSString*) activityType;
- (NSArray*) activityViewControllerPlaceholderItems: (UIActivityViewController*) activityViewController;
- (NSString*) activityViewController: (UIActivityViewController*) activityViewController
              subjectForActivityType: (NSString*) activityType;

- (void) sharingFinished;

@end

#endif // QTSHARINGACTIVITYITEMPROVIDER_H
