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

#import <CoreData/NSPersistentStoreDescription.h>

static NSString *const kReadOnlyOption = @"NSReadOnlyPersistentStoreOption";
static NSString *const kTimeoutOption = @"NSPersistentStoreTimeoutOption";

@implementation NSPersistentStoreDescription

@synthesize shouldAddStoreAsynchronously = _shouldAddStoreAsynchronously;
@synthesize shouldMigrateStoreAutomatically = _shouldMigrateStoreAutomatically;
@synthesize shouldInferMappingModelAutomatically = _shouldInferMappingModelAutomatically;

+ (instancetype) persistentStoreDescriptionWithURL: (NSURL *) URL {
    return [[[self alloc] initWithURL: URL] autorelease];
}

- (instancetype) init {
    return [self initWithURL: nil];
}

- (instancetype) initWithURL: (NSURL *) url {
    if ((self = [super init])) {
        _type = [@"SQLite" copy];
        _url = [url copy];
        _options = [[NSMutableDictionary alloc] init];
        _sqlitePragmas = [[NSMutableDictionary alloc] init];
        _timeout = 240;
        _shouldMigrateStoreAutomatically = YES;
        _shouldInferMappingModelAutomatically = YES;
    }
    return self;
}

- (void) dealloc {
    [_type release];
    [_configuration release];
    [_url release];
    [_options release];
    [_sqlitePragmas release];
    [super dealloc];
}

- (id) copyWithZone: (NSZone *) zone {
    NSPersistentStoreDescription *copy = [[[self class] allocWithZone: zone] initWithURL: _url];
    [copy->_type release];
    copy->_type = [_type copy];
    copy->_configuration = [_configuration copy];
    [copy->_options setDictionary: _options];
    [copy->_sqlitePragmas setDictionary: _sqlitePragmas];
    copy->_timeout = _timeout;
    copy->_readOnly = _readOnly;
    copy->_shouldAddStoreAsynchronously = _shouldAddStoreAsynchronously;
    copy->_shouldMigrateStoreAutomatically = _shouldMigrateStoreAutomatically;
    copy->_shouldInferMappingModelAutomatically = _shouldInferMappingModelAutomatically;
    return copy;
}

- (NSString *) type {
    return _type;
}

- (void) setType: (NSString *) type {
    if (_type != type) {
        [_type release];
        _type = [type copy];
    }
}

- (NSString *) configuration {
    return _configuration;
}

- (void) setConfiguration: (NSString *) configuration {
    if (_configuration != configuration) {
        [_configuration release];
        _configuration = [configuration copy];
    }
}

- (NSURL *) URL {
    return _url;
}

- (void) setURL: (NSURL *) URL {
    if (_url != URL) {
        [_url release];
        _url = [URL copy];
    }
}

- (NSDictionary *) options {
    return [[_options copy] autorelease];
}

- (void) setOption: (NSObject *) option forKey: (NSString *) key {
    if (option == nil) {
        [_options removeObjectForKey: key];
    } else {
        [_options setObject: option forKey: key];
    }
}

- (BOOL) isReadOnly {
    return _readOnly;
}

- (void) setReadOnly: (BOOL) readOnly {
    _readOnly = readOnly;
    [_options setObject: [NSNumber numberWithBool: readOnly] forKey: kReadOnlyOption];
}

- (NSTimeInterval) timeout {
    return _timeout;
}

- (void) setTimeout: (NSTimeInterval) timeout {
    _timeout = timeout;
    [_options setObject: [NSNumber numberWithDouble: timeout] forKey: kTimeoutOption];
}

- (NSDictionary *) sqlitePragmas {
    return [[_sqlitePragmas copy] autorelease];
}

- (void) setValue: (NSObject *) value forPragmaNamed: (NSString *) name {
    if (value == nil) {
        [_sqlitePragmas removeObjectForKey: name];
    } else {
        [_sqlitePragmas setObject: value forKey: name];
    }
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@: %p> (type: %@, url: %@)", [self class], self, _type, _url];
}

@end
