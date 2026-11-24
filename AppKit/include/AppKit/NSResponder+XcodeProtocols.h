#import <AppKit/NSResponder.h>
#import <AppKit/NSAppearance.h>
#import <AppKit/NSAnimation.h>

@protocol NSValidatedUserInterfaceItem;

@interface NSResponder (XcodeProtocols)

- (NSAppearance *) appearance;
- (void) setAppearance: (NSAppearance *) appearance;
- (NSAppearance *) effectiveAppearance;

- (NSTouchBar *) touchBar;
- (void) setTouchBar: (NSTouchBar *) touchBar;

- (BOOL) validateUserInterfaceItem: (id<NSValidatedUserInterfaceItem>) item;

- (instancetype) animator;
- (NSDictionary<NSString *, id> *) animations;
- (void) setAnimations: (NSDictionary<NSString *, id> *) animations;
- (id) animationForKey: (NSString *) key;
+ (id) defaultAnimationForKey: (NSString *) key;

@end
