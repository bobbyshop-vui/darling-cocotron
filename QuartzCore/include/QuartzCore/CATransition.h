#import <QuartzCore/CAAnimation.h>

@interface CATransition : CAAnimation {
    NSString *_type;
    NSString *_subtype;
    float _startProgress;
    float _endProgress;
    id _filter;
}

@property(copy) NSString *type;
@property(copy) NSString *subtype;
// float, as in Apple's SDK (callers pass a float).
@property float startProgress;
@property float endProgress;
@property(retain) id filter;

@end
