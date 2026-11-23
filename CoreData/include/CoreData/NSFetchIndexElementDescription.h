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

#import <Foundation/Foundation.h>

@class NSPropertyDescription;
@class NSFetchIndexDescription;

#ifndef DARLING_NSFetchIndexElementType_DEFINED
#define DARLING_NSFetchIndexElementType_DEFINED
typedef NS_ENUM(NSUInteger, NSFetchIndexElementType) {
    NSFetchIndexElementTypeBinary,
    NSFetchIndexElementTypeRTree,
};
#endif

@interface NSFetchIndexElementDescription : NSObject <NSCoding> {
    NSPropertyDescription *_property;
    NSString *_propertyName;
    NSFetchIndexElementType _collationType;
    NSFetchIndexDescription *_indexDescription;
    BOOL _ascending;
}

- (instancetype) initWithProperty: (NSPropertyDescription *) property
                    collationType: (NSFetchIndexElementType) collationType;

@property (readonly, retain) NSPropertyDescription *property;
@property (readonly, retain) NSString *propertyName;
@property NSFetchIndexElementType collationType;
@property (getter = isAscending) BOOL ascending;
@property (readonly, nonatomic, assign) NSFetchIndexDescription *indexDescription;

@end
