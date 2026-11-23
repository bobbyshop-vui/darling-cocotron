/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSColorSpace.h>
#import <Foundation/NSRaise.h>

// not sure where these belong
NSString *const _NSColorCoreUICatalogMainBundleID =
        @"_NSColorCoreUICatalogMainBundleID";
NSString *const _NSColorCoreUICatalogNamePrefix =
        @"_NSColorCoreUICatalogNamePrefix";

@implementation NSColorSpace

// kind: 0 = RGB, 1 = gray, 2 = CMYK; used when the named space is unavailable
static NSColorSpace *_NSColorSpaceCreate(Class cls, CFStringRef name, int kind,
                                         NSString *localizedName) {
    CGColorSpaceRef cgSpace = name ? CGColorSpaceCreateWithName(name) : NULL;
    if (cgSpace == NULL) {
        switch (kind) {
        case 1:
            cgSpace = CGColorSpaceCreateDeviceGray();
            break;
        case 2:
            cgSpace = CGColorSpaceCreateDeviceCMYK();
            break;
        default:
            cgSpace = CGColorSpaceCreateDeviceRGB();
            break;
        }
    }
    NSColorSpace *result =
            [[[cls alloc] initWithCGColorSpace: cgSpace] autorelease];
    CGColorSpaceRelease(cgSpace);
    [result->_localizedName release];
    result->_localizedName = [localizedName copy];
    return result;
}

+ (NSColorSpace *) sRGBColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceSRGB, 0,
                               @"sRGB IEC61966-2.1");
}

+ (NSColorSpace *) deviceRGBColorSpace {
    return _NSColorSpaceCreate(self, NULL, 0, @"Device RGB");
}

+ (NSColorSpace *) deviceGrayColorSpace {
    return _NSColorSpaceCreate(self, NULL, 1, @"Device Gray");
}

+ (NSColorSpace *) deviceCMYKColorSpace {
    return _NSColorSpaceCreate(self, NULL, 2, @"Device CMYK");
}

+ (NSColorSpace *) genericRGBColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceGenericRGB, 0,
                               @"Generic RGB Profile");
}

+ (NSColorSpace *) genericGrayColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceGenericGray, 1,
                               @"Generic Gray Profile");
}

+ (NSColorSpace *) genericCMYKColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceGenericCMYK, 2,
                               @"Generic CMYK Profile");
}

+ (NSColorSpace *) genericGamma22GrayColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceGenericGrayGamma2_2, 1,
                               @"Generic Gray Gamma 2.2 Profile");
}

+ (NSColorSpace *) extendedSRGBColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceExtendedSRGB, 0,
                               @"Extended sRGB");
}

+ (NSColorSpace *) displayP3ColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceDisplayP3, 0, @"Display P3");
}

+ (NSColorSpace *) adobeRGB1998ColorSpace {
    return _NSColorSpaceCreate(self, kCGColorSpaceAdobeRGB1998, 0,
                               @"Adobe RGB (1998)");
}

+ (NSArray *) availableColorSpacesWithModel: (NSColorSpaceModel) model {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *candidates = [NSArray
            arrayWithObjects: [self genericGrayColorSpace],
                              [self genericGamma22GrayColorSpace],
                              [self genericRGBColorSpace],
                              [self sRGBColorSpace],
                              [self adobeRGB1998ColorSpace],
                              [self displayP3ColorSpace],
                              [self genericCMYKColorSpace], nil];
    for (NSColorSpace *space in candidates) {
        if (model == NSColorSpaceModelUnknown ||
            [space colorSpaceModel] == model)
            [result addObject: space];
    }
    return result;
}

- initWithCGColorSpace: (CGColorSpaceRef) cgColorSpace {
    _cgColorSpace = CGColorSpaceRetain(cgColorSpace);
    return self;
}

- (void) dealloc {
    [_localizedName release];
    CGColorSpaceRelease(_cgColorSpace);
    [super dealloc];
}

- (CGColorSpaceRef) CGColorSpace {
    return _cgColorSpace;
}

- (NSInteger) numberOfColorComponents {
    return CGColorSpaceGetNumberOfComponents(_cgColorSpace);
}

- (NSColorSpaceModel) colorSpaceModel {
    switch (CGColorSpaceGetModel(_cgColorSpace)) {
    case kCGColorSpaceModelMonochrome:
        return NSColorSpaceModelGray;
    case kCGColorSpaceModelRGB:
        return NSColorSpaceModelRGB;
    case kCGColorSpaceModelCMYK:
        return NSColorSpaceModelCMYK;
    case kCGColorSpaceModelLab:
        return NSColorSpaceModelLAB;
    case kCGColorSpaceModelDeviceN:
        return NSColorSpaceModelDeviceN;
    case kCGColorSpaceModelIndexed:
        return NSColorSpaceModelIndexed;
    case kCGColorSpaceModelPattern:
        return NSColorSpaceModelPatterned;
    default:
        return NSColorSpaceModelUnknown;
    }
}

- (NSString *) localizedName {
    return _localizedName;
}

@end

NSString* _NSColorSpaceNameFromNum(void) {
    NSUnimplementedFunction();
    return nil;
};
