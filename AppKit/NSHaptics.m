#import <AppKit/NSHaptics.h>

// There is no force feedback hardware behind Darling, so performing a pattern
// has no physical effect; the performer exists so callers get a valid object.
@interface _NSNullHapticFeedbackPerformer : NSObject <NSHapticFeedbackPerformer>
@end

@implementation _NSNullHapticFeedbackPerformer

- (void) performFeedbackPattern: (NSHapticFeedbackPattern) pattern
                performanceTime: (NSHapticFeedbackPerformanceTime) performanceTime
{
}

@end

@interface _NSAlignmentFeedbackTokenImpl : NSObject <NSAlignmentFeedbackToken>
@end

@implementation _NSAlignmentFeedbackTokenImpl
@end

@implementation NSHapticFeedbackManager

+ (id<NSHapticFeedbackPerformer>) defaultPerformer {
    static id performer = nil;
    @synchronized(self) {
        if (performer == nil)
            performer = [[_NSNullHapticFeedbackPerformer alloc] init];
    }
    return performer;
}

@end

@implementation NSAlignmentFeedbackFilter

- (void) dealloc {
    [_lastEvent release];
    [super dealloc];
}

- (void) updateWithEvent: (NSEvent *) event {
    if (event == _lastEvent)
        return;
    [_lastEvent release];
    _lastEvent = [event retain];
}

// Feedback is due only when the alignment actually moves the object: the
// aligned location must differ from both the location the user last saw and
// from where the object would be without alignment.
- (id<NSAlignmentFeedbackToken>)
        alignmentFeedbackTokenForHorizontalMovementInView: (NSView *) view
                                                previousX: (CGFloat) previousX
                                                 alignedX: (CGFloat) alignedX
                                                 defaultX: (CGFloat) defaultX
{
    if (alignedX == previousX || alignedX == defaultX)
        return nil;
    return [[[_NSAlignmentFeedbackTokenImpl alloc] init] autorelease];
}

- (id<NSAlignmentFeedbackToken>)
        alignmentFeedbackTokenForVerticalMovementInView: (NSView *) view
                                              previousY: (CGFloat) previousY
                                               alignedY: (CGFloat) alignedY
                                               defaultY: (CGFloat) defaultY
{
    if (alignedY == previousY || alignedY == defaultY)
        return nil;
    return [[[_NSAlignmentFeedbackTokenImpl alloc] init] autorelease];
}

- (void) performFeedback: (NSArray *) alignmentFeedbackTokens
         performanceTime: (NSHapticFeedbackPerformanceTime) performanceTime
{
    if ([alignmentFeedbackTokens count] == 0)
        return;
    [[NSHapticFeedbackManager defaultPerformer]
            performFeedbackPattern: NSHapticFeedbackPatternAlignment
                   performanceTime: performanceTime];
}

@end
