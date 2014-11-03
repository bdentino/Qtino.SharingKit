#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QtSharingActivityViewController;

@protocol QtSharingActivityViewControllerDelegate <NSObject>

- (NSArray*) activityViewController: (UIActivityViewController*) activityViewController itemsForActivityType: (NSString*) activityType;
- (NSArray*) activityViewControllerPlaceholderItems: (UIActivityViewController*) activityViewController;
- (NSString*) activityViewController: (UIActivityViewController*) activityViewController subjectForActivityType: (NSString*) activityType;
- (void) sharingFinished;
@end
