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

#import <CoreData/NSExpressionDescription.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSExpression.h>

@implementation NSExpressionDescription

// NSPropertyDescription's -init is abstract, and its accessors are not
// backed by storage, so this class supplies its own.
- (instancetype) init {
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding])
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ can not initWithCoder:%@", [self class],
                            [coder class]];
    [super initWithCoder: coder];
    _expression = [[coder decodeObjectForKey: @"NSExpression"] retain];
    _expressionResultType = [coder decodeIntForKey: @"NSExpressionResultType"];
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding])
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ can not encodeWithCoder:%@", [self class],
                            [coder class]];
    [coder encodeObject: _propertyName forKey: @"NSPropertyName"];
    [coder encodeObject: _expression forKey: @"NSExpression"];
    [coder encodeInt: _expressionResultType forKey: @"NSExpressionResultType"];
}

- (id) copyWithZone: (NSZone *) zone {
    NSExpressionDescription *copy = [[[self class] allocWithZone: zone] init];
    copy->_propertyName = [_propertyName copy];
    copy->_expression = [_expression copy];
    copy->_expressionResultType = _expressionResultType;
    copy->_optional = _optional;
    copy->_transient = _transient;
    copy->_userInfo = [_userInfo copy];
    copy->_validationPredicates = [_validationPredicates copy];
    copy->_validationWarnings = [_validationWarnings copy];
    return copy;
}

- (void) dealloc {
    [_propertyName release];
    [_expression release];
    [_userInfo release];
    [_validationPredicates release];
    [_validationWarnings release];
    [super dealloc];
}

- (NSExpression *) expression {
    return _expression;
}

- (void) setExpression: (NSExpression *) expression {
    if (_expression != expression) {
        [_expression release];
        _expression = [expression retain];
    }
}

- (NSAttributeType) expressionResultType {
    return _expressionResultType;
}

- (void) setExpressionResultType: (NSAttributeType) type {
    _expressionResultType = type;
}

- (void) setName: (NSString *) value {
    if (_propertyName != value) {
        [_propertyName release];
        _propertyName = [value copy];
    }
}

- (BOOL) isOptional {
    return _optional;
}

- (void) setOptional: (BOOL) value {
    _optional = value;
}

- (BOOL) isTransient {
    return _transient;
}

- (void) setTransient: (BOOL) value {
    _transient = value;
}

- (NSDictionary *) userInfo {
    return _userInfo;
}

- (void) setUserInfo: (NSDictionary *) value {
    if (_userInfo != value) {
        [_userInfo release];
        _userInfo = [value copy];
    }
}

- (NSArray *) validationPredicates {
    return _validationPredicates != nil ? _validationPredicates : [NSArray array];
}

- (NSArray *) validationWarnings {
    return _validationWarnings != nil ? _validationWarnings : [NSArray array];
}

- (void) setValidationPredicates: (NSArray *) predicates
          withValidationWarnings: (NSArray *) warnings {
    [_validationPredicates release];
    _validationPredicates = [predicates copy];
    [_validationWarnings release];
    _validationWarnings = [warnings copy];
}

@end
