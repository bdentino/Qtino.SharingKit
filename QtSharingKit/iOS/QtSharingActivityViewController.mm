#import "QtSharingActivityViewController.h"
#include <QObject>

@interface QtSharingActivityViewController ()
{
    NSMutableDictionary *_itemsMapping;
    int _maximumNumberOfItems;
    NSArray* _placeholders;
    int _currentPlaceholder;
}

@end

@implementation QtSharingActivityViewController

@synthesize delegate = _delegate;

- (id) initWithDelegate:(id<QtSharingActivityViewControllerDelegate>)delegate
{
    return [self initWithDelegate:delegate maximumNumberOfItems:10 applicationActivities:nil];
}

- (id) initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems
{
    return [self initWithDelegate:delegate maximumNumberOfItems:maximumNumberOfItems applicationActivities:nil];
}

- (id) initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems applicationActivities:(NSArray *)applicationActivities
{
    _delegate = delegate;
    _maximumNumberOfItems = maximumNumberOfItems;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    int i;
    
    for (i = 0; i < maximumNumberOfItems; i++) {
        [items addObject:self];
    }
    
    self = [self initWithActivityItems:items applicationActivities:applicationActivities];
    if (self) {
        _itemsMapping = [[NSMutableDictionary alloc] init];
    }
    
    _currentPlaceholder = 0;
    _placeholders = [_delegate activityViewControllerPlaceholderItems: self];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [self setCompletionWithItemsHandler: ^(NSString* activityType, BOOL completed, NSArray* returnedItems, NSError* activityError) {
            NSLog(@"Sharing Finished!");
            [_delegate sharingFinished];
        }];
    }
    else
    {
        [self setCompletionHandler:^(NSString *activityType, BOOL completed) {
            NSLog(@"Sharing Finished!");
            [_delegate sharingFinished];
        }];
    }

    return self;
}

- (id) activityViewController:(UIActivityViewController*) activityViewController itemForActivityType:(NSString*) activityType
{
    // Get the items if not already received
    NSMutableDictionary *activity = [_itemsMapping objectForKey:activityType];
    NSArray *items;
    
    if (!activity) {
        items = [_delegate performSelector:@selector(activityViewController:itemsForActivityType:) withObject:activityViewController withObject:activityType];
        activity = [[NSMutableDictionary alloc] initWithObjectsAndKeys:items, @"items", [NSNumber numberWithInt:0], @"index", nil];
        
        [_itemsMapping setObject:activity forKey:activityType];
    } else {
        items = [activity objectForKey:@"items"];
    }
    
    // Get the item
    unsigned int index = [[activity objectForKey:@"index"] integerValue];
    id item = nil;
    
    if (index < [items count]) {
        item = [items objectAtIndex:index];
    }
    
    // Increase the index, and reset
    index = (index + 1) % _maximumNumberOfItems;
    [activity setObject:[NSNumber numberWithInt:index] forKey:@"index"];
    return item;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController*) activityViewController
{
    int max = [_placeholders count];
    Q_UNUSED(activityViewController);
    if(_placeholders == nil || [_placeholders count] == 0) { return nil; }
    if (_currentPlaceholder >= (int)[_placeholders count]) { return [_placeholders objectAtIndex: max - 1]; }
    return [_placeholders objectAtIndex: _currentPlaceholder++];
}

- (NSString*) activityViewController: (UIActivityViewController*) activityViewController
              subjectForActivityType: (NSString*) activityType
{
    return [_delegate activityViewController: activityViewController subjectForActivityType: activityType];
}

@end
