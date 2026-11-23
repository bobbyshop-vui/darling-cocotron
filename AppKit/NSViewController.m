#import <AppKit/NSNib.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSView.h>

// Private hooks used by the container/presentation bookkeeping below.
@interface NSViewController (VCXPrivate)
- (void) _vcxClearParent;
- (void) _vcxClearPresenter;
@end

// The parts of NSPopover that presentation uses; the class is private to
// NSPopover.m so it is looked up by name.
@interface NSObject (VCXPopover)
- (void) setContentViewController: (NSViewController *) controller;
- (void) setBehavior: (NSInteger) behavior;
- (void) showRelativeToRect: (NSRect) rect
                     ofView: (NSView *) view
              preferredEdge: (NSRectEdge) edge;
- (void) close;
@end

@implementation NSViewController

@synthesize identifier = _identifier;

- initWithNibName: (NSString *) name bundle: (NSBundle *) bundle {
    _nibName = [name copy];
    _nibBundle = [bundle retain];
    return self;
}

- initWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        _nibName = [[coder decodeObjectForKey: @"NSNibName"] copy];
        _title = [[coder decodeObjectForKey: @"NSTitle"] copy];
        NSString *bundleIdentifier =
                [coder decodeObjectForKey: @"NSNibBundleIdentifier"];
        if (bundleIdentifier != nil)
            _nibBundle = [NSBundle bundleWithIdentifier: bundleIdentifier];
    }

    return self;
}

- (void) dealloc {
    [_identifier release];
    [_vcxChildViewControllers makeObjectsPerformSelector: @selector(_vcxClearParent)];
    [_vcxChildViewControllers release];
    [_vcxPresentedViewControllers makeObjectsPerformSelector: @selector(_vcxClearPresenter)];
    [_vcxPresentedViewControllers release];
    [_vcxPresentationObject release];

    [super dealloc];
}

- (NSString *) nibName {
    return _nibName;
}

- (NSBundle *) nibBundle {
    return _nibBundle;
}

- (NSView *) view {
    if (_view == nil) {
        [self loadView];
        if (_view != nil && !_vcxDidLoadView) {
            _vcxDidLoadView = YES;
            [self viewDidLoad];
        }
    }

    return _view;
}

- (NSString *) title {
    return _title;
}

- representedObject {
    return _representedObject;
}

- (void) setRepresentedObject: object {
    object = [object retain];
    [_representedObject release];
    _representedObject = object;
}

- (void) setTitle: (NSString *) value {
    value = [value retain];
    [_title release];
    _title = value;
}

- (void) setView: (NSView *) value {
    value = [value retain];
    [_view release];
    _view = value;
}

- (void) loadView {
    NSString *name = [self nibName];
    NSBundle *bundle = [self nibBundle];

    if (name == nil) {
        // should pathForResource assert name for non-nil?
        [NSException raise: NSInvalidArgumentException
                    format: @"-[%@ %s] nibName is nil", [self class], _cmd];
        return;
    }

    if (bundle == nil)
        bundle = [NSBundle mainBundle];

    NSString *path = [bundle pathForResource: name ofType: @"nib"];
    NSDictionary *nameTable = [NSDictionary dictionaryWithObject: self
                                                          forKey: NSNibOwner];

    if (path == nil)
        NSLog(@"NSViewController unable to find nib named %@, bundle=%@", name,
              bundle);

    [bundle loadNibFile: path externalNameTable: nameTable withZone: NULL];
}

- (void) discardEditing {
    NSUnimplementedMethod();
}

- (BOOL) commitEditing {
    NSUnimplementedMethod();
    return NO;
}

- (void) commitEditingWithDelegate: delegate
                 didCommitSelector: (SEL) didCommitSelector
                       contextInfo: (void *) contextInfo
{
    NSUnimplementedMethod();
}

- (BOOL) isViewLoaded {
    return _view != nil;
}

- (void) viewDidLoad {
}

- (void) viewWillAppear {
}

- (void) viewDidAppear {
}

- (void) viewWillDisappear {
}

- (void) viewDidDisappear {
}

- (NSSize) preferredContentSize {
    return _vcxPreferredContentSize;
}

- (void) setPreferredContentSize: (NSSize) value {
    _vcxPreferredContentSize = value;
    [_vcxParentViewController
            preferredContentSizeDidChangeForViewController: self];
}

- (void) preferredContentSizeDidChangeForViewController: (NSViewController *) viewController {
}

- (void) updateViewConstraints {
}

- (void) viewWillLayout {
}

- (void) viewDidLayout {
}

- (NSViewController *) parentViewController {
    return _vcxParentViewController;
}

- (void) _vcxClearParent {
    _vcxParentViewController = nil;
}

- (void) _vcxClearPresenter {
    _vcxPresentingViewController = nil;
}

- (NSArray *) childViewControllers {
    return _vcxChildViewControllers != nil
                   ? [NSArray arrayWithArray: _vcxChildViewControllers]
                   : [NSArray array];
}

- (void) addChildViewController: (NSViewController *) childViewController {
    if (childViewController == nil || childViewController == self)
        return;
    if (childViewController->_vcxParentViewController == self &&
        [_vcxChildViewControllers indexOfObjectIdenticalTo: childViewController] != NSNotFound)
        return;

    [childViewController removeFromParentViewController];

    if (_vcxChildViewControllers == nil)
        _vcxChildViewControllers = [[NSMutableArray alloc] init];
    [_vcxChildViewControllers addObject: childViewController];
    childViewController->_vcxParentViewController = self;
}

- (void) removeFromParentViewController {
    NSViewController *parent = _vcxParentViewController;

    if (parent == nil)
        return;

    _vcxParentViewController = nil;
    [self retain];
    [parent->_vcxChildViewControllers removeObjectIdenticalTo: self];
    [self release];
}

- (void) setChildViewControllers: (NSArray *) value {
    NSArray *old = [NSArray arrayWithArray: _vcxChildViewControllers];
    NSArray *new = [[value copy] autorelease];

    for (NSViewController *controller in old)
        [controller removeFromParentViewController];
    for (NSViewController *controller in new)
        [self addChildViewController: controller];
}

- (void) insertChildViewController: (NSViewController *) childViewController
                           atIndex: (NSInteger) index {
    if (childViewController == nil)
        return;
    [self addChildViewController: childViewController];
    NSUInteger current =
            [_vcxChildViewControllers indexOfObjectIdenticalTo: childViewController];
    if (current != NSNotFound && (NSUInteger) index < current) {
        [childViewController retain];
        [_vcxChildViewControllers removeObjectAtIndex: current];
        [_vcxChildViewControllers insertObject: childViewController atIndex: index];
        [childViewController release];
    }
}

- (void) removeChildViewControllerAtIndex: (NSInteger) index {
    [[_vcxChildViewControllers objectAtIndex: index] removeFromParentViewController];
}

- (NSArray *) presentedViewControllers {
    return [_vcxPresentedViewControllers count] > 0
                   ? [NSArray arrayWithArray: _vcxPresentedViewControllers]
                   : nil;
}

- (NSViewController *) presentingViewController {
    return _vcxPresentingViewController;
}

- (void) _vcxRecordPresented: (NSViewController *) viewController
                      object: (id) object {
    if (_vcxPresentedViewControllers == nil)
        _vcxPresentedViewControllers = [[NSMutableArray alloc] init];
    [_vcxPresentedViewControllers addObject: viewController];
    viewController->_vcxPresentingViewController = self;
    [viewController->_vcxPresentationObject release];
    viewController->_vcxPresentationObject = [object retain];
}

- (void) presentViewControllerAsSheet: (NSViewController *) viewController {
    NSWindow *parentWindow = [[self view] window];
    NSView *content = [viewController view];
    NSRect frame = NSMakeRect(0, 0, NSWidth([content frame]), NSHeight([content frame]));
    NSWindow *sheet = [[[NSWindow alloc]
            initWithContentRect: frame
                      styleMask: NSTitledWindowMask
                        backing: NSBackingStoreBuffered
                          defer: YES] autorelease];

    [sheet setReleasedWhenClosed: NO];
    [sheet setContentView: content];
    [self _vcxRecordPresented: viewController object: sheet];
    [viewController viewWillAppear];
    if (parentWindow != nil)
        [parentWindow beginSheet: sheet completionHandler: nil];
    [viewController viewDidAppear];
}

- (void) presentViewController: (NSViewController *) viewController
        asPopoverRelativeToRect: (NSRect) positioningRect
                         ofView: (NSView *) positioningView
                  preferredEdge: (NSRectEdge) preferredEdge
                       behavior: (NSInteger) behavior {
    id popover = [[[NSClassFromString(@"NSPopover") alloc] init] autorelease];

    [popover setContentViewController: viewController];
    [popover setBehavior: behavior];
    [self _vcxRecordPresented: viewController object: popover];
    [viewController viewWillAppear];
    [popover showRelativeToRect: positioningRect
                         ofView: positioningView
                  preferredEdge: preferredEdge];
    [viewController viewDidAppear];
}

- (void) dismissViewController: (NSViewController *) viewController {
    if (viewController == nil ||
        [_vcxPresentedViewControllers indexOfObjectIdenticalTo: viewController] == NSNotFound)
        return;

    id object = [viewController->_vcxPresentationObject retain];

    [viewController viewWillDisappear];
    if ([object isKindOfClass: [NSWindow class]]) {
        NSWindow *parentWindow = [(NSWindow *) object sheetParent];
        [parentWindow endSheet: object];
        [object orderOut: nil];
    } else if ([object respondsToSelector: @selector(close)])
        [object close];
    [viewController viewDidDisappear];

    [viewController retain];
    [_vcxPresentedViewControllers removeObjectIdenticalTo: viewController];
    viewController->_vcxPresentingViewController = nil;
    [viewController->_vcxPresentationObject release];
    viewController->_vcxPresentationObject = nil;
    [viewController release];
    [object release];
}

- (IBAction) dismissController: (id) sender {
    if (_vcxPresentingViewController != nil)
        [_vcxPresentingViewController dismissViewController: self];
}

// Storyboards are not supported, so no controller is ever instantiated from
// one.
- (NSStoryboard *) storyboard {
    return nil;
}

@end
