/* Copyright (c) 2007 Christopher J. W. Lloyd

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE. */

#import "NSAnimationContext.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSThread.h>

static NSString *const NSAnimationContextStackKey =
        @"NSAnimationContextStack";

@implementation NSAnimationContext

- init {
    if ((self = [super init]) != nil) {
        _duration = 0.25;
    }
    return self;
}

- (void) dealloc {
    [_timingFunction release];
    [_completionHandler release];
    [super dealloc];
}

- (id) copyWithZone: (NSZone *) zone {
    NSAnimationContext *copy = [[[self class] allocWithZone: zone] init];

    copy->_duration = _duration;
    copy->_timingFunction = [_timingFunction retain];
    copy->_allowsImplicitAnimation = _allowsImplicitAnimation;
    // the completion handler belongs to the grouping, it is not inherited
    return copy;
}

// The per-thread stack of active groupings; the bottom entry is the implicit
// context that is current outside any grouping.
+ (NSMutableArray *) _contextStack {
    NSMutableDictionary *threadDictionary =
            [[NSThread currentThread] threadDictionary];
    NSMutableArray *stack =
            [threadDictionary objectForKey: NSAnimationContextStackKey];

    if (stack == nil) {
        NSAnimationContext *root = [[[NSAnimationContext alloc] init] autorelease];

        stack = [NSMutableArray arrayWithObject: root];
        [threadDictionary setObject: stack forKey: NSAnimationContextStackKey];
    }
    return stack;
}

+ (void) beginGrouping {
    NSMutableArray *stack = [self _contextStack];
    NSAnimationContext *context = [[[stack lastObject] copy] autorelease];

    [stack addObject: context];
}

+ (void) endGrouping {
    NSMutableArray *stack = [self _contextStack];

    if ([stack count] <= 1)
        return; // unbalanced, the root context is never popped

    NSAnimationContext *context = [[[stack lastObject] retain] autorelease];

    [stack removeLastObject];

    void (^handler)(void) = context->_completionHandler;

    if (handler != nil) {
        // Without a Core Animation transaction to wait for, the changes have
        // been applied by now.
        handler();
    }
}

+ (void) runAnimationGroup: (void (^)(NSAnimationContext *context)) changes
         completionHandler: (void (^)(void)) completionHandler
{
    [self beginGrouping];

    NSAnimationContext *context = [self currentContext];

    [context setCompletionHandler: completionHandler];
    if (changes != nil)
        changes(context);

    [self endGrouping];
}

+ (void) runAnimationGroup: (void (^)(NSAnimationContext *context)) changes {
    [self runAnimationGroup: changes completionHandler: nil];
}

+ (NSAnimationContext *) currentContext {
    return [[self _contextStack] lastObject];
}

- (void) setDuration: (NSTimeInterval) duration {
    _duration = duration;
}

- (NSTimeInterval) duration {
    return _duration;
}

- (void) setTimingFunction: (CAMediaTimingFunction *) timingFunction {
    if (timingFunction != _timingFunction) {
        [_timingFunction release];
        _timingFunction = [timingFunction retain];
    }
}

- (CAMediaTimingFunction *) timingFunction {
    return _timingFunction;
}

- (void) setCompletionHandler: (void (^)(void)) handler {
    if (handler != _completionHandler) {
        [_completionHandler release];
        _completionHandler = [handler copy];
    }
}

- (void (^)(void)) completionHandler {
    return _completionHandler;
}

- (BOOL) allowsImplicitAnimation {
    return _allowsImplicitAnimation;
}

- (void) setAllowsImplicitAnimation: (BOOL) flag {
    _allowsImplicitAnimation = flag;
}

@end
