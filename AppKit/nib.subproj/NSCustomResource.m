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

#import "NSCustomResource.h"
#import <AppKit/NSImage.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSString.h>

@implementation NSCustomResource

- initWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        NSKeyedUnarchiver *keyed = (NSKeyedUnarchiver *) coder;

        _className = [[keyed decodeObjectForKey: @"NSClassName"] retain];
        _resourceName = [[keyed decodeObjectForKey: @"NSResourceName"] retain];
    } else {
        [coder decodeValuesOfObjCTypes:"@@", &_className, &_resourceName];
    }

    return self;
}

/*
 * `-resourceName` is part of the real class and is called by
 * IDEInterfaceBuilderKit's -ibSwizzledAwakeAfterUsingCoder: while decoding a
 * nib.  Without it, loading Xcode's Welcome window raised
 * "-[NSCustomResource resourceName]: unrecognized selector" and aborted.
 */
/*
 * IDEInterfaceBuilderKit decides what to do with a custom resource by asking it
 * for its -className.  NSObject's -className returns the receiver's class name
 * ("NSCustomResource"), which made IB log "Unknown custom resource type
 * NSCustomResource" and return nil from its swizzled awakeAfterUsingCoder:.
 * The real class overrides -className to report the *archived* class name
 * (usually "NSImage").
 */
- (NSString *) className {
    return _className;
}

- (NSString *) resourceName {
    return _resourceName;
}

- (void) setResourceName: (NSString *) value {
    if (value != _resourceName) {
        [_resourceName release];
        _resourceName = [value retain];
    }
}

- (void) dealloc {
    [_className release];
    [_resourceName release];
    [super dealloc];
}

- awakeAfterUsingCoder: (NSCoder *) coder {
    if ([_className isEqualToString: @"NSImage"]) {
        NSImage *image = [NSImage imageNamed: _resourceName];

        if ([_resourceName hasSuffix: @"Template"])
            [image setTemplate: YES];

        if (image != nil) {
            [self release];
            return [image retain];
        }
    }

    NSLog(@"Could not find image named '%@'", _resourceName);

    return [[NSImage alloc] init];
}

@end
