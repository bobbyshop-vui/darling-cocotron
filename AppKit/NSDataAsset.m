#import <AppKit/NSDataAsset.h>

@implementation NSDataAsset

- (instancetype) init {
    [self release];
    return nil;
}

- (instancetype) initWithName: (NSString *) name {
    return [self initWithName: name bundle: [NSBundle mainBundle]];
}

// Data assets are looked up as loose resources: either a file called
// <name> (optionally with an extension) or the payload of a <name>.dataset
// folder, as laid out by an uncompiled asset catalog.
- (instancetype) initWithName: (NSString *) name bundle: (NSBundle *) bundle {
    NSString *path = nil;
    NSFileManager *fm = [NSFileManager defaultManager];

    if (name == nil || bundle == nil) {
        [self release];
        return nil;
    }

    NSString *datasetDir = [bundle pathForResource: name ofType: @"dataset"];
    if (datasetDir != nil) {
        NSArray *items = [fm contentsOfDirectoryAtPath: datasetDir error: NULL];
        for (NSString *item in items) {
            if ([item isEqualToString: @"Contents.json"] ||
                [item hasPrefix: @"."])
                continue;
            path = [datasetDir stringByAppendingPathComponent: item];
            break;
        }
    }
    if (path == nil)
        path = [bundle pathForResource: name ofType: nil];

    NSData *data = path != nil ? [NSData dataWithContentsOfFile: path] : nil;
    if (data == nil) {
        [self release];
        return nil;
    }

    if ((self = [super init])) {
        _name = [name copy];
        _data = [data copy];

        NSString *ext = [[path pathExtension] lowercaseString];
        if ([ext isEqualToString: @"json"])
            _typeIdentifier = @"public.json";
        else if ([ext isEqualToString: @"txt"])
            _typeIdentifier = @"public.plain-text";
        else if ([ext isEqualToString: @"plist"])
            _typeIdentifier = @"com.apple.property-list";
        else if ([ext isEqualToString: @"xml"])
            _typeIdentifier = @"public.xml";
        else if ([ext isEqualToString: @"png"])
            _typeIdentifier = @"public.png";
        else if ([ext isEqualToString: @"jpg"] || [ext isEqualToString: @"jpeg"])
            _typeIdentifier = @"public.jpeg";
        else if ([ext isEqualToString: @"pdf"])
            _typeIdentifier = @"com.adobe.pdf";
        else
            _typeIdentifier = @"public.data";
    }
    return self;
}

- (NSString *) name {
    return _name;
}

- (NSData *) data {
    return _data;
}

- (NSString *) typeIdentifier {
    return _typeIdentifier;
}

- (id) copyWithZone: (NSZone *) zone {
    return [self retain];
}

- (void) dealloc {
    [_name release];
    [_data release];
    [super dealloc];
}

@end
