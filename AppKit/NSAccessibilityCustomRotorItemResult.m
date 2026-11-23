/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <AppKit/NSAccessibilityCustomRotorItemResult.h>

@implementation NSAccessibilityCustomRotorItemResult

@synthesize targetElement = _targetElement;
@synthesize itemLoadingToken = _itemLoadingToken;
@synthesize customLabel = _customLabel;
@synthesize targetRange = _targetRange;

+ (instancetype)new
{
    [NSException raise:NSInvalidArgumentException format:@"+[NSAccessibilityCustomRotorItemResult new] is unavailable"];
    return nil;
}

- (instancetype)init
{
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"-[NSAccessibilityCustomRotorItemResult init] is unavailable"];
    return nil;
}

- (instancetype)initWithTargetElement:(id)targetElement
{
    if ((self = [super init]) != nil) {
        _targetElement = targetElement;
        _targetRange = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

- (instancetype)initWithItemLoadingToken:(NSAccessibilityLoadingToken)itemLoadingToken customLabel:(NSString *)customLabel
{
    if ((self = [super init]) != nil) {
        _itemLoadingToken = [itemLoadingToken retain];
        _customLabel = [customLabel copy];
        _targetRange = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

- (void)dealloc
{
    [_customLabel release];
    [_itemLoadingToken release];
    _targetElement = nil;
    [super dealloc];
}

- (NSRange)targetRange
{
    return _targetRange;
}

- (void)setTargetRange:(NSRange)range
{
    _targetRange = range;
}

@end
