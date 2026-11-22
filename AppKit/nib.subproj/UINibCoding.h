#import <Foundation/NSData.h>

__attribute__((visibility("hidden")))
BOOL NSIsNibArchive(NSData *data);

__attribute__((visibility("hidden")))
NSData *NSKeyedArchiveFromNibArchive(NSData *data);
