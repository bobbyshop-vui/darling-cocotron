#import <Foundation/Foundation.h>

@class NSSavePanel;

@interface _NSFileSystemDataSource : NSObject {
    NSMutableSet *_cachedPaths;
    NSMutableDictionary *_childrenCache;
    NSFileManager *_fileManager;
    NSSavePanel *_panel; // not retained, the panel owns the outline view
}

- (void) setPanel: (NSSavePanel *) panel;
// Drops cached directory listings, call when the panel's filters change.
- (void) reset;
// The canonical item (NSURL) the outline view uses for path.
- (NSURL *) itemForPath: (NSString *) path;
- (BOOL) isPackageItem: (NSURL *) url;
- (BOOL) isDirectoryItem: (NSURL *) url;
// Whether the user may choose url (allowed types, directories, delegate).
- (BOOL) isEnabledItem: (NSURL *) url;

@end
