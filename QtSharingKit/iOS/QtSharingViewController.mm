#include "QtSharingViewController.h"
#include "OSKShareableContent.h"
#include "OSKPresentationManager.h"
#include "UIDevice+OSKHardware.h"

@implementation QtSharingViewController

- (void)showShareSheet_Phone:(OSKShareableContent *)content {

    // 2) Setup optional completion and dismissal handlers
    //OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    //OSKPresentationEndingHandler dismissalHandler = [self dismissalHandler];

    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{};

    // 4) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                                    options:options];
}

@end
