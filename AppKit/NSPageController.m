#import <AppKit/NSPageController.h>
#import <AppKit/NSView.h>

@implementation NSPageController

- (id) initWithNibName: (NSString *) name bundle: (NSBundle *) bundle
{
    if ((self = [super initWithNibName: name bundle: bundle]) != nil) {
        _transitionStyle = NSPageControllerTransitionStyleStackHistory;
        _arrangedObjects = [[NSArray alloc] init];
    }
    return self;
}

- (id) initWithCoder: (NSCoder *) coder
{
    if ((self = [super initWithCoder: coder]) != nil) {
        _transitionStyle = NSPageControllerTransitionStyleStackHistory;
        _arrangedObjects = [[NSArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_selectedViewController release];
    [_arrangedObjects release];
    [super dealloc];
}

- (id<NSPageControllerDelegate>) delegate
{
    return _delegate;
}

- (void) setDelegate: (id<NSPageControllerDelegate>) delegate
{
    _delegate = delegate;
}

- (NSViewController *) selectedViewController
{
    return _selectedViewController;
}

- (NSPageControllerTransitionStyle) transitionStyle
{
    return _transitionStyle;
}

- (void) setTransitionStyle: (NSPageControllerTransitionStyle) style
{
    _transitionStyle = style;
}

- (NSArray *) arrangedObjects
{
    return _arrangedObjects;
}

- (void) _updateSelectedViewController
{
    NSViewController *controller = nil;
    id object = nil;

    if (_selectedIndex >= 0 && _selectedIndex < (NSInteger) [_arrangedObjects count])
        object = [_arrangedObjects objectAtIndex: _selectedIndex];

    if (object != nil &&
        [(id) _delegate respondsToSelector: @selector(pageController:identifierForObject:)] &&
        [(id) _delegate respondsToSelector: @selector(pageController:viewControllerForIdentifier:)]) {
        NSString *identifier = [_delegate pageController: self
                                     identifierForObject: object];
        controller = [_delegate pageController: self
                   viewControllerForIdentifier: identifier];

        if ([(id) _delegate respondsToSelector: @selector(pageController:prepareViewController:withObject:)])
            [_delegate pageController: self
                prepareViewController: controller
                           withObject: object];
        else
            [controller setRepresentedObject: object];
    }

    if (controller != _selectedViewController) {
        [_selectedViewController release];
        _selectedViewController = [controller retain];
    }
}

- (void) setArrangedObjects: (NSArray *) objects
{
    NSArray *copy = objects != nil ? [objects copy] : [[NSArray alloc] init];

    [self willChangeValueForKey: @"arrangedObjects"];
    [_arrangedObjects release];
    _arrangedObjects = copy;
    if (_selectedIndex >= (NSInteger) [_arrangedObjects count])
        _selectedIndex = [_arrangedObjects count] > 0 ? [_arrangedObjects count] - 1 : 0;
    [self _updateSelectedViewController];
    [self didChangeValueForKey: @"arrangedObjects"];
}

- (NSInteger) selectedIndex
{
    return _selectedIndex;
}

- (void) setSelectedIndex: (NSInteger) index
{
    [self willChangeValueForKey: @"selectedIndex"];
    _selectedIndex = index;
    [self _updateSelectedViewController];
    [self didChangeValueForKey: @"selectedIndex"];
}

- (void) completeTransition
{
    NSView *content = [self view];
    NSView *selectedView = [_selectedViewController view];

    if (content == nil || selectedView == nil)
        return;

    for (NSView *subview in [[[content subviews] copy] autorelease]) {
        if (subview != selectedView)
            [subview removeFromSuperview];
    }
    if ([selectedView superview] != content) {
        [selectedView setFrame: [content bounds]];
        [content addSubview: selectedView];
    }
    [content setNeedsDisplay: YES];
}

@end
