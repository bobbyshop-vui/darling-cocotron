/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSAnimation.h>
#import <AppKit/NSRaise.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSValue.h>
#import <objc/runtime.h>

NSString *const NSAnimationProgressMarkNotification =
        @"NSAnimationProgressMarkNotification";

NSString *NSAnimationTriggerOrderIn = @"NSAnimationTriggerOrderIn";
NSString *NSAnimationTriggerOrderOut = @"NSAnimationTriggerOrderOut";

NSString *NSAnimationRunLoopMode = @"NSAnimationRunLoopMode";

static char _startAnimationObservationContext;
static char _stopAnimationObservationContext;
static char _startAnimationInfoKey;
static char _stopAnimationInfoKey;

@implementation NSAnimation

- initWithDuration: (NSTimeInterval) duration
        animationCurve: (NSAnimationCurve) curve
{
    _duration = duration;
    _curve = curve;
    _frameRate = 10;
    _blockingMode = NSAnimationBlocking;
    _delegate = nil;
    _progressMarks = [NSMutableArray new];
    _currentValue = 0;
    _runLoopModes = nil; // nil== default, modal and event tracking
    return self;
}

- initWithCoder: (NSCoder *) coder {
    NSTimeInterval duration = 0.5;
    NSAnimationCurve curve = NSAnimationEaseInOut;

    if ([coder allowsKeyedCoding]) {
        if ([coder containsValueForKey: @"NSDuration"])
            duration = [coder decodeDoubleForKey: @"NSDuration"];
        if ([coder containsValueForKey: @"NSAnimationCurve"])
            curve = (NSAnimationCurve)[coder
                    decodeIntegerForKey: @"NSAnimationCurve"];
    }

    self = [self initWithDuration: duration animationCurve: curve];
    if (self == nil)
        return nil;

    if ([coder allowsKeyedCoding]) {
        if ([coder containsValueForKey: @"NSFrameRate"])
            _frameRate = [coder decodeFloatForKey: @"NSFrameRate"];
        if ([coder containsValueForKey: @"NSAnimationBlockingMode"])
            _blockingMode = (NSAnimationBlockingMode)[coder
                    decodeIntegerForKey: @"NSAnimationBlockingMode"];
        if ([coder containsValueForKey: @"NSProgressMarks"]) {
            NSArray *marks = [coder decodeObjectForKey: @"NSProgressMarks"];
            if (marks != nil) {
                [_progressMarks release];
                _progressMarks = [marks mutableCopy];
            }
        }
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeDouble: _duration forKey: @"NSDuration"];
        [coder encodeInteger: _curve forKey: @"NSAnimationCurve"];
        [coder encodeFloat: _frameRate forKey: @"NSFrameRate"];
        [coder encodeInteger: _blockingMode forKey: @"NSAnimationBlockingMode"];
        [coder encodeObject: _progressMarks forKey: @"NSProgressMarks"];
    }
}

- (void) dealloc {
    [self clearStartAnimation];
    [self clearStopAnimation];
    [_progressMarks release];
    [_runLoopModes release];
    [super dealloc];
}

- copyWithZone: (NSZone *) zone {
    NSAnimation *result = NSCopyObject(self, 0, zone);

    result->_currentValue = 0;
    result->_currentProgress = 0;
    result->_progressMarks = [_progressMarks mutableCopy];
    result->_runLoopModes = [_runLoopModes copy];
    result->_isAnimating = NO;
    result->_timer = nil;

    return result;
}

- (NSTimeInterval) duration {
    return _duration;
}

- (NSAnimationCurve) animationCurve {
    return _curve;
}

- (float) frameRate {
    return _frameRate;
}

- (NSAnimationBlockingMode) animationBlockingMode {
    return _blockingMode;
}

- delegate {
    return _delegate;
}

- (NSArray *) progressMarks {
    return _progressMarks;
}

- (void) setDuration: (NSTimeInterval) interval {
    _duration = interval;
}

- (void) setAnimationCurve: (NSAnimationCurve) curve {
    _curve = curve;
}

- (void) setFrameRate: (float) fps {
    _frameRate = fps;
}

- (void) setAnimationBlockingMode: (NSAnimationBlockingMode) mode {
    _blockingMode = mode;
}

- (void) setDelegate: delegate {
    _delegate = delegate;
}

- (void) setProgressMarks: (NSArray *) marks {
    NSMutableArray *mcopy = [marks mutableCopy];
    [_progressMarks release];
    _progressMarks = mcopy;
}

- (void) addProgressMark: (NSAnimationProgress) mark {
    if (mark < 0)
        mark = 0;
    else if (mark > 1)
        mark = 1;

    [_progressMarks addObject: [NSNumber numberWithFloat: mark]];
}

- (void) removeProgressMark: (NSAnimationProgress) mark {
    if (mark < 0)
        mark = 0;
    else if (mark > 1)
        mark = 1;

    NSNumber *progressMark = [NSNumber numberWithFloat: mark];
    NSUInteger index = [_progressMarks indexOfObject: progressMark];
    if (index != NSNotFound)
        [_progressMarks removeObjectAtIndex: index];
}

- (NSAnimationProgress) currentProgress {
    return _currentProgress;
}

- (float) currentValue {
    return _currentValue;
}

- (BOOL) isAnimating {
    return _isAnimating;
}

- (NSArray *) runLoopModesForAnimating {
    return _runLoopModes;
}

- (void) setCurrentProgress: (NSAnimationProgress) progress {
    _currentProgress = progress;
}

- (void) clearStartAnimation {
    NSDictionary *info = objc_getAssociatedObject(self, &_startAnimationInfoKey);
    NSAnimation *animation = [info objectForKey: @"animation"];
    if (animation != nil) {
        [animation removeObserver: self
                       forKeyPath: @"currentProgress"
                          context: &_startAnimationObservationContext];
        objc_setAssociatedObject(self, &_startAnimationInfoKey, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void) clearStopAnimation {
    NSDictionary *info = objc_getAssociatedObject(self, &_stopAnimationInfoKey);
    NSAnimation *animation = [info objectForKey: @"animation"];
    if (animation != nil) {
        [animation removeObserver: self
                       forKeyPath: @"currentProgress"
                          context: &_stopAnimationObservationContext];
        objc_setAssociatedObject(self, &_stopAnimationInfoKey, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    NSDictionary *startInfo = objc_getAssociatedObject(self, &_startAnimationInfoKey);
    NSAnimation *startAnimation = [startInfo objectForKey: @"animation"];
    NSAnimationProgress startProgress =
            [[startInfo objectForKey: @"progress"] floatValue];
    if (context == &_startAnimationObservationContext &&
        object == startAnimation &&
        [object currentProgress] >= startProgress) {
        [self clearStartAnimation];
        [self startAnimation];
        return;
    }

    NSDictionary *stopInfo = objc_getAssociatedObject(self, &_stopAnimationInfoKey);
    NSAnimation *stopAnimation = [stopInfo objectForKey: @"animation"];
    NSAnimationProgress stopProgress =
            [[stopInfo objectForKey: @"progress"] floatValue];
    if (context == &_stopAnimationObservationContext &&
        object == stopAnimation &&
        [object currentProgress] >= stopProgress) {
        [self clearStopAnimation];
        [self stopAnimation];
        return;
    }

    [super observeValueForKeyPath: keyPath
                         ofObject: object
                           change: change
                          context: context];
}

- (void) _setCurrentProgressAndEndIfNeeded: (NSAnimationProgress) progress {
    if (_isAnimating) {
        progress = MAX(0.0, MIN(1.0, progress));
        [self setCurrentProgress: progress];

        if (progress >= 1.0) {
            if ([_delegate respondsToSelector: @selector(animationDidEnd:)])
                [_delegate performSelector: @selector(animationDidEnd:)
                                withObject: self];

            [self stopAnimation];
        }
    }
}

- (void) timer: (NSTimer *) timer {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsedTime = currentTime - _startTime;
    CGFloat progress = elapsedTime / _duration;

    [self _setCurrentProgressAndEndIfNeeded: progress];
}

- (void) startAnimation {
    if (!_isAnimating) {

        if ([_delegate respondsToSelector: @selector(animationShouldStart:)])
            if (![_delegate animationShouldStart: self])
                return;

        [self retain];
        _isAnimating = YES;
        _startTime = [NSDate timeIntervalSinceReferenceDate];

        switch (_blockingMode) {

        case NSAnimationBlocking:
            _timer = [NSTimer timerWithTimeInterval: 1.0 / _frameRate
                                             target: self
                                           selector: @selector(timer:)
                                           userInfo: nil
                                            repeats: YES];

            [[NSRunLoop currentRunLoop] addTimer: _timer
                                         forMode: NSAnimationRunLoopMode];

            while (_isAnimating)
                [[NSRunLoop currentRunLoop]
                           runMode: NSAnimationRunLoopMode
                        beforeDate: [NSDate dateWithTimeIntervalSinceNow:
                                                    _duration]];

            [self _setCurrentProgressAndEndIfNeeded: 1.0];
            break;

        case NSAnimationNonblocking:
            _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / _frameRate
                                                      target: self
                                                    selector: @selector(timer:)
                                                    userInfo: nil
                                                     repeats: YES];
            break;

        case NSAnimationNonblockingThreaded:
            [NSThread detachNewThreadSelector: @selector(_runThreadedAnimation)
                                     toTarget: self
                                   withObject: nil];
            break;
        }
    }
}

- (void) _runThreadedAnimation {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    _timer = [NSTimer timerWithTimeInterval: 1.0 / _frameRate
                                     target: self
                                   selector: @selector(timer:)
                                   userInfo: nil
                                    repeats: YES];
    [runLoop addTimer: _timer forMode: NSAnimationRunLoopMode];

    while (_isAnimating)
        [runLoop runMode: NSAnimationRunLoopMode
              beforeDate: [NSDate dateWithTimeIntervalSinceNow: _duration]];

    [pool drain];
}

- (void) stopAnimation {
    if (_isAnimating) {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        [self autorelease];
    }
}

- (void) startWhenAnimation: (NSAnimation *) animation
            reachesProgress: (NSAnimationProgress) progress
{
    [self clearStartAnimation];
    if (animation == nil)
        return;
    if (progress < 0)
        progress = 0;
    else if (progress > 1)
        progress = 1;

    if ([animation currentProgress] >= progress) {
        [self startAnimation];
        return;
    }

    NSDictionary *info = [NSDictionary
            dictionaryWithObjectsAndKeys: animation, @"animation",
                                         [NSNumber numberWithFloat: progress],
                                         @"progress", nil];
    objc_setAssociatedObject(self, &_startAnimationInfoKey, info,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [animation addObserver: self
                forKeyPath: @"currentProgress"
                   options: 0
                   context: &_startAnimationObservationContext];
}

- (void) stopWhenAnimation: (NSAnimation *) animation
           reachesProgress: (NSAnimationProgress) progress
{
    [self clearStopAnimation];
    if (animation == nil)
        return;
    if (progress < 0)
        progress = 0;
    else if (progress > 1)
        progress = 1;

    if ([animation currentProgress] >= progress) {
        [self stopAnimation];
        return;
    }

    NSDictionary *info = [NSDictionary
            dictionaryWithObjectsAndKeys: animation, @"animation",
                                         [NSNumber numberWithFloat: progress],
                                         @"progress", nil];
    objc_setAssociatedObject(self, &_stopAnimationInfoKey, info,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [animation addObserver: self
                forKeyPath: @"currentProgress"
                   options: 0
                   context: &_stopAnimationObservationContext];
}

@end
