#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

typedef NS_OPTIONS(NSUInteger, NSMediaLibrary) {
    NSMediaLibraryAudio = 1UL << 0,
    NSMediaLibraryImage = 1UL << 1,
    NSMediaLibraryMovie = 1UL << 2
};

@interface NSMediaLibraryBrowserController : NSObject {
    BOOL _visible;
    NSRect _frame;
    NSMediaLibrary _mediaLibraries;
}

+ (NSMediaLibraryBrowserController *)sharedMediaLibraryBrowserController;

- (BOOL)isVisible;
- (void)setVisible:(BOOL)visible;
- (NSRect)frame;
- (void)setFrame:(NSRect)frame;
- (NSMediaLibrary)mediaLibraries;
- (void)setMediaLibraries:(NSMediaLibrary)mediaLibraries;
- (IBAction)togglePanel:(id)sender;

@end
