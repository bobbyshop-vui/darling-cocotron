#import "CATransactionGroup.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSNumber.h>
#import <Foundation/NSString.h>
#include <dispatch/dispatch.h>
#import <QuartzCore/CALayerContext.h>
#import <QuartzCore/CATransaction.h>

NSString *const kCATransactionAnimationDuration =
        @"kCATransactionAnimationDuration";
NSString *const kCATransactionDisableActions = @"kCATransactionDisableActions";
NSString *const kCATransactionAnimationTimingFunction =
        @"kCATransactionAnimationTimingFunction";
NSString *const kCATransactionCompletionBlock =
        @"kCATransactionCompletionBlock";

@implementation CATransaction

static NSMutableArray *transactionStack() {
    NSMutableDictionary *shared = [NSCurrentThread() sharedDictionary];
    id stack = [shared objectForKey: @"CATransactionStack"];

    if (stack == nil) {
        stack = [NSMutableArray array];
        [shared setObject: stack forKey: @"CATransactionStack"];
    }

    return stack;
}

static CATransactionGroup *currentTransactionGroup() {
    id stack = transactionStack();

    CATransactionGroup *result = [stack lastObject];

    return result;
}

static CATransactionGroup *createImplicitTransactionGroupIfNeeded() {
    CATransactionGroup *check = currentTransactionGroup();

    if (check == nil) {
        check = [[CATransactionGroup alloc] init];

        [transactionStack() addObject: check];
        [[NSRunLoop currentRunLoop]
                performSelector: @selector(commit)
                         target: [CATransaction class]
                       argument: nil
                          order: 0
                          modes: [NSArray arrayWithObject:
                                                  NSDefaultRunLoopMode]];
    }

    return check;
}

+ (BOOL) disableActions {
    return [[self valueForKey: kCATransactionDisableActions] boolValue];
}

+ (CFTimeInterval) animationDuration {
    return [[self valueForKey: kCATransactionAnimationDuration] doubleValue];
}

+ (CAMediaTimingFunction *) animationTimingFunction {
    return [self valueForKey: kCATransactionAnimationTimingFunction];
}

+ (void (^)(void)) completionBlock {
    return [self valueForKey: kCATransactionCompletionBlock];
}

+ valueForKey: (NSString *) key {
    CATransactionGroup *group = createImplicitTransactionGroupIfNeeded();

    return [group valueForKey: key];
}

+ (void) setAnimationDuration: (CFTimeInterval) value {
    [self setValue: [NSNumber numberWithDouble: value]
            forKey: kCATransactionAnimationDuration];
}

+ (void) setAnimationTimingFunction: (CAMediaTimingFunction *) value {
    [self setValue: value forKey: kCATransactionAnimationTimingFunction];
}

+ (void) setCompletionBlock: (void (^)(void)) block {
    id copy = [block copy];
    [self setValue: copy forKey: kCATransactionCompletionBlock];
    [copy release];
}
+ (void) setDisableActions: (BOOL) value {
    [self setValue: [NSNumber numberWithBool: value]
            forKey: kCATransactionDisableActions];
}

+ (void) setValue: value forKey: (NSString *) key {
    CATransactionGroup *group = createImplicitTransactionGroupIfNeeded();

    [group setValue: value forKey: key];
}

+ (void) begin {
    CATransactionGroup *group = [[CATransactionGroup alloc] init];

    [transactionStack() addObject: group];
}

+ (void) commit {
    NSMutableArray *stack = transactionStack();
    if ([stack count] == 0)
        return;

    CATransactionGroup *group = [[stack lastObject] retain];
    [stack removeLastObject];

    // Darling applies layer changes immediately, so the transaction's
    // animations are done once it commits. As on macOS, the completion block
    // runs later on the main thread, never inside -commit.
    void (^completion)(void) = [group valueForKey: kCATransactionCompletionBlock];
    if (completion != nil) {
        void (^block)(void) = [completion copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
            [block release];
        });
    }
    [group release];
}

+ (void) flush {
}

+ (void) lock {
}

+ (void) unlock {
}

@end
