/*
 * This file is part of Darling.
 *
 * Darling is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <AppKit/NSCollectionView.h>
#import <AppKit/NSDragging.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTextView.h>

@class NSDraggingSession;

/* The Cocotron headers predate the context-based NSDraggingSource API. */
typedef NSInteger NSDraggingContext;
enum {
	NSDraggingContextOutsideApplication = 0,
	NSDraggingContextWithinApplication = 1
};

@implementation NSTextView (NSDraggingSourceXcodeProtocols)

- (NSDragOperation) draggingSession: (NSDraggingSession *) session
    sourceOperationMaskForDraggingContext: (NSDraggingContext) context
{
	(void)session;
	return context == NSDraggingContextOutsideApplication
			? NSDragOperationCopy
			: NSDragOperationEvery;
}

@end

@implementation NSCollectionView (NSDraggingSourceXcodeProtocols)

- (NSDragOperation) draggingSession: (NSDraggingSession *) session
    sourceOperationMaskForDraggingContext: (NSDraggingContext) context
{
	(void)session;
	return context == NSDraggingContextOutsideApplication
			? NSDragOperationCopy
			: NSDragOperationEvery;
}

@end

@implementation NSOutlineView (NSDraggingSourceXcodeProtocols)

- (NSDragOperation) draggingSession: (NSDraggingSession *) session
    sourceOperationMaskForDraggingContext: (NSDraggingContext) context
{
	(void)session;
	return [(id)self draggingSourceOperationMaskForLocal:
			(context != NSDraggingContextOutsideApplication)];
}

@end

@implementation NSTableView (NSDraggingSourceXcodeProtocols)

- (NSDragOperation) draggingSession: (NSDraggingSession *) session
    sourceOperationMaskForDraggingContext: (NSDraggingContext) context
{
	(void)session;
	return [(id)self draggingSourceOperationMaskForLocal:
			(context != NSDraggingContextOutsideApplication)];
}

@end
