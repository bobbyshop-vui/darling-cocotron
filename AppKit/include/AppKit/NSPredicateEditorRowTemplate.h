#import <Foundation/NSObject.h>
#import <Foundation/NSComparisonPredicate.h>

@class NSArray, NSPredicate, NSExpression, NSEntityDescription, NSView;

@interface NSPredicateEditorRowTemplate : NSObject <NSCoding, NSCopying> {
    NSArray *_leftExpressions;
    NSArray *_rightExpressions;
    NSArray *_operators;
    NSArray *_compoundTypes;
    NSUInteger _modifier;
    NSUInteger _options;
    NSUInteger _rightAttributeType;
    NSPredicate *_predicate;
    NSArray *_views;
}

+ (NSArray *) templatesWithAttributeKeyPaths: (NSArray *) keyPaths
                         inEntityDescription: (NSEntityDescription *) entityDescription;

- (instancetype) initWithCompoundTypes: (NSArray *) compoundTypes;
- (instancetype) initWithLeftExpressions: (NSArray *) leftExpressions
            rightExpressionAttributeType: (NSUInteger) attributeType
                                modifier: (NSComparisonPredicateModifier) modifier
                               operators: (NSArray *) operators
                                 options: (NSUInteger) options;
- (instancetype) initWithLeftExpressions: (NSArray *) leftExpressions
                        rightExpressions: (NSArray *) rightExpressions
                                modifier: (NSComparisonPredicateModifier) modifier
                               operators: (NSArray *) operators
                                 options: (NSUInteger) options;

- (double) matchForPredicate: (NSPredicate *) predicate;
- (NSArray *) templateViews;
- (void) setPredicate: (NSPredicate *) predicate;
- (NSPredicate *) predicateWithSubpredicates: (NSArray *) subpredicates;
- (NSArray *) displayableSubpredicatesOfPredicate: (NSPredicate *) predicate;

- (NSArray *) leftExpressions;
- (NSArray *) rightExpressions;
- (NSUInteger) rightExpressionAttributeType;
- (NSComparisonPredicateModifier) modifier;
- (NSArray *) operators;
- (NSUInteger) options;
- (NSArray *) compoundTypes;

@end
