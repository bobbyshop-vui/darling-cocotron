#import <AppKit/NSViewController.h>
#import <Foundation/Foundation.h>

@interface NSTitlebarAccessoryViewController : NSViewController {
    NSInteger _tavcLayoutAttribute;
    CGFloat _tavcFullScreenMinHeight;
    BOOL _tavcHidden;
}

- (NSInteger) layoutAttribute;
- (void) setLayoutAttribute: (NSInteger) layoutAttribute;
- (CGFloat) fullScreenMinHeight;
- (void) setFullScreenMinHeight: (CGFloat) height;
- (BOOL) isHidden;
- (void) setHidden: (BOOL) hidden;
- (void) viewWillAppear;
- (void) viewDidAppear;
- (void) viewDidDisappear;

@end
