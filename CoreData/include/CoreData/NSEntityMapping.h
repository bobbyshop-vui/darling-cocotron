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

#import <Foundation/NSObject.h>

@class NSString, NSData, NSArray, NSMutableArray, NSDictionary, NSExpression;

typedef NS_ENUM(NSUInteger, NSEntityMappingType) {
    NSUndefinedEntityMappingType = 0x00,
    NSCustomEntityMappingType = 0x01,
    NSAddEntityMappingType = 0x02,
    NSRemoveEntityMappingType = 0x03,
    NSCopyEntityMappingType = 0x04,
    NSTransformEntityMappingType = 0x05,
};

@interface NSEntityMapping : NSObject {
    NSString *_name;
    NSEntityMappingType _mappingType;
    NSString *_sourceEntityName;
    NSData *_sourceEntityVersionHash;
    NSString *_destinationEntityName;
    NSData *_destinationEntityVersionHash;
    NSExpression *_sourceExpression;
    NSDictionary *_userInfo;
    NSString *_entityMigrationPolicyClassName;
    NSArray *_attributeMappings;
    NSArray *_relationshipMappings;
}

@property (null_resettable, copy) NSString *name;
@property () NSEntityMappingType mappingType;
@property (nullable, copy) NSString *sourceEntityName;
@property (nullable, copy) NSData *sourceEntityVersionHash;
@property (nullable, copy) NSString *destinationEntityName;
@property (nullable, copy) NSData *destinationEntityVersionHash;
@property (nullable, copy) NSArray *attributeMappings;
@property (nullable, copy) NSArray *relationshipMappings;
@property (nullable, strong) NSExpression *sourceExpression;
@property (nullable, copy) NSDictionary *userInfo;
@property (nullable, copy) NSString *entityMigrationPolicyClassName;

@end
