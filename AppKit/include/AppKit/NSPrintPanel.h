#import <AppKit/AppKitExport.h>
#import <Foundation/NSObject.h>

@class NSMutableDictionary, NSMutableArray, NSView, NSViewController, NSPrintInfo;

enum {

    NSPrintPanelShowsCopies = 1 << 0,
    NSPrintPanelShowsPageRange = 1 << 1,
    NSPrintPanelShowsPaperSize = 1 << 2,
    NSPrintPanelShowsOrientation = 1 << 3,
    NSPrintPanelShowsScaling = 1 << 4,
    NSPrintPanelShowsPrintSelection = 1 << 5,
    NSPrintPanelShowsPageSetupAccessory = 1 << 8,
    NSPrintPanelShowsPreview = 1 << 17
};

typedef NSInteger NSPrintPanelOptions;

@interface NSPrintPanel : NSObject {
    NSMutableDictionary *_attributes;
    NSInteger _options;
    NSMutableArray *_accessoryControllers;
    NSString *_defaultButtonTitle;
    NSView *_accessoryView;
}

+ (NSPrintPanel *) printPanel;

- (void) setOptions: (NSPrintPanelOptions) options;
- (NSPrintPanelOptions) options;

- (int) runModal;

- (void) setAccessoryView: (NSView *) view;
- (NSView *) accessoryView;
- (void) addAccessoryController: (NSViewController *) accessoryController;
- (NSPrintInfo *) printInfo;
- (void) setDefaultButtonTitle: (NSString *) title;
- (NSString *) defaultButtonTitle;

- (void) updateFromPrintInfo;
- (void) finalWritePrintInfo;

@end

@protocol NSPrintPanelAccessorizing

// TODO

@end

APPKIT_EXPORT NSString *const NSPrintPanelAccessorySummaryItemNameKey;
APPKIT_EXPORT NSString *const NSPrintPanelAccessorySummaryItemDescriptionKey;
