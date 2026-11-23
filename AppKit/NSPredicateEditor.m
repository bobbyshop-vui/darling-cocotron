#import <AppKit/NSPredicateEditor.h>
#import <AppKit/NSPredicateEditorRowTemplate.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSKeyedArchiver.h>

@implementation NSPredicateEditor

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder]) != nil) {
        NSArray *templates = nil;

        if ([coder allowsKeyedCoding] &&
            [coder containsValueForKey: @"NSPredicateEditorRowTemplates"])
            templates = [coder decodeObjectForKey: @"NSPredicateEditorRowTemplates"];
        _rowTemplates = [templates copy];
        if (_rowTemplates == nil)
            _rowTemplates = [[NSArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_rowTemplates release];
    [super dealloc];
}

- (NSArray *) rowTemplates {
    if (_rowTemplates == nil)
        _rowTemplates = [[NSArray alloc] init];
    return _rowTemplates;
}

- (void) setRowTemplates: (NSArray *) rowTemplates {
    NSArray *copy = [rowTemplates copy];
    [_rowTemplates release];
    _rowTemplates = copy;
}

- (BOOL) _forceUseDelegate {
    return NO;
}

@end
