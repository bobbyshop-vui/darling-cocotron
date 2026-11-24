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

#import <AppKit/NSKeyBindingManager.h>
#import <Foundation/Foundation.h>

@implementation NSKeyBindingManager

static NSKeyBindingManager *sharedManager = nil;

+ (NSKeyBindingManager *) sharedKeyBindingManager
{
	@synchronized(self) {
		if (sharedManager == nil)
			sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

- (instancetype) init
{
	if ((self = [super init])) {
		NSMutableDictionary *bindings = [NSMutableDictionary dictionary];
		NSMutableArray *paths = [NSMutableArray array];

		NSString *standard = [[NSBundle bundleForClass: [NSKeyBindingManager class]]
			pathForResource: @"StandardKeyBinding" ofType: @"dict"];
		if (standard != nil)
			[paths addObject: standard];
		[paths addObject: [NSHomeDirectory() stringByAppendingPathComponent:
			@"Library/KeyBindings/DefaultKeyBinding.dict"]];

		for (NSString *path in paths) {
			NSDictionary *loaded = [NSDictionary dictionaryWithContentsOfFile: path];
			if ([loaded isKindOfClass: [NSDictionary class]])
				[bindings addEntriesFromDictionary: loaded];
		}
		_dictionary = [bindings copy];
	}
	return self;
}

- (void) dealloc
{
	[_dictionary release];
	[super dealloc];
}

- (NSDictionary *) dictionary
{
	@synchronized(self) {
		return [[_dictionary retain] autorelease];
	}
}

- (void) setDictionary: (NSDictionary *) dictionary
{
	@synchronized(self) {
		if (dictionary != _dictionary) {
			[_dictionary release];
			_dictionary = [dictionary copy];
		}
	}
}

@end
