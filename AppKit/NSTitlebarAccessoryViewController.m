#import <AppKit/NSTitlebarAccessoryViewController.h>

@implementation NSTitlebarAccessoryViewController

- (NSInteger) layoutAttribute {
    return _tavcLayoutAttribute;
}

- (void) setLayoutAttribute: (NSInteger) layoutAttribute {
    _tavcLayoutAttribute = layoutAttribute;
}

- (CGFloat) fullScreenMinHeight {
    return _tavcFullScreenMinHeight;
}

- (void) setFullScreenMinHeight: (CGFloat) height {
    _tavcFullScreenMinHeight = height;
}

- (BOOL) isHidden {
    return _tavcHidden;
}

- (void) setHidden: (BOOL) hidden {
    _tavcHidden = hidden;
}

- (void) viewWillAppear {
}

- (void) viewDidAppear {
}

- (void) viewDidDisappear {
}

@end
