#import <AppKit/NSRuleEditor.h>
#import <Foundation/Foundation.h>

NSString *const NSRuleEditorRowsDidChangeNotification =
        @"NSRuleEditorRowsDidChangeNotification";

NSRuleEditorPredicatePartKey const NSRuleEditorPredicateLeftExpression =
        @"NSRuleEditorPredicateLeftExpression";
NSRuleEditorPredicatePartKey const NSRuleEditorPredicateRightExpression =
        @"NSRuleEditorPredicateRightExpression";
NSRuleEditorPredicatePartKey const NSRuleEditorPredicateComparisonModifier =
        @"NSRuleEditorPredicateComparisonModifier";
NSRuleEditorPredicatePartKey const NSRuleEditorPredicateOptions =
        @"NSRuleEditorPredicateOptions";
NSRuleEditorPredicatePartKey const NSRuleEditorPredicateOperatorType =
        @"NSRuleEditorPredicateOperatorType";
NSRuleEditorPredicatePartKey const NSRuleEditorPredicateCustomSelector =
        @"NSRuleEditorPredicateCustomSelector";
NSRuleEditorPredicatePartKey const NSRuleEditorPredicateCompoundType =
        @"NSRuleEditorPredicateCompoundType";

// Model object for one row; rows are kept in a flat, depth-first ordered array.
@interface _NSRuleEditorRowInfo : NSObject {
@public
    NSRuleEditorRowType type;
    NSArray *criteria;
    NSArray *displayValues;
    _NSRuleEditorRowInfo *parent; // not retained
}
@end

@implementation _NSRuleEditorRowInfo
- (void) dealloc {
    [criteria release];
    [displayValues release];
    [super dealloc];
}
@end

@implementation NSRuleEditor

- (void) _commonInit {
    _nestingMode = NSRuleEditorNestingModeCompound;
    _rowHeight = 25.0;
    _canRemoveAllRows = YES;
    if (_rows == nil)
        _rows = [[NSMutableArray alloc] init];
    if (_selectedRowIndexes == nil)
        _selectedRowIndexes = [[NSIndexSet alloc] init];
}

- initWithFrame: (NSRect) frame {
    if ((self = [super initWithFrame: frame]) != nil) {
        [self _commonInit];
    }
    return self;
}

- initWithCoder: (NSCoder *) coder {
    [super initWithCoder: coder];

    [self _commonInit];
    if ([coder allowsKeyedCoding]) {
        if ([coder containsValueForKey: @"NSRuleEditorNestingMode"])
            _nestingMode = [coder decodeIntegerForKey: @"NSRuleEditorNestingMode"];
        if ([coder containsValueForKey: @"NSRuleEditorRowHeight"])
            _rowHeight = [coder decodeDoubleForKey: @"NSRuleEditorRowHeight"];
        if ([coder containsValueForKey: @"NSRuleEditorCanRemoveAllRows"])
            _canRemoveAllRows = [coder decodeBoolForKey: @"NSRuleEditorCanRemoveAllRows"];
        if ([coder containsValueForKey: @"NSRuleEditorFormattingStringsFilename"]) {
            _formattingStringsFilename = [[coder decodeObjectForKey:
                    @"NSRuleEditorFormattingStringsFilename"] copy];
        }
    }

    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder: coder];
    if ([coder allowsKeyedCoding]) {
        [coder encodeInteger: _nestingMode forKey: @"NSRuleEditorNestingMode"];
        [coder encodeDouble: _rowHeight forKey: @"NSRuleEditorRowHeight"];
        [coder encodeBool: _canRemoveAllRows forKey: @"NSRuleEditorCanRemoveAllRows"];
        if (_formattingStringsFilename != nil) {
            [coder encodeObject: _formattingStringsFilename
                         forKey: @"NSRuleEditorFormattingStringsFilename"];
        }
    }
}

- (void) dealloc {
    [_formattingStringsFilename release];
    [_rows release];
    [_selectedRowIndexes release];
    [super dealloc];
}

- (id<NSRuleEditorDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate: (id<NSRuleEditorDelegate>) delegate {
    _delegate = delegate;
    [self reloadCriteria];
}

- (NSString *) formattingStringsFilename {
    return _formattingStringsFilename;
}

- (void) setFormattingStringsFilename: (NSString *) filename {
    filename = [filename copy];
    [_formattingStringsFilename release];
    _formattingStringsFilename = filename;
}

- (NSRuleEditorNestingMode) nestingMode {
    return _nestingMode;
}

- (void) setNestingMode: (NSRuleEditorNestingMode) mode {
    _nestingMode = mode;
}

- (CGFloat) rowHeight {
    return _rowHeight;
}

- (void) setRowHeight: (CGFloat) height {
    _rowHeight = height;
    [self setNeedsDisplay: YES];
}

- (BOOL) canRemoveAllRows {
    return _canRemoveAllRows;
}

- (void) setCanRemoveAllRows: (BOOL) flag {
    _canRemoveAllRows = flag;
}

#pragma mark - Row model

- (_NSRuleEditorRowInfo *) _rowAtIndex: (NSInteger) index {
    if (index < 0 || index >= (NSInteger) [_rows count])
        return nil;
    return [_rows objectAtIndex: index];
}

- (void) _postRowsDidChange {
    NSNotification *note = [NSNotification
            notificationWithName: NSRuleEditorRowsDidChangeNotification
                          object: self];
    if ([_delegate respondsToSelector: @selector(ruleEditorRowsDidChange:)])
        [_delegate ruleEditorRowsDidChange: note];
    [[NSNotificationCenter defaultCenter] postNotification: note];
    [self setNeedsDisplay: YES];
}

// Fill the row with the first path through the delegate's criteria tree.
- (void) _populateRow: (_NSRuleEditorRowInfo *) row atIndex: (NSInteger) index {
    NSMutableArray *criteria = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];

    if (_delegate != nil) {
        id criterion = nil;
        for (;;) {
            NSInteger count = [_delegate ruleEditor: self
                       numberOfChildrenForCriterion: criterion
                                        withRowType: row->type];
            if (count <= 0)
                break;
            criterion = [_delegate ruleEditor: self
                                        child: 0
                                 forCriterion: criterion
                                  withRowType: row->type];
            if (criterion == nil)
                break;
            id value = [_delegate ruleEditor: self
                    displayValueForCriterion: criterion
                                       inRow: index];
            [criteria addObject: criterion];
            [values addObject: value != nil ? value : (id) [NSNull null]];
        }
    }

    [row->criteria release];
    row->criteria = [criteria copy];
    [row->displayValues release];
    row->displayValues = [values copy];
}

- (void) reloadCriteria {
    NSUInteger i, count = [_rows count];
    for (i = 0; i < count; i++)
        [self _populateRow: [_rows objectAtIndex: i] atIndex: i];
    [self setNeedsDisplay: YES];
}

- (NSInteger) numberOfRows {
    return [_rows count];
}

- (NSIndexSet *) subrowIndexesForRow: (NSInteger) rowIndex {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    NSUInteger i, count = [_rows count];

    if (rowIndex >= (NSInteger) count)
        return set;

    _NSRuleEditorRowInfo *parent = rowIndex < 0 ? nil : [_rows objectAtIndex: rowIndex];
    for (i = 0; i < count; i++) {
        if (((_NSRuleEditorRowInfo *) [_rows objectAtIndex: i])->parent == parent)
            [set addIndex: i];
    }
    return set;
}

- (NSArray *) criteriaForRow: (NSInteger) row {
    _NSRuleEditorRowInfo *info = [self _rowAtIndex: row];
    return info != nil ? info->criteria : [NSArray array];
}

- (NSArray *) displayValuesForRow: (NSInteger) row {
    _NSRuleEditorRowInfo *info = [self _rowAtIndex: row];
    return info != nil ? info->displayValues : [NSArray array];
}

- (NSRuleEditorRowType) rowTypeForRow: (NSInteger) rowIndex {
    _NSRuleEditorRowInfo *info = [self _rowAtIndex: rowIndex];
    return info != nil ? info->type : NSRuleEditorRowTypeSimple;
}

- (NSInteger) parentRowForRow: (NSInteger) rowIndex {
    _NSRuleEditorRowInfo *info = [self _rowAtIndex: rowIndex];
    if (info == nil || info->parent == nil)
        return -1;
    return [_rows indexOfObjectIdenticalTo: info->parent];
}

- (NSInteger) rowForDisplayValue: (id) displayValue {
    NSUInteger i, count = [_rows count];
    for (i = 0; i < count; i++) {
        if ([((_NSRuleEditorRowInfo *) [_rows objectAtIndex: i])->displayValues
                    containsObject: displayValue])
            return i;
    }
    return NSNotFound;
}

- (void) addRow: (id) sender {
    NSRuleEditorRowType type = NSRuleEditorRowTypeSimple;
    NSInteger parent = -1;

    if (_nestingMode == NSRuleEditorNestingModeSingle && [_rows count] > 0)
        return;

    if ((_nestingMode == NSRuleEditorNestingModeSimple ||
         _nestingMode == NSRuleEditorNestingModeCompound) &&
        [_rows count] > 0 && [self rowTypeForRow: 0] == NSRuleEditorRowTypeCompound) {
        parent = 0;
    }

    [self insertRowAtIndex: [_rows count]
                  withType: type
             asSubrowOfRow: parent
                   animate: NO];
}

- (void) insertRowAtIndex: (NSInteger) rowIndex
                 withType: (NSRuleEditorRowType) rowType
            asSubrowOfRow: (NSInteger) parentRow
                  animate: (BOOL) shouldAnimate
{
    if (rowIndex < 0 || rowIndex > (NSInteger) [_rows count])
        [NSException raise: NSRangeException
                    format: @"NSRuleEditor: row index %ld out of range",
                            (long) rowIndex];
    if (parentRow >= (NSInteger) [_rows count])
        [NSException raise: NSRangeException
                    format: @"NSRuleEditor: parent row %ld out of range",
                            (long) parentRow];

    _NSRuleEditorRowInfo *row = [[_NSRuleEditorRowInfo alloc] init];
    row->type = rowType;
    row->parent = parentRow < 0 ? nil : [_rows objectAtIndex: parentRow];
    [_rows insertObject: row atIndex: rowIndex];
    [row release];

    [self _populateRow: row atIndex: rowIndex];
    [self _postRowsDidChange];
}

- (void) setCriteria: (NSArray *) criteria
        andDisplayValues: (NSArray *) values
           forRowAtIndex: (NSInteger) rowIndex
{
    _NSRuleEditorRowInfo *row = [self _rowAtIndex: rowIndex];
    if (row == nil)
        [NSException raise: NSRangeException
                    format: @"NSRuleEditor: row index %ld out of range",
                            (long) rowIndex];

    criteria = [criteria copy];
    values = [values copy];
    [row->criteria release];
    [row->displayValues release];
    row->criteria = criteria;
    row->displayValues = values;
    [self setNeedsDisplay: YES];
}

- (void) removeRowAtIndex: (NSInteger) rowIndex {
    [self removeRowsAtIndexes: [NSIndexSet indexSetWithIndex: rowIndex]
               includeSubrows: NO];
}

- (void) removeRowsAtIndexes: (NSIndexSet *) rowIndexes
              includeSubrows: (BOOL) includeSubrows
{
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    NSUInteger i, count = [_rows count];

    for (i = 0; i < count; i++) {
        _NSRuleEditorRowInfo *row = [_rows objectAtIndex: i];
        BOOL remove = [rowIndexes containsIndex: i];
        if (!remove && includeSubrows) {
            _NSRuleEditorRowInfo *ancestor = row->parent;
            while (ancestor != nil && !remove) {
                remove = [rowIndexes containsIndex:
                                [_rows indexOfObjectIdenticalTo: ancestor]];
                ancestor = ancestor->parent;
            }
        }
        if (remove)
            [toRemove addIndex: i];
    }

    if ([toRemove count] == 0)
        return;
    if (!_canRemoveAllRows && [toRemove count] >= count)
        return;

    // Subrows that survive move up to the removed row's parent.
    for (i = 0; i < count; i++) {
        _NSRuleEditorRowInfo *row = [_rows objectAtIndex: i];
        if ([toRemove containsIndex: i])
            continue;
        while (row->parent != nil &&
               [toRemove containsIndex: [_rows indexOfObjectIdenticalTo: row->parent]])
            row->parent = row->parent->parent;
    }

    [_rows removeObjectsAtIndexes: toRemove];

    NSMutableIndexSet *selection = [NSMutableIndexSet indexSet];
    NSUInteger idx = [_selectedRowIndexes firstIndex];
    while (idx != NSNotFound) {
        if (![toRemove containsIndex: idx])
            [selection addIndex: idx - [toRemove countOfIndexesInRange: NSMakeRange(0, idx)]];
        idx = [_selectedRowIndexes indexGreaterThanIndex: idx];
    }
    [_selectedRowIndexes release];
    _selectedRowIndexes = [selection copy];

    [self _postRowsDidChange];
}

- (NSIndexSet *) selectedRowIndexes {
    return _selectedRowIndexes;
}

- (void) selectRowIndexes: (NSIndexSet *) indexes
        byExtendingSelection: (BOOL) extend
{
    NSMutableIndexSet *selection = extend ? [[_selectedRowIndexes mutableCopy] autorelease]
                                          : [NSMutableIndexSet indexSet];
    NSUInteger idx = [indexes firstIndex];
    while (idx != NSNotFound) {
        if (idx < [_rows count])
            [selection addIndex: idx];
        idx = [indexes indexGreaterThanIndex: idx];
    }
    [_selectedRowIndexes release];
    _selectedRowIndexes = [selection copy];
    [self setNeedsDisplay: YES];
}

#pragma mark - Predicate

- (NSPredicate *) _predicateForRowInfo: (_NSRuleEditorRowInfo *) info {
    NSInteger index = [_rows indexOfObjectIdenticalTo: info];
    if (![_delegate respondsToSelector: @selector
                    (ruleEditor:predicatePartsForCriterion:withDisplayValue:inRow:)])
        return nil;

    NSMutableDictionary *parts = [NSMutableDictionary dictionary];
    NSUInteger i, count = [info->criteria count];
    for (i = 0; i < count; i++) {
        id value = i < [info->displayValues count] ? [info->displayValues objectAtIndex: i] : nil;
        NSDictionary *p = [_delegate ruleEditor: self
                     predicatePartsForCriterion: [info->criteria objectAtIndex: i]
                               withDisplayValue: value
                                          inRow: index];
        if (p != nil)
            [parts addEntriesFromDictionary: p];
    }

    NSNumber *compound = [parts objectForKey: NSRuleEditorPredicateCompoundType];
    if (compound != nil) {
        NSMutableArray *subpredicates = [NSMutableArray array];
        NSUInteger r, rows = [_rows count];
        for (r = 0; r < rows; r++) {
            _NSRuleEditorRowInfo *sub = [_rows objectAtIndex: r];
            if (sub->parent == info) {
                NSPredicate *p = [self _predicateForRowInfo: sub];
                if (p != nil)
                    [subpredicates addObject: p];
            }
        }
        return [[[NSCompoundPredicate alloc]
                initWithType: (NSCompoundPredicateType) [compound unsignedIntegerValue]
               subpredicates: subpredicates] autorelease];
    }

    NSExpression *left = [parts objectForKey: NSRuleEditorPredicateLeftExpression];
    NSExpression *right = [parts objectForKey: NSRuleEditorPredicateRightExpression];
    if (left == nil || right == nil)
        return nil;

    NSComparisonPredicateModifier modifier = NSDirectPredicateModifier;
    NSNumber *number = [parts objectForKey: NSRuleEditorPredicateComparisonModifier];
    if (number != nil)
        modifier = (NSComparisonPredicateModifier) [number unsignedIntegerValue];

    NSComparisonPredicateOptions options = 0;
    number = [parts objectForKey: NSRuleEditorPredicateOptions];
    if (number != nil)
        options = (NSComparisonPredicateOptions) [number unsignedIntegerValue];

    NSString *selectorName = [parts objectForKey: NSRuleEditorPredicateCustomSelector];
    if (selectorName != nil) {
        return [NSComparisonPredicate predicateWithLeftExpression: left
                                                  rightExpression: right
                                                   customSelector: NSSelectorFromString(selectorName)];
    }

    number = [parts objectForKey: NSRuleEditorPredicateOperatorType];
    if (number == nil)
        return nil;
    return [NSComparisonPredicate
            predicateWithLeftExpression: left
                        rightExpression: right
                               modifier: modifier
                                   type: (NSPredicateOperatorType) [number unsignedIntegerValue]
                                options: options];
}

- (NSPredicate *) predicateForRow: (NSInteger) row {
    _NSRuleEditorRowInfo *info = [self _rowAtIndex: row];
    return info != nil ? [self _predicateForRowInfo: info] : nil;
}

- (NSPredicate *) predicate {
    NSMutableArray *predicates = [NSMutableArray array];
    NSUInteger i, count = [_rows count];
    for (i = 0; i < count; i++) {
        _NSRuleEditorRowInfo *info = [_rows objectAtIndex: i];
        if (info->parent != nil)
            continue;
        NSPredicate *p = [self _predicateForRowInfo: info];
        if (p != nil)
            [predicates addObject: p];
    }
    if ([predicates count] == 0)
        return nil;
    if ([predicates count] == 1)
        return [predicates objectAtIndex: 0];
    return [NSCompoundPredicate andPredicateWithSubpredicates: predicates];
}

@end
