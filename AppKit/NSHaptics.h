#import <Foundation/Foundation.h>
#import <AppKit/NSEvent.h>

@class NSView;

typedef NS_ENUM(NSInteger, NSHapticFeedbackPattern) {
    NSHapticFeedbackPatternGeneric = 0,
    NSHapticFeedbackPatternAlignment,
    NSHapticFeedbackPatternLevelChange
};

typedef NS_ENUM(NSUInteger, NSHapticFeedbackPerformanceTime) {
    NSHapticFeedbackPerformanceTimeDefault = 0,
    NSHapticFeedbackPerformanceTimeNow,
    NSHapticFeedbackPerformanceTimeDrawCompleted,
};

@protocol NSHapticFeedbackPerformer <NSObject>
@required
- (void) performFeedbackPattern: (NSHapticFeedbackPattern) pattern
                performanceTime: (NSHapticFeedbackPerformanceTime) performanceTime;
@end

@protocol NSAlignmentFeedbackToken <NSObject>
@end

@interface NSHapticFeedbackManager : NSObject
+ (id<NSHapticFeedbackPerformer>) defaultPerformer;
@end

@interface NSAlignmentFeedbackFilter : NSObject {
    NSEvent *_lastEvent;
}
- (void) updateWithEvent: (NSEvent *) event;
- (id<NSAlignmentFeedbackToken>)
        alignmentFeedbackTokenForHorizontalMovementInView: (NSView *) view
                                                previousX: (CGFloat) previousX
                                                 alignedX: (CGFloat) alignedX
                                                 defaultX: (CGFloat) defaultX;
- (id<NSAlignmentFeedbackToken>)
        alignmentFeedbackTokenForVerticalMovementInView: (NSView *) view
                                              previousY: (CGFloat) previousY
                                               alignedY: (CGFloat) alignedY
                                               defaultY: (CGFloat) defaultY;
- (void) performFeedback: (NSArray *) alignmentFeedbackTokens
         performanceTime: (NSHapticFeedbackPerformanceTime) performanceTime;
@end
