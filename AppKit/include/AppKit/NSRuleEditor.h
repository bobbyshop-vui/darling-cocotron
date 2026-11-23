#import <AppKit/AppKitExport.h>
#import <AppKit/NSControl.h>
#import <Foundation/NSString.h>

@class NSIndexSet, NSPredicate, NSArray;
@protocol NSRuleEditorDelegate;

APPKIT_EXPORT NSString *const NSRuleEditorRowsDidChangeNotification;

typedef NSString *NSRuleEditorPredicatePartKey;

APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateLeftExpression;
APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateRightExpression;
APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateComparisonModifier;
APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateOptions;
APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateOperatorType;
APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateCustomSelector;
APPKIT_EXPORT NSRuleEditorPredicatePartKey const NSRuleEditorPredicateCompoundType;

typedef NS_ENUM(NSUInteger, NSRuleEditorNestingMode) {
    NSRuleEditorNestingModeSingle,
    NSRuleEditorNestingModeList,
    NSRuleEditorNestingModeCompound,
    NSRuleEditorNestingModeSimple
};

typedef NS_ENUM(NSUInteger, NSRuleEditorRowType) {
    NSRuleEditorRowTypeSimple,
    NSRuleEditorRowTypeCompound
};

@interface NSRuleEditor : NSControl <NSCoding> {
    id _delegate;
    NSString *_formattingStringsFilename;
    NSRuleEditorNestingMode _nestingMode;
    CGFloat _rowHeight;
    BOOL _canRemoveAllRows;
    NSMutableArray *_rows;
    NSIndexSet *_selectedRowIndexes;
}

- (id<NSRuleEditorDelegate>) delegate;
- (void) setDelegate: (id<NSRuleEditorDelegate>) delegate;

- (NSString *) formattingStringsFilename;
- (void) setFormattingStringsFilename: (NSString *) filename;

- (void) reloadCriteria;

- (NSRuleEditorNestingMode) nestingMode;
- (void) setNestingMode: (NSRuleEditorNestingMode) mode;

- (CGFloat) rowHeight;
- (void) setRowHeight: (CGFloat) height;

- (BOOL) canRemoveAllRows;
- (void) setCanRemoveAllRows: (BOOL) flag;

- (NSPredicate *) predicate;
- (NSPredicate *) predicateForRow: (NSInteger) row;

- (NSInteger) numberOfRows;
- (NSIndexSet *) subrowIndexesForRow: (NSInteger) rowIndex;
- (NSArray *) criteriaForRow: (NSInteger) row;
- (NSArray *) displayValuesForRow: (NSInteger) row;
- (NSRuleEditorRowType) rowTypeForRow: (NSInteger) rowIndex;

- (void) addRow: (id) sender;
- (void) insertRowAtIndex: (NSInteger) rowIndex
                 withType: (NSRuleEditorRowType) rowType
            asSubrowOfRow: (NSInteger) parentRow
                  animate: (BOOL) shouldAnimate;
- (void) setCriteria: (NSArray *) criteria
        andDisplayValues: (NSArray *) values
           forRowAtIndex: (NSInteger) rowIndex;
- (void) removeRowAtIndex: (NSInteger) rowIndex;
- (void) removeRowsAtIndexes: (NSIndexSet *) rowIndexes
              includeSubrows: (BOOL) includeSubrows;

- (NSIndexSet *) selectedRowIndexes;
- (void) selectRowIndexes: (NSIndexSet *) indexes
        byExtendingSelection: (BOOL) extend;

@end

@protocol NSRuleEditorDelegate <NSObject>

@required
- (NSInteger) ruleEditor: (NSRuleEditor *) editor
        numberOfChildrenForCriterion: (id) criterion
                         withRowType: (NSRuleEditorRowType) rowType;
- (id) ruleEditor: (NSRuleEditor *) editor
                    child: (NSInteger) index
             forCriterion: (id) criterion
              withRowType: (NSRuleEditorRowType) rowType;
- (id) ruleEditor: (NSRuleEditor *) editor
        displayValueForCriterion: (id) criterion
                           inRow: (NSInteger) row;

@optional
- (NSDictionary *) ruleEditor: (NSRuleEditor *) editor
        predicatePartsForCriterion: (id) criterion
                  withDisplayValue: (id) value
                             inRow: (NSInteger) row;
- (void) ruleEditorRowsDidChange: (NSNotification *) notification;

@end
