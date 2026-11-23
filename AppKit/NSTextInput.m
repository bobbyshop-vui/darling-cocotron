#include <AppKit/NSTextInput.h>
#include <AppKit/NSTextInput_Internal.h>

NSString *const NSTextInputContextKeyboardSelectionDidChangeNotification = @"NSTextInputContextKeyboardSelectionDidChangeNotification";

NSString *const NSTextInputReplacementRangeAttributeName = @"NSTextInputReplacementRangeAttributeName";

@implementation NSTextInputContext

- (instancetype) initWithClient: (id<NSTextInputClient>) client {
    self = [super init];
    if (self != nil) {
        // The client owns its input context, so do not retain it.
        _darlingClient = client;
    }
    return self;
}

- (void) dealloc {
    [_darlingAllowedInputSourceLocales release];
    [super dealloc];
}

- (id<NSTextInputClient>) client {
    return _darlingClient;
}

- (NSArray *) allowedInputSourceLocales {
    return _darlingAllowedInputSourceLocales;
}

- (void) setAllowedInputSourceLocales: (NSArray *) locales {
    locales = [locales copy];
    [_darlingAllowedInputSourceLocales release];
    _darlingAllowedInputSourceLocales = locales;
}

- (void) activate {
    _darlingActive = YES;
}

- (void) deactivate {
    if (_darlingActive)
        [self discardMarkedText];
    _darlingActive = NO;
}

- (BOOL) handleEvent: (NSEvent *) event {
    // There is no input method server; events are handled by the normal
    // key event path of the client.
    return NO;
}

- (void) discardMarkedText {
    if ([_darlingClient respondsToSelector: @selector(unmarkText)])
        [(id) _darlingClient performSelector: @selector(unmarkText)];
}

@end
