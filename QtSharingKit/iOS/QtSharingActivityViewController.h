#import <UIKit/UIKit.h>

#import "QtSharingActivityViewControllerDelegate.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface QtSharingActivityViewController : UIActivityViewController <UIActivityItemSource>

@property (nonatomic, assign) id <QtSharingActivityViewControllerDelegate> delegate;
@property (nonatomic, copy) id placeholderItem;

- (id)initWithDelegate:(id <QtSharingActivityViewControllerDelegate>)delegate;
- (id)initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems;
- (id)initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems applicationActivities:(NSArray *)applicationActivities;

@end
