#import <AppKit/NSPredicateEditorRowTemplate.h>
#import <Foundation/Foundation.h>

// CoreData is not linked into AppKit; talk to its objects through these selectors.
@protocol _NSPERTEntity
- (NSDictionary *) attributesByName;
@end
@protocol _NSPERTAttribute
- (NSUInteger) attributeType;
@end

@implementation NSPredicateEditorRowTemplate

+ (NSArray *) templatesWithAttributeKeyPaths: (NSArray *) keyPaths
                         inEntityDescription: (NSEntityDescription *) entityDescription
{
    // Group the key paths by attribute type, as AppKit does: one template per type.
    NSMutableArray *types = [NSMutableArray array];
    NSMutableDictionary *byType = [NSMutableDictionary dictionary];
    NSMutableArray *result = [NSMutableArray array];
    NSDictionary *attributes = [(id<_NSPERTEntity>) entityDescription attributesByName];

    for (NSString *keyPath in keyPaths) {
        id<_NSPERTAttribute> attribute = [attributes objectForKey: keyPath];
        if (attribute == nil)
            continue;
        NSNumber *type = [NSNumber numberWithUnsignedInteger: [attribute attributeType]];
        NSMutableArray *list = [byType objectForKey: type];
        if (list == nil) {
            list = [NSMutableArray array];
            [byType setObject: list forKey: type];
            [types addObject: type];
        }
        [list addObject: [NSExpression expressionForKeyPath: keyPath]];
    }

    for (NSNumber *type in types) {
        NSUInteger t = [type unsignedIntegerValue];
        NSArray *operators;
        NSUInteger options = 0;

        if (t == 700) { // string
            operators = [NSArray arrayWithObjects:
                    [NSNumber numberWithUnsignedInteger: NSContainsPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSBeginsWithPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSEndsWithPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSEqualToPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSNotEqualToPredicateOperatorType], nil];
            options = NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption;
        } else if (t == 800 || t == 1000) { // bool, binary
            operators = [NSArray arrayWithObjects:
                    [NSNumber numberWithUnsignedInteger: NSEqualToPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSNotEqualToPredicateOperatorType], nil];
        } else {
            operators = [NSArray arrayWithObjects:
                    [NSNumber numberWithUnsignedInteger: NSEqualToPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSNotEqualToPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSLessThanPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSLessThanOrEqualToPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSGreaterThanPredicateOperatorType],
                    [NSNumber numberWithUnsignedInteger: NSGreaterThanOrEqualToPredicateOperatorType], nil];
        }

        NSPredicateEditorRowTemplate *template = [[NSPredicateEditorRowTemplate alloc]
                initWithLeftExpressions: [byType objectForKey: type]
           rightExpressionAttributeType: t
                               modifier: NSDirectPredicateModifier
                              operators: operators
                                options: options];
        [result addObject: template];
        [template release];
    }
    return result;
}

- (instancetype) initWithCompoundTypes: (NSArray *) compoundTypes {
    if ((self = [super init]) != nil) {
        _compoundTypes = [compoundTypes copy];
    }
    return self;
}

- (instancetype) initWithLeftExpressions: (NSArray *) leftExpressions
            rightExpressionAttributeType: (NSUInteger) attributeType
                                modifier: (NSComparisonPredicateModifier) modifier
                               operators: (NSArray *) operators
                                 options: (NSUInteger) options
{
    if ((self = [super init]) != nil) {
        _leftExpressions = [leftExpressions copy];
        _rightAttributeType = attributeType;
        _modifier = modifier;
        _operators = [operators copy];
        _options = options;
    }
    return self;
}

- (instancetype) initWithLeftExpressions: (NSArray *) leftExpressions
                        rightExpressions: (NSArray *) rightExpressions
                                modifier: (NSComparisonPredicateModifier) modifier
                               operators: (NSArray *) operators
                                 options: (NSUInteger) options
{
    if ((self = [super init]) != nil) {
        _leftExpressions = [leftExpressions copy];
        _rightExpressions = [rightExpressions copy];
        _modifier = modifier;
        _operators = [operators copy];
        _options = options;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super init]) != nil) {
        if ([coder allowsKeyedCoding]) {
            _leftExpressions = [[coder decodeObjectForKey: @"NSLeftExpressions"] copy];
            _rightExpressions = [[coder decodeObjectForKey: @"NSRightExpressions"] copy];
            _operators = [[coder decodeObjectForKey: @"NSOperators"] copy];
            _compoundTypes = [[coder decodeObjectForKey: @"NSCompoundTypes"] copy];
            _modifier = [coder decodeIntegerForKey: @"NSModifier"];
            _options = [coder decodeIntegerForKey: @"NSOptions"];
            _rightAttributeType = [coder decodeIntegerForKey: @"NSRightAttributeType"];
        }
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject: _leftExpressions forKey: @"NSLeftExpressions"];
        [coder encodeObject: _rightExpressions forKey: @"NSRightExpressions"];
        [coder encodeObject: _operators forKey: @"NSOperators"];
        [coder encodeObject: _compoundTypes forKey: @"NSCompoundTypes"];
        [coder encodeInteger: _modifier forKey: @"NSModifier"];
        [coder encodeInteger: _options forKey: @"NSOptions"];
        [coder encodeInteger: _rightAttributeType forKey: @"NSRightAttributeType"];
    }
}

- (id) copyWithZone: (NSZone *) zone {
    NSPredicateEditorRowTemplate *copy = [[[self class] allocWithZone: zone] init];
    copy->_leftExpressions = [_leftExpressions copy];
    copy->_rightExpressions = [_rightExpressions copy];
    copy->_operators = [_operators copy];
    copy->_compoundTypes = [_compoundTypes copy];
    copy->_modifier = _modifier;
    copy->_options = _options;
    copy->_rightAttributeType = _rightAttributeType;
    copy->_predicate = [_predicate retain];
    return copy;
}

- (void) dealloc {
    [_leftExpressions release];
    [_rightExpressions release];
    [_operators release];
    [_compoundTypes release];
    [_predicate release];
    [_views release];
    [super dealloc];
}

- (double) matchForPredicate: (NSPredicate *) predicate {
    if ([predicate isKindOfClass: [NSCompoundPredicate class]]) {
        NSNumber *type = [NSNumber numberWithUnsignedInteger: [(NSCompoundPredicate *) predicate compoundPredicateType]];
        return [_compoundTypes containsObject: type] ? 1.0 : 0.0;
    }
    if ([predicate isKindOfClass: [NSComparisonPredicate class]] && _leftExpressions != nil) {
        NSComparisonPredicate *p = (NSComparisonPredicate *) predicate;
        NSNumber *op = [NSNumber numberWithUnsignedInteger: [p predicateOperatorType]];

        if ([p comparisonPredicateModifier] != _modifier)
            return 0.0;
        if (![_leftExpressions containsObject: [p leftExpression]])
            return 0.0;
        if (_operators != nil && ![_operators containsObject: op])
            return 0.0;
        if (_rightExpressions != nil && ![_rightExpressions containsObject: [p rightExpression]])
            return 0.0;
        return 1.0;
    }
    return 0.0;
}

- (NSArray *) templateViews {
    // No view construction is available; the editor UI is not built from these.
    if (_views == nil)
        _views = [[NSArray alloc] init];
    return _views;
}

- (void) setPredicate: (NSPredicate *) predicate {
    predicate = [predicate retain];
    [_predicate release];
    _predicate = predicate;
}

- (NSPredicate *) predicateWithSubpredicates: (NSArray *) subpredicates {
    if (_compoundTypes != nil) {
        NSCompoundPredicateType type = [_compoundTypes count] > 0 ? [[_compoundTypes objectAtIndex: 0] unsignedIntegerValue] : NSAndPredicateType;
        if ([_predicate isKindOfClass: [NSCompoundPredicate class]])
            type = [(NSCompoundPredicate *) _predicate compoundPredicateType];
        return [[[NSCompoundPredicate alloc] initWithType: type
                                            subpredicates: subpredicates ? subpredicates : [NSArray array]] autorelease];
    }

    if ([_predicate isKindOfClass: [NSComparisonPredicate class]])
        return _predicate;

    NSExpression *left = [_leftExpressions firstObject];
    NSExpression *right = [_rightExpressions firstObject];
    if (left == nil)
        return nil;
    if (right == nil)
        right = [NSExpression expressionForConstantValue: nil];
    NSPredicateOperatorType op = [_operators count] > 0 ? [[_operators objectAtIndex: 0] unsignedIntegerValue] : NSEqualToPredicateOperatorType;
    return [NSComparisonPredicate predicateWithLeftExpression: left
                                              rightExpression: right
                                                     modifier: _modifier
                                                         type: op
                                                      options: _options];
}

- (NSArray *) displayableSubpredicatesOfPredicate: (NSPredicate *) predicate {
    if ([predicate isKindOfClass: [NSCompoundPredicate class]])
        return [(NSCompoundPredicate *) predicate subpredicates];
    return nil;
}

- (NSArray *) leftExpressions {
    return _leftExpressions;
}

- (NSArray *) rightExpressions {
    return _rightExpressions;
}

- (NSUInteger) rightExpressionAttributeType {
    return _rightAttributeType;
}

- (NSComparisonPredicateModifier) modifier {
    return (NSComparisonPredicateModifier) _modifier;
}

- (NSArray *) operators {
    return _operators;
}

- (NSUInteger) options {
    return _options;
}

- (NSArray *) compoundTypes {
    return _compoundTypes;
}

@end
