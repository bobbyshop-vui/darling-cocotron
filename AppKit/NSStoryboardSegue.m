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

#import <AppKit/NSStoryboardSegue.h>

@implementation NSStoryboardSegue

@synthesize sourceController = _sourceController;
@synthesize destinationController = _destinationController;

+ (instancetype)segueWithIdentifier:(NSString *)identifier source:(id)sourceController destination:(id)destinationController performHandler:(void (^)(void))performHandler
{
    NSStoryboardSegue *segue = [[[self alloc] initWithIdentifier:identifier source:sourceController destination:destinationController] autorelease];
    segue->_performHandler = [performHandler copy];
    return segue;
}

- (instancetype)initWithIdentifier:(NSString *)identifier source:(id)sourceController destination:(id)destinationController
{
    if ((self = [super init]) != nil) {
        _identifier = [identifier copy];
        _sourceController = [sourceController retain];
        _destinationController = [destinationController retain];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithIdentifier:nil source:nil destination:nil];
}

- (void)dealloc
{
    [_performHandler release];
    [_prepareHandler release];
    [_identifier release];
    [_sourceController release];
    [_destinationController release];
    [super dealloc];
}

- (NSString *)identifier
{
    return _identifier;
}

- (void)perform
{
    if (_performHandler != nil)
        _performHandler();
}

@end
