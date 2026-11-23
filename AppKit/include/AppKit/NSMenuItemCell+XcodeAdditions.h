#import <AppKit/NSMenuItemCell.h>

@class NSMenuView;

@interface NSMenuItemCell (XcodeAdditions)
- (NSMenuView *) menuView;
- (void) calcSize;
- (BOOL) needsDisplay;
- (void) setNeedsDisplay: (BOOL) flag;
- (CGFloat) imageWidth;
- (CGFloat) titleWidth;
- (NSRect) stateImageRectForBounds: (NSRect) cellFrame;
- (NSRect) keyEquivalentRectForBounds: (NSRect) cellFrame;
- (void) drawBorderAndBackgroundWithFrame: (NSRect) cellFrame
                                   inView: (NSView *) controlView;
- (void) drawImageWithFrame: (NSRect) cellFrame inView: (NSView *) controlView;
@end
