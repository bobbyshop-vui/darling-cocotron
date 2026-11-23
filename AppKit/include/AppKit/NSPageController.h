#import <Foundation/Foundation.h>
#import <AppKit/NSViewController.h>

typedef NS_ENUM(NSInteger, NSPageControllerTransitionStyle) {
    NSPageControllerTransitionStyleStackHistory,
    NSPageControllerTransitionStyleStackBook,
    NSPageControllerTransitionStyleHorizontalStrip
};

@protocol NSPageControllerDelegate;

@interface NSPageController : NSViewController {
    NSViewController *_selectedViewController;
    NSPageControllerTransitionStyle _transitionStyle;
    id<NSPageControllerDelegate> _delegate;
    NSInteger _selectedIndex;
    NSArray *_arrangedObjects;
}

@property (weak) id<NSPageControllerDelegate> delegate;
@property (readonly, strong) NSViewController *selectedViewController;
@property NSPageControllerTransitionStyle transitionStyle;
@property (copy) NSArray *arrangedObjects;
@property NSInteger selectedIndex;

- (void) completeTransition;

@end

@protocol NSPageControllerDelegate <NSObject>
@optional
- (NSString *) pageController: (NSPageController *) pageController
          identifierForObject: (id) object;
- (NSViewController *) pageController: (NSPageController *) pageController
          viewControllerForIdentifier: (NSString *) identifier;
- (NSRect) pageController: (NSPageController *) pageController
           frameForObject: (id) object;
- (void) pageController: (NSPageController *) pageController
        prepareViewController: (NSViewController *) viewController
                   withObject: (id) object;
- (void) pageController: (NSPageController *) pageController
        didTransitionToObject: (id) object;
- (void) pageControllerWillStartLiveTransition: (NSPageController *) pageController;
- (void) pageControllerDidEndLiveTransition: (NSPageController *) pageController;
@end
