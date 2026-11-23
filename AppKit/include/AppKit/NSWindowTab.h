#import <Foundation/Foundation.h>
#import <AppKit/AppKitExport.h>

@class NSWindow, NSView, NSImage, NSAttributedString;

@interface NSWindowTab : NSObject {
    NSString *_title;
    NSAttributedString *_attributedTitle;
    NSString *_toolTip;
    NSImage *_image;
    NSView *_accessoryView;
    NSWindow *_window;
}

/* Setting nil makes the title follow the window title again. */
@property(copy) NSString *title;
@property(copy) NSAttributedString *attributedTitle;
/* Setting nil makes the tool tip follow the title again. */
@property(copy) NSString *toolTip;
@property(retain) NSView *accessoryView;
/* The window the tab belongs to (not retained). */
@property(assign) NSWindow *window;

- (instancetype)initWithWindow:(NSWindow *)window;

@end
