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
#import <AppKit/NSSound.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSException.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSString.h>

extern NSBundle *NSNibCurrentLoadingBundle(void);

@implementation NSCustomResource

/*
 * The bundles a named resource is looked up in: the bundle the nib is being
 * loaded from first (Xcode keeps its UI images next to its nibs in IDEKit and
 * other frameworks), then the main bundle and AppKit itself.
 */
static NSArray *NSCustomResourceBundles(void) {
    NSMutableArray *bundles = [NSMutableArray array];
    NSBundle *nibBundle = NSNibCurrentLoadingBundle();

    if (nibBundle != nil)
        [bundles addObject: nibBundle];
    if ([NSBundle mainBundle] != nil &&
        ![bundles containsObject: [NSBundle mainBundle]])
        [bundles addObject: [NSBundle mainBundle]];
    return bundles;
}

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

/*
 * IDEInterfaceBuilderKit's -ibSwizzledAwakeAfterUsingCoder: (which replaces
 * this class's -awakeAfterUsingCoder: inside Xcode) dispatches on -className
 * and then calls one of these loaders on the receiver.  They are part of the
 * real AppKit class.  Each returns an autoreleased object.
 */
- (NSImage *) loadImageWithName: (NSString *) name {
    NSImage *image = nil;

    if (name == nil)
        return nil;

    for (NSBundle *bundle in NSCustomResourceBundles()) {
        NSString *path = [bundle pathForImageResource: name];

        if (path != nil) {
            image = [[[NSImage alloc] initWithContentsOfFile: path]
                    autorelease];
            if (image != nil) {
                [image setName: name];
                break;
            }
        }
    }

    if (image == nil)
        image = [NSImage imageNamed: name];

    if (image == nil) {
        /*
         * Most of Xcode's images live in compiled asset catalogs (Assets.car),
         * which we cannot read yet.  Returning nil would make the unarchiver
         * fail the whole nib, so hand back an empty, named placeholder the
         * way AppKit does for a missing image in a nib.
         */
        NSLog(@"NSCustomResource: could not find image named '%@'", name);
        image = [[[NSImage alloc] initWithSize: NSMakeSize(0, 0)] autorelease];
        [image setName: name];
    }

    if ([name hasSuffix: @"Template"])
        [image setTemplate: YES];

    return image;
}

- (NSSound *) loadSoundWithName: (NSString *) name {
    NSSound *sound;

    if (name == nil)
        return nil;

    for (NSBundle *bundle in NSCustomResourceBundles()) {
        NSString *path = [bundle pathForSoundResource: name];

        if (path != nil) {
            sound = [[[NSSound alloc] initWithContentsOfFile: path
                                                 byReference: YES]
                    autorelease];
            if (sound != nil)
                return sound;
        }
    }

    return [NSSound soundNamed: name];
}

- (id) loadCIImageWithName: (NSString *) name {
    Class ciImageClass = NSClassFromString(@"CIImage");

    if (name == nil || ciImageClass == Nil)
        return nil;

    for (NSBundle *bundle in NSCustomResourceBundles()) {
        NSString *path = [bundle pathForImageResource: name];

        if (path != nil &&
            [ciImageClass respondsToSelector: @selector(imageWithContentsOfURL:)])
        {
            return [ciImageClass
                    performSelector: @selector(imageWithContentsOfURL:)
                         withObject: [NSURL fileURLWithPath: path]];
        }
    }

    return nil;
}

- (void) dealloc {
    [_className release];
    [_resourceName release];
    [super dealloc];
}

- awakeAfterUsingCoder: (NSCoder *) coder {
    id result = nil;

    if ([_className isEqualToString: @"NSImage"])
        result = [self loadImageWithName: _resourceName];
    else if ([_className isEqualToString: @"NSSound"])
        result = [self loadSoundWithName: _resourceName];
    else if ([_className isEqualToString: @"CIImage"])
        result = [self loadCIImageWithName: _resourceName];

    if (result == nil) {
        NSLog(@"Could not load %@ named '%@'", _className, _resourceName);
        result = [[[NSImage alloc] initWithSize: NSMakeSize(0, 0)] autorelease];
    }

    [result retain];
    [self release];
    return result;
}

@end
