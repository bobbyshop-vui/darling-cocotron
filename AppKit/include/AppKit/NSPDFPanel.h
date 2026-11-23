#import <Foundation/NSObject.h>

@class NSString, NSPDFInfo, NSViewController, NSWindow;

typedef NS_OPTIONS(NSInteger, NSPDFPanelOptions) {
    NSPDFPanelShowsPaperSize = 1 << 2,
    NSPDFPanelShowsOrientation = 1 << 3,
    NSPDFPanelRequestsParentDirectory = 1 << 24
};

@interface NSPDFPanel : NSObject {
    NSViewController *_accessoryController;
    NSPDFPanelOptions _options;
    NSString *_defaultFileName;
}

+ (NSPDFPanel *)panel;

- (NSViewController *)accessoryController;
- (void)setAccessoryController:(NSViewController *)controller;
- (NSPDFPanelOptions)options;
- (void)setOptions:(NSPDFPanelOptions)options;
- (NSString *)defaultFileName;
- (void)setDefaultFileName:(NSString *)name;

- (void)beginSheetWithPDFInfo:(NSPDFInfo *)pdfInfo modalForWindow:(NSWindow *)docWindow completionHandler:(void (^)(NSInteger))completionHandler;

@end
