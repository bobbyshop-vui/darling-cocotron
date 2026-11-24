#import <AppKit/NSResponder+XcodeProtocols.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSUserInterfaceValidation.h>
#import <objc/runtime.h>

static char NSResponderXcodeAppearanceKey;
static char NSResponderXcodeTouchBarKey;
static char NSResponderXcodeAnimationsKey;

static NSAppearance *NSResponderXcodeExplicitAppearance(id object) {
    if (object == nil || ![object respondsToSelector: @selector(appearance)]) {
        return nil;
    }

    return [object appearance];
}

static NSAppearance *NSResponderXcodeInheritedAppearance(id object) {
    if (object == nil) {
        return nil;
    }

    NSAppearance *appearance = NSResponderXcodeExplicitAppearance(object);
    if (appearance != nil) {
        return appearance;
    }

    if ([object respondsToSelector: @selector(superview)]) {
        id superview = [object performSelector: @selector(superview)];
        if (superview != nil && superview != object) {
            appearance = NSResponderXcodeInheritedAppearance(superview);
            if (appearance != nil) {
                return appearance;
            }
        }
    }

    if ([object respondsToSelector: @selector(window)]) {
        id window = [object performSelector: @selector(window)];
        if (window != nil && window != object) {
            appearance = NSResponderXcodeInheritedAppearance(window);
            if (appearance != nil) {
                return appearance;
            }
        }
    }

    id application = NSApp;
    if (application != nil && application != object) {
        appearance = NSResponderXcodeExplicitAppearance(application);
        if (appearance == nil &&
            [application respondsToSelector: @selector(effectiveAppearance)]) {
            appearance = [application effectiveAppearance];
        }
        if (appearance != nil) {
            return appearance;
        }
    }

    appearance = [NSAppearance currentAppearance];
    if (appearance != nil) {
        return appearance;
    }

    return [NSAppearance appearanceNamed: NSAppearanceNameAqua];
}

@implementation NSResponder (XcodeProtocols)

- (NSAppearance *) appearance {
    return objc_getAssociatedObject(self, &NSResponderXcodeAppearanceKey);
}

- (void) setAppearance: (NSAppearance *) appearance {
    objc_setAssociatedObject(self, &NSResponderXcodeAppearanceKey, appearance,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSAppearance *) effectiveAppearance {
    return NSResponderXcodeInheritedAppearance(self);
}

- (NSTouchBar *) touchBar {
    NSTouchBar *touchBar = objc_getAssociatedObject(self, &NSResponderXcodeTouchBarKey);
    if (touchBar == nil) {
        touchBar = [self makeTouchBar];
        if (touchBar != nil) {
            objc_setAssociatedObject(self, &NSResponderXcodeTouchBarKey, touchBar,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }

    return touchBar;
}

- (void) setTouchBar: (NSTouchBar *) touchBar {
    objc_setAssociatedObject(self, &NSResponderXcodeTouchBarKey, touchBar,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) validateUserInterfaceItem: (id<NSValidatedUserInterfaceItem>) item {
    if (item == nil) {
        return NO;
    }

    SEL action = [item action];
    return action != NULL && [self respondsToSelector: action];
}

- (instancetype) animator {
    return self;
}

- (NSDictionary<NSString *, id> *) animations {
    return objc_getAssociatedObject(self, &NSResponderXcodeAnimationsKey);
}

- (void) setAnimations: (NSDictionary<NSString *, id> *) animations {
    objc_setAssociatedObject(self, &NSResponderXcodeAnimationsKey, animations,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id) animationForKey: (NSString *) key {
    id animation = [[self animations] objectForKey: key];
    if (animation != nil) {
        return animation;
    }

    return [[self class] defaultAnimationForKey: key];
}

+ (id) defaultAnimationForKey: (NSString *) key {
    return nil;
}

@end
