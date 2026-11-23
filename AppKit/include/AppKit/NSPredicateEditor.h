#import <AppKit/NSRuleEditor.h>

@class NSArray, NSPredicateEditorRowTemplate;

@interface NSPredicateEditor : NSRuleEditor {
    NSArray *_rowTemplates;
}

- (NSArray *) rowTemplates;
- (void) setRowTemplates: (NSArray *) rowTemplates;

@end
