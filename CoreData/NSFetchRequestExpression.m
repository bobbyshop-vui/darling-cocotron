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

#import <CoreData/NSFetchRequestExpression.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSManagedObjectContext.h>
#import <Foundation/Foundation.h>

@implementation NSFetchRequestExpression

+ (NSExpression *) expressionForFetch: (NSExpression *) fetch
                              context: (NSExpression *) context
                            countOnly: (BOOL) countFlag
{
    NSFetchRequestExpression *result = [[self alloc]
            initWithExpressionType: NSFetchRequestExpressionType];

    result->_fetchRequest = [fetch retain];
    result->_managedObjectContext = [context retain];
    result->_isCountOnly = countFlag;
    return [result autorelease];
}

- (void) dealloc {
    [_fetchRequest release];
    [_managedObjectContext release];
    [super dealloc];
}

- (NSExpression *) requestExpression {
    return _fetchRequest;
}

- (NSExpression *) contextExpression {
    return _managedObjectContext;
}

- (BOOL) isCountOnlyRequest {
    return _isCountOnly;
}

- (id) copyWithZone: (NSZone *) zone {
    return [[[self class] expressionForFetch: _fetchRequest
                                     context: _managedObjectContext
                                   countOnly: _isCountOnly] retain];
}

- (BOOL) isEqual: (id) other {
    if (other == self)
        return YES;
    if (![other isKindOfClass: [NSFetchRequestExpression class]])
        return NO;

    NSFetchRequestExpression *o = other;

    return _isCountOnly == o->_isCountOnly &&
           (_fetchRequest == o->_fetchRequest ||
            [_fetchRequest isEqual: o->_fetchRequest]) &&
           (_managedObjectContext == o->_managedObjectContext ||
            [_managedObjectContext isEqual: o->_managedObjectContext]);
}

- (NSUInteger) hash {
    return [_fetchRequest hash] ^ ([_managedObjectContext hash] << 1) ^
           (_isCountOnly ? 1 : 0);
}

- (id) expressionValueWithObject: (id) object
                         context: (NSMutableDictionary *) context
{
    NSFetchRequest *request =
            [_fetchRequest expressionValueWithObject: object context: context];
    NSManagedObjectContext *moc = [_managedObjectContext
            expressionValueWithObject: object
                              context: context];

    if (![request isKindOfClass: [NSFetchRequest class]] ||
        ![moc isKindOfClass: [NSManagedObjectContext class]])
        return nil;

    NSError *error = nil;

    if (_isCountOnly)
        return [NSNumber
                numberWithUnsignedInteger: [moc countForFetchRequest: request
                                                               error: &error]];

    return [moc executeFetchRequest: request error: &error];
}

@end
