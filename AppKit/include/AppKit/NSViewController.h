#import <AppKit/NSResponder.h>
#import <AppKit/NSUserInterfaceItemIdentification.h>

@class NSView, NSArray, NSStoryboard;

@interface NSViewController : NSResponder <NSUserInterfaceItemIdentification> {
    NSString *_nibName;
    NSBundle *_nibBundle;
    id _representedObject;
    NSString *_title;
    NSView *_view;
    NSUserInterfaceItemIdentifier _identifier;
    NSSize _vcxPreferredContentSize;
    NSViewController *_vcxParentViewController;
    NSMutableArray *_vcxChildViewControllers;
    NSViewController *_vcxPresentingViewController;
    NSMutableArray *_vcxPresentedViewControllers;
    id _vcxPresentationObject;
    BOOL _vcxDidLoadView;
}

- initWithNibName: (NSString *) name bundle: (NSBundle *) bundle;

- (NSString *) nibName;
- (NSBundle *) nibBundle;

- (NSView *) view;
- (NSString *) title;
- representedObject;

- (void) setRepresentedObject: object;

- (void) setTitle: (NSString *) value;

- (void) setView: (NSView *) value;

- (void) loadView;

- (void) discardEditing;

- (BOOL) commitEditing;
- (void) commitEditingWithDelegate: delegate
                 didCommitSelector: (SEL) didCommitSelector
                       contextInfo: (void *) contextInfo;

- (BOOL) isViewLoaded;
- (void) viewDidLoad;
- (void) viewWillAppear;
- (void) viewDidAppear;
- (void) viewWillDisappear;
- (void) viewDidDisappear;
- (NSSize) preferredContentSize;
- (void) setPreferredContentSize: (NSSize) value;
- (void) updateViewConstraints;
- (void) viewWillLayout;
- (void) viewDidLayout;

- (void) dismissViewController: (NSViewController *) viewController;
- (NSArray *) presentedViewControllers;
- (NSViewController *) presentingViewController;
- (void) presentViewControllerAsSheet: (NSViewController *) viewController;
- (void) presentViewController: (NSViewController *) viewController
        asPopoverRelativeToRect: (NSRect) positioningRect
                         ofView: (NSView *) positioningView
                  preferredEdge: (NSRectEdge) preferredEdge
                       behavior: (NSInteger) behavior;

- (NSViewController *) parentViewController;
- (NSArray *) childViewControllers;
- (void) setChildViewControllers: (NSArray *) value;
- (void) addChildViewController: (NSViewController *) childViewController;
- (void) removeFromParentViewController;

- (void) insertChildViewController: (NSViewController *) childViewController
                           atIndex: (NSInteger) index;
- (void) removeChildViewControllerAtIndex: (NSInteger) index;
- (void) preferredContentSizeDidChangeForViewController: (NSViewController *) viewController;
- (IBAction) dismissController: (id) sender;

- (NSStoryboard *) storyboard;

@end
