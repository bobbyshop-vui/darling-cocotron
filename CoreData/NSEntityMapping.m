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

#include <CoreData/NSEntityMapping.h>
#import <Foundation/Foundation.h>

@implementation NSEntityMapping

- (void) dealloc {
    [_name release];
    [_sourceEntityName release];
    [_sourceEntityVersionHash release];
    [_destinationEntityName release];
    [_destinationEntityVersionHash release];
    [_attributeMappings release];
    [_relationshipMappings release];
    [_sourceExpression release];
    [_userInfo release];
    [_entityMigrationPolicyClassName release];
    [super dealloc];
}

- (NSString *) name {
    if (_name != nil)
        return _name;
    return [NSString stringWithFormat: @"%@->%@",
                                       _sourceEntityName ? _sourceEntityName : @"",
                                       _destinationEntityName ? _destinationEntityName : @""];
}

- (void) setName: (NSString *) value {
    value = [value copy];
    [_name release];
    _name = value;
}

- (NSString *) sourceEntityName {
    return _sourceEntityName;
}

- (void) setSourceEntityName: (NSString *) value {
    value = [value copy];
    [_sourceEntityName release];
    _sourceEntityName = value;
}

- (NSData *) sourceEntityVersionHash {
    return _sourceEntityVersionHash;
}

- (void) setSourceEntityVersionHash: (NSData *) value {
    value = [value copy];
    [_sourceEntityVersionHash release];
    _sourceEntityVersionHash = value;
}

- (NSString *) destinationEntityName {
    return _destinationEntityName;
}

- (void) setDestinationEntityName: (NSString *) value {
    value = [value copy];
    [_destinationEntityName release];
    _destinationEntityName = value;
}

- (NSData *) destinationEntityVersionHash {
    return _destinationEntityVersionHash;
}

- (void) setDestinationEntityVersionHash: (NSData *) value {
    value = [value copy];
    [_destinationEntityVersionHash release];
    _destinationEntityVersionHash = value;
}

- (NSArray *) attributeMappings {
    return _attributeMappings;
}

- (void) setAttributeMappings: (NSArray *) value {
    value = [value copy];
    [_attributeMappings release];
    _attributeMappings = value;
}

- (NSArray *) relationshipMappings {
    return _relationshipMappings;
}

- (void) setRelationshipMappings: (NSArray *) value {
    value = [value copy];
    [_relationshipMappings release];
    _relationshipMappings = value;
}

- (NSExpression *) sourceExpression {
    return _sourceExpression;
}

- (void) setSourceExpression: (NSExpression *) value {
    value = [value retain];
    [_sourceExpression release];
    _sourceExpression = value;
}

- (NSDictionary *) userInfo {
    return _userInfo;
}

- (void) setUserInfo: (NSDictionary *) value {
    value = [value copy];
    [_userInfo release];
    _userInfo = value;
}

- (NSString *) entityMigrationPolicyClassName {
    return _entityMigrationPolicyClassName;
}

- (void) setEntityMigrationPolicyClassName: (NSString *) value {
    value = [value copy];
    [_entityMigrationPolicyClassName release];
    _entityMigrationPolicyClassName = value;
}

- (NSEntityMappingType) mappingType {
    return _mappingType;
}

- (void) setMappingType: (NSEntityMappingType) value {
    _mappingType = value;
}

@end
