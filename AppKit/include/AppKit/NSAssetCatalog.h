/*
 * Private reader for compiled Apple asset catalogs (Assets.car).
 */

#import <AppKit/NSImage.h>

@interface NSAssetCatalog : NSObject {
@private
    NSData *_fileData;
    NSArray *_blockRanges;
    NSDictionary *_namedBlockIndices;
    NSArray *_keyFormat;
    NSDictionary *_facets;
    NSDictionary *_renditions;
}

+ (NSAssetCatalog *)catalogWithPath:(NSString *)carPath;
// Looks name up in the Assets.car of each bundle (catalogs are cached per path).
+ (NSImage *)imageNamed:(NSString *)name inBundles:(NSArray *)bundles;
- (NSData *)imageDataForName:(NSString *)name scale:(CGFloat)scale;
- (NSImage *)imageNamed:(NSString *)name;

@end
