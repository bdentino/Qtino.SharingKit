#ifndef SHARESHEETMANAGER_H
#define SHARESHEETMANAGER_H

#include <UIKit/UIKit.h>

@class OSKShareableContent;

@interface QtSharingViewController : UIViewController

- (void)showShareSheet_Phone:(OSKShareableContent*) content;

@end

#endif // SHARESHEETMANAGER_H
