/*
 This file is part of Darling.

 Copyright (C) 2021 Lubos Dolezel

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/NSStoryboard.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSWindowController.h>

@interface NSStoryboardControllerPlaceholder : NSObject
@end

@implementation NSStoryboard

+ (instancetype) storyboardWithName: (NSStoryboardName) name
                             bundle: (NSBundle *) bundle
{
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    NSString *path = [bundle pathForResource: name ofType: @"storyboardc"];
    if (path == nil) {
        return nil;
    }
    NSStoryboard *storyboard = [[[self alloc] init] autorelease];
    storyboard->_path = [path copy];
    storyboard->_info = [[NSDictionary alloc]
            initWithContentsOfFile: [path stringByAppendingPathComponent:
                                                  @"Info.plist"]];
    return storyboard;
}

- (void) dealloc {
    [_path release];
    [_info release];
    [super dealloc];
}

/* Compiled storyboards are directories holding Info.plist and one nib per
   scene. Info.plist maps scene identifiers to nib names and records the
   initial scene. */
- (NSString *) _nibPathForIdentifier: (NSString *) identifier {
    NSDictionary *map = [_info objectForKey: @"NSViewControllerIdentifiersToNibNames"];
    if (map == nil) {
        map = [_info objectForKey: @"NSStoryboardIdentifiersToNibNames"];
    }
    NSString *nibName = [map objectForKey: identifier];
    if (nibName == nil) {
        nibName = identifier;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *ext in [NSArray arrayWithObjects: @"nib", @"", nil]) {
        NSString *file = [ext length] ? [nibName stringByAppendingPathExtension: ext]
                                      : nibName;
        NSString *full = [_path stringByAppendingPathComponent: file];
        if ([fm fileExistsAtPath: full]) {
            return full;
        }
    }
    return nil;
}

- (id) instantiateControllerWithIdentifier:
        (NSStoryboardSceneIdentifier) identifier
{
    NSString *nibPath = [self _nibPathForIdentifier: identifier];
    if (nibPath == nil) {
        [NSException raise: NSInvalidArgumentException
                    format: @"Could not find a view controller with identifier '%@' in storyboard", identifier];
    }
    NSNib *nib = [[[NSNib alloc]
            initWithContentsOfURL: [NSURL fileURLWithPath: nibPath]]
            autorelease];
    NSArray *objects = nil;
    if (![nib instantiateNibWithOwner: nil topLevelObjects: &objects]) {
        return nil;
    }
    for (id object in objects) {
        if ([object isKindOfClass: [NSViewController class]] ||
            [object isKindOfClass: [NSWindowController class]]) {
            return object;
        }
    }
    return nil;
}

- (id) instantiateInitialController {
    NSString *identifier = [_info objectForKey: @"NSStoryboardDesignatedEntryPointIdentifier"];
    if (identifier == nil) {
        identifier = [_info objectForKey: @"NSStoryboardInitialViewControllerIdentifier"];
    }
    if (identifier == nil) {
        return nil;
    }
    return [self instantiateControllerWithIdentifier: identifier];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end

@implementation NSStoryboardControllerPlaceholder

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
