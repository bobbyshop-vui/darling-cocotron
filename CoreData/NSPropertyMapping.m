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

#import <CoreData/NSPropertyMapping.h>

@implementation NSPropertyMapping

- (void)dealloc
{
    [_mappingName release];
    [_mappingValueExpression release];
    [_mappingUserInfo release];
    [super dealloc];
}

- (NSString *)name
{
    return _mappingName;
}

- (void)setName:(NSString *)name
{
    name = [name copy];
    [_mappingName release];
    _mappingName = name;
}

- (NSExpression *)valueExpression
{
    return _mappingValueExpression;
}

- (void)setValueExpression:(NSExpression *)valueExpression
{
    valueExpression = [valueExpression retain];
    [_mappingValueExpression release];
    _mappingValueExpression = valueExpression;
}

- (NSDictionary *)userInfo
{
    return _mappingUserInfo;
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    userInfo = [userInfo copy];
    [_mappingUserInfo release];
    _mappingUserInfo = userInfo;
}

@end
