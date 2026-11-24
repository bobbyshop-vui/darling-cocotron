#import <AppKit/NSAnimation.h>
#import <AppKit/NSDocument.h>
#import <AppKit/NSDocumentController.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSOpenGLContext.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSUserInterfaceItemIdentification.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSSplitViewItem.h>
#import <Foundation/NSExtensionContext.h>
#import <Foundation/NSLock.h>
#import <objc/runtime.h>

static char NSDocumentPresentedItemOperationQueueKey;
static char NSTextContainerLayoutOrientationKey;
static char NSScrollViewFindBarViewKey;
static char NSOpenGLContextLockKey;
static char NSAnimatablePropertyContainerAnimationsKey;

@implementation NSDocument (XcodeProtocolsMisc)

- (NSURL *)presentedItemURL {
    return [self fileURL];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    NSOperationQueue *queue = nil;
    @synchronized(self) {
        queue = objc_getAssociatedObject(self,
                                         &NSDocumentPresentedItemOperationQueueKey);
        if (queue == nil) {
            queue = [[NSOperationQueue alloc] init];
            [queue setMaxConcurrentOperationCount:1];
            objc_setAssociatedObject(self,
                                     &NSDocumentPresentedItemOperationQueueKey,
                                     queue,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [queue release];
            queue = objc_getAssociatedObject(self,
                                             &NSDocumentPresentedItemOperationQueueKey);
        }
    }
    return queue;
}

@end

@implementation NSDocumentController (XcodeProtocolsMiscWindowRestoration)

+ (void)restoreWindowWithIdentifier:(NSUserInterfaceItemIdentifier)identifier
                              state:(NSCoder *)state
                  completionHandler:(void (^)(NSWindow *window,
                                               NSError *error))completionHandler {
    (void)identifier;
    (void)state;
    if (completionHandler != nil) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:NSFileNoSuchFileError
                                          userInfo:@{
                                              NSLocalizedDescriptionKey:
                                                  @"The requested window could not be restored."
                                          }];
        completionHandler(nil, error);
    }
}

@end

@implementation NSTextContainer (XcodeProtocolsMisc)

- (NSTextLayoutOrientation)layoutOrientation {
    NSNumber *orientation = objc_getAssociatedObject(
        self, &NSTextContainerLayoutOrientationKey);
    return orientation != nil ? (NSTextLayoutOrientation)[orientation integerValue]
                              : (NSTextLayoutOrientation)0;
}

- (void)setLayoutOrientation:(NSTextLayoutOrientation)orientation {
    objc_setAssociatedObject(self,
                             &NSTextContainerLayoutOrientationKey,
                             [NSNumber numberWithInteger:orientation],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"-[%@ %s] is not implemented for coder %@",
                           [self class], sel_getName(_cmd), coder];
        return;
    }

    NSSize size = [self size];
    [coder encodeFloat:size.width forKey:@"NSWidth"];
    [coder encodeObject:[self textView] forKey:@"NSTextView"];
    [coder encodeObject:[self layoutManager] forKey:@"NSLayoutManager"];
    int flags = ([self widthTracksTextView] ? 1 : 0) |
                ([self heightTracksTextView] ? 2 : 0);
    [coder encodeInt:flags forKey:@"NSTCFlags"];
}

@end

@implementation NSLayoutManager (XcodeProtocolsMisc)

- (NSAttributedString *)attributedString {
    return (NSAttributedString *)[self textStorage];
}

- (NSUInteger)layoutOptions {
    return 0;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"-[%@ %s] is not implemented for coder %@",
                           [self class], sel_getName(_cmd), coder];
        return;
    }

    [coder encodeObject:[self textStorage] forKey:@"NSTextStorage"];
    [coder encodeObject:[self delegate] forKey:@"NSDelegate"];
    [coder encodeObject:[self textContainers] forKey:@"NSTextContainers"];
}

@end

@implementation NSScrollView (XcodeProtocolsMisc)

- (NSView *)findBarView {
    return objc_getAssociatedObject(self, &NSScrollViewFindBarViewKey);
}

- (void)setFindBarView:(NSView *)findBarView {
    objc_setAssociatedObject(self,
                             &NSScrollViewFindBarViewKey,
                             findBarView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

static NSRecursiveLock *NSOpenGLContextLock(NSOpenGLContext *context,
                                             BOOL createIfNeeded) {
    NSRecursiveLock *lock = nil;
    @synchronized(context) {
        lock = objc_getAssociatedObject(context, &NSOpenGLContextLockKey);
        if (lock == nil && createIfNeeded) {
            lock = [[NSRecursiveLock alloc] init];
            objc_setAssociatedObject(context,
                                     &NSOpenGLContextLockKey,
                                     lock,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [lock release];
            lock = objc_getAssociatedObject(context, &NSOpenGLContextLockKey);
        }
    }
    return lock;
}

@interface NSOpenGLContext (XcodeProtocolsMisc) <NSLocking>
@end

@implementation NSOpenGLContext (XcodeProtocolsMisc)

- (void)lock {
    [NSOpenGLContextLock(self, YES) lock];
}

- (void)unlock {
    [NSOpenGLContextLock(self, NO) unlock];
}

@end

@implementation NSMenu (XcodeProtocolsMisc)

- (NSRect)accessibilityFrame {
    return NSZeroRect;
}

- (id)accessibilityParent {
    return nil;
}

@end

@implementation NSViewController (XcodeProtocolsMisc)

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    (void)context;
}

@end

@interface NSSplitViewItem (XcodeProtocolsMisc) <NSAnimatablePropertyContainer>
@end

@implementation NSSplitViewItem (XcodeProtocolsMisc)

- (instancetype)animator {
    return self;
}

- (NSDictionary *)animations {
    return objc_getAssociatedObject(self,
                                    &NSAnimatablePropertyContainerAnimationsKey);
}

- (void)setAnimations:(NSDictionary *)animations {
    objc_setAssociatedObject(self,
                             &NSAnimatablePropertyContainerAnimationsKey,
                             animations,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)animationForKey:(NSString *)key {
    id animation = [objc_getAssociatedObject(
        self, &NSAnimatablePropertyContainerAnimationsKey) objectForKey:key];
    return animation != nil ? animation : [[self class] defaultAnimationForKey:key];
}

+ (id)defaultAnimationForKey:(NSString *)key {
    (void)key;
    return nil;
}

@end

@implementation NSNib (XcodeProtocolsMisc)

- (void)encodeWithCoder:(NSCoder *)coder {
    (void)coder;
}

@end
