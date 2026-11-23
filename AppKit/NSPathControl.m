#import <AppKit/NSPathControl.h>

#import "AppKit/NSRaise.h"

@implementation NSPathControl

- (void) dealloc {
    [_pathItems release];
    [super dealloc];
}

- (NSArray<NSString *> *) allowedTypes {
    NSPathCell *cell = [self cell];
    return [cell allowedTypes];
}

- (void) setAllowedTypes: (NSArray<NSString *> *) allowedTypes {
    NSPathCell *cell = [self cell];
    [cell setAllowedTypes: allowedTypes];
}

- (NSString *) placeholderString {
    NSPathCell *cell = [self cell];
    return [cell placeholderString];
}

- (void) setPlaceholderString: (NSString *) string {
    NSPathCell *cell = [self cell];
    [cell setPlaceholderString: string];
}

- (NSAttributedString *) placeholderAttributedString {
    NSPathCell *cell = [self cell];
    return [cell placeholderAttributedString];
}

- (void) setPlaceholderAttributedString: (NSAttributedString *) string {
    NSPathCell *cell = [self cell];
    [cell setPlaceholderAttributedString: string];
}

- (NSArray<NSPathControlItem *> *) pathItems {
    return _pathItems != nil ? _pathItems : [NSArray array];
}

- (void) setPathItems: (NSArray<NSPathControlItem *> *) items {
    NSArray *copy = [items copy];
    [_pathItems release];
    _pathItems = copy;
    [self setNeedsDisplay: YES];
}

- (NSPathControlItem *) clickedPathItem {
    // Items correspond one to one with the component cells
    NSPathComponentCell *clicked = [self clickedPathComponentCell];
    if (clicked == nil) {
        return nil;
    }
    NSUInteger index = [[self pathComponentCells] indexOfObjectIdenticalTo: clicked];
    if (index == NSNotFound || index >= [_pathItems count]) {
        return nil;
    }
    return [_pathItems objectAtIndex: index];
}

- (BOOL) isFlipped {
    return YES;
}

- (NSPathStyle) pathStyle; {
    NSPathCell *cell = [self cell];
    return [cell pathStyle];
}

- (void) setPathStyle: (NSPathStyle) style; {
    NSPathCell *cell = [self cell];
    [cell setPathStyle: style];
}

- (NSColor *) backgroundColor; {
    NSPathCell *cell = [self cell];
    return [cell backgroundColor];
}

- (void) setBackgroundColor: (NSColor *) color; {
    NSPathCell *cell = [self cell];
    [cell setBackgroundColor: color];
}

- (NSPathComponentCell *) clickedPathComponentCell {
    NSPathCell *cell = [self cell];
    return [cell clickedPathComponentCell];
}

- (NSArray *) pathComponentCells; {
    NSPathCell *cell = [self cell];
    return [cell pathComponentCells];
}

- (void) setPathComponentCells: (NSArray *) cells; {
    NSPathCell *cell = [self cell];
    [cell setPathComponentCells: cells];
}

- (SEL) doubleAction; {
    NSPathCell *cell = [self cell];
    return [cell doubleAction];
}

- (void) setDoubleAction: (SEL) action; {
    NSPathCell *cell = [self cell];
    [cell setDoubleAction: action];
}

- (NSURL *) URL; {
    NSPathCell *cell = [self cell];
    return [cell URL];
}
- (void) setURL: (NSURL *) url; {
    NSPathCell *cell = [self cell];
    [cell setURL: url];
}

- (id<NSPathControlDelegate>) delegate; {
    NSUnimplementedMethod();
    return nil;
}

- (void) setDelegate: (id<NSPathControlDelegate>) delegate; {
    NSUnimplementedMethod();
}

- (void) setDraggingSourceOperationMask: (NSDragOperation) mask
                               forLocal: (BOOL) isLocal;
{
    NSUnimplementedMethod();
}

- (NSMenu *) menu; {
    NSPathCell *cell = [self cell];
    //	return [cell menu];
    return nil;
}

- (void) setMenu: (NSMenu *) menu; {
    NSPathCell *cell = [self cell];
    //	[cell setMenu: menu];
}

+ (void) initialize; {
    if (self == [NSPathControl class]) {
        [self setCellClass: [NSPathCell class]];
    }
}

@end
