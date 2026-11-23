/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

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

#import <AppKit/NSCustomTouchBarItem.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>

@implementation NSCustomTouchBarItem

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding]) {
            _view = [[coder decodeObjectForKey:@"NSTouchBarItemView"] retain];
            _viewController = [[coder decodeObjectForKey:@"NSTouchBarItemViewController"] retain];
            _customizationLabel = [[coder decodeObjectForKey:@"NSTouchBarItemCustomizationLabel"] copy];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_view forKey:@"NSTouchBarItemView"];
        [coder encodeObject:_viewController forKey:@"NSTouchBarItemViewController"];
        [coder encodeObject:_customizationLabel forKey:@"NSTouchBarItemCustomizationLabel"];
    }
}

- (void)dealloc
{
    [_view release];
    [_viewController release];
    [_customizationLabel release];
    [super dealloc];
}

- (NSView *)view
{
    if (_view == nil && _viewController != nil)
        return [_viewController view];
    return _view;
}

- (void)setView:(NSView *)view
{
    [self willChangeValueForKey:@"view"];
    [view retain];
    [_view release];
    _view = view;
    // Setting the view explicitly clears the view controller.
    [_viewController release];
    _viewController = nil;
    [self didChangeValueForKey:@"view"];
}

- (NSViewController *)viewController
{
    return _viewController;
}

- (void)setViewController:(NSViewController *)viewController
{
    [self willChangeValueForKey:@"viewController"];
    [viewController retain];
    [_viewController release];
    _viewController = viewController;
    [_view release];
    _view = nil;
    [self didChangeValueForKey:@"viewController"];
}

- (NSString *)customizationLabel
{
    return _customizationLabel != nil ? _customizationLabel : @"";
}

- (void)setCustomizationLabel:(NSString *)label
{
    label = [label copy];
    [_customizationLabel release];
    _customizationLabel = label;
}

@end

@implementation NSButtonGroupTouchBarItem

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
