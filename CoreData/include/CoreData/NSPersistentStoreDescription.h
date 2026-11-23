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

#import <Foundation/Foundation.h>

@interface NSPersistentStoreDescription : NSObject <NSCopying> {
    NSString *_type;
    NSString *_configuration;
    NSURL *_url;
    NSMutableDictionary *_options;
    NSMutableDictionary *_sqlitePragmas;
    NSTimeInterval _timeout;
    BOOL _readOnly;
    BOOL _shouldAddStoreAsynchronously;
    BOOL _shouldMigrateStoreAutomatically;
    BOOL _shouldInferMappingModelAutomatically;
}

+ (instancetype) persistentStoreDescriptionWithURL: (NSURL *) URL;
- (instancetype) initWithURL: (NSURL *) url;

@property (copy) NSString *type;
@property (copy) NSString *configuration;
@property (copy) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *options;
- (void) setOption: (NSObject *) option forKey: (NSString *) key;

@property (getter = isReadOnly) BOOL readOnly;
@property NSTimeInterval timeout;
@property (nonatomic, copy, readonly) NSDictionary *sqlitePragmas;
- (void) setValue: (NSObject *) value forPragmaNamed: (NSString *) name;

@property BOOL shouldAddStoreAsynchronously;
@property BOOL shouldMigrateStoreAutomatically;
@property BOOL shouldInferMappingModelAutomatically;

@end
