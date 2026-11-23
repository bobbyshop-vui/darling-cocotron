#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSGeometry.h>
#import <AppKit/NSPrintInfo.h>

#ifndef NSPaperOrientationPortrait
typedef NSInteger NSPaperOrientation;
enum {
    NSPaperOrientationPortrait = 0,
    NSPaperOrientationLandscape = 1,
};
#endif

@class NSURL;

@interface NSPDFInfo : NSObject <NSCopying, NSCoding> {
    NSURL *_URL;
    NSArray *_tagNames;
    NSPaperOrientation _orientation;
    NSSize _paperSize;
    NSMutableDictionary *_attributes;
    BOOL _fileExtensionHidden;
}

@property(copy) NSURL *URL;
@property(getter=isFileExtensionHidden) BOOL fileExtensionHidden;
@property(copy) NSArray *tagNames;
@property NSPaperOrientation orientation;
@property NSSize paperSize;
@property(readonly) NSMutableDictionary *attributes;

@end
