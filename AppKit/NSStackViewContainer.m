#import <AppKit/NSView.h>

// Private view class that NSStackView archives for each gravity area; the keys it adds
// (NSStackViewContainer*) only describe the owning stack view and are not needed to lay out
// the subviews it holds.
@interface NSStackViewContainer : NSView
@end

@implementation NSStackViewContainer
@end
