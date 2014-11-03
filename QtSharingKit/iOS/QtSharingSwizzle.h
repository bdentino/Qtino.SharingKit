#ifndef QTSHARINGSWIZZLE_H
#define QTSHARINGSWIZZLE_H

#include <Foundation/Foundation.h>

@interface NSObject (QtSharingSwizzle)

+ (void) load;

+ (BOOL)qtsharing_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)qtsharing_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_;

@end

#endif // QTSHARINGSWIZZLE_H
