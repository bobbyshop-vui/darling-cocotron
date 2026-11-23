#import <AppKit/NSAccessibilityCustomRotor.h>

@implementation NSAccessibilityCustomRotorSearchParameters

- (instancetype)init
{
    if ((self = [super init]) != nil) {
        _searchDirection = NSAccessibilityCustomRotorSearchDirectionNext;
        _filterString = @"";
    }
    return self;
}

- (void)dealloc
{
    [_currentItem release];
    [_filterString release];
    [super dealloc];
}

- (NSAccessibilityCustomRotorItemResult *)currentItem
{
    return _currentItem;
}

- (void)setCurrentItem:(NSAccessibilityCustomRotorItemResult *)item
{
    if (_currentItem != item) {
        [_currentItem release];
        _currentItem = [item retain];
    }
}

- (NSAccessibilityCustomRotorSearchDirection)searchDirection
{
    return _searchDirection;
}

- (void)setSearchDirection:(NSAccessibilityCustomRotorSearchDirection)direction
{
    _searchDirection = direction;
}

- (NSString *)filterString
{
    return _filterString;
}

- (void)setFilterString:(NSString *)filterString
{
    if (_filterString != filterString) {
        [_filterString release];
        _filterString = [filterString copy];
    }
}

@end
