#import <Foundation/NSURL.h>

@class NSPasteboard;

@interface NSURL (XcodeAdditions)
+ (instancetype) fileURLWithPath: (NSString *) path
                     isDirectory: (BOOL) isDir
                   relativeToURL: (NSURL *) baseURL;
+ (instancetype) URLByResolvingAliasFileAtURL: (NSURL *) url
                                      options: (NSURLBookmarkResolutionOptions) options
                                        error: (NSError **) error;
- (instancetype) initFileURLWithPath: (NSString *) path
                         isDirectory: (BOOL) isDir
                       relativeToURL: (NSURL *) baseURL;
- (instancetype) initFileURLWithPath: (NSString *) path
                       relativeToURL: (NSURL *) baseURL;
- (instancetype) initWithDataRepresentation: (NSData *) data
                              relativeToURL: (NSURL *) baseURL;
- (instancetype) initAbsoluteURLWithDataRepresentation: (NSData *) data
                                         relativeToURL: (NSURL *) baseURL;
- (NSData *) dataRepresentation;
- (BOOL) hasDirectoryPath;
- (BOOL) checkPromisedItemIsReachableAndReturnError: (NSError **) error;
- (NSDictionary *) promisedItemResourceValuesForKeys: (NSArray *) keys
                                               error: (NSError **) error;
- (id) propertyForKey: (NSString *) propertyKey;
- (BOOL) setProperty: (id) property forKey: (NSString *) propertyKey;
- (void) removeCachedResourceValueForKey: (NSString *) key;
- (void) removeAllCachedResourceValues;
- (void) setTemporaryResourceValue: (id) value forKey: (NSString *) key;
- (BOOL) startAccessingSecurityScopedResource;
- (void) stopAccessingSecurityScopedResource;
- (BOOL) writeToPasteboard: (NSPasteboard *) pasteboard;
@end
