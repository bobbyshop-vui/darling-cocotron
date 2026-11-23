#import <AppKit/NSWindowTab.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSView.h>
#import <AppKit/NSImage.h>
#import <Foundation/NSAttributedString.h>

@implementation NSWindowTab

@synthesize window = _window;

- (instancetype)init {
    return [self initWithWindow:nil];
}

- (instancetype)initWithWindow:(NSWindow *)window {
    if ((self = [super init])) {
        _window = window;
    }
    return self;
}

- (void)dealloc {
    [_title release];
    [_attributedTitle release];
    [_toolTip release];
    [_image release];
    [_accessoryView release];
    _window = nil;
    [super dealloc];
}

- (NSString *)title {
    if (_title != nil)
        return _title;
    NSString *windowTitle = [_window title];
    return windowTitle != nil ? windowTitle : @"";
}

- (void)setTitle:(NSString *)title {
    if (title == _title)
        return;
    [_title release];
    _title = [title copy];
}

- (NSAttributedString *)attributedTitle {
    return _attributedTitle;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    if (attributedTitle == _attributedTitle)
        return;
    [_attributedTitle release];
    _attributedTitle = [attributedTitle copy];
}

- (NSString *)toolTip {
    if (_toolTip != nil)
        return _toolTip;
    return [self title];
}

- (void)setToolTip:(NSString *)toolTip {
    if (toolTip == _toolTip)
        return;
    [_toolTip release];
    _toolTip = [toolTip copy];
}

- (NSView *)accessoryView {
    return _accessoryView;
}

- (void)setAccessoryView:(NSView *)accessoryView {
    if (accessoryView == _accessoryView)
        return;
    [accessoryView retain];
    [_accessoryView release];
    _accessoryView = accessoryView;
    [_accessoryView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

@end
