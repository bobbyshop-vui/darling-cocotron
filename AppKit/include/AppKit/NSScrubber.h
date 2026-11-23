/*
 * This file is part of Darling.
 *
 * Copyright (C) 2023 Darling Developers
 *
 * Darling is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Darling is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Darling.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <AppKit/NSView.h>

@class NSColor, NSIndexSet, NSScrubber;

@protocol NSScrubberDataSource <NSObject>
@required
- (NSInteger)numberOfItemsForScrubber:(NSScrubber *)scrubber;
@end

typedef NS_ENUM(NSInteger, NSScrubberMode) {
    NSScrubberModeFixed = 0,
    NSScrubberModeFree
};

typedef NS_ENUM(NSInteger, NSScrubberAlignment) {
    NSScrubberAlignmentNone = 0,
    NSScrubberAlignmentLeading,
    NSScrubberAlignmentTrailing,
    NSScrubberAlignmentCenter
};

@interface NSScrubberLayout : NSObject <NSCoding> {
    NSScrubber *_scrubber;
}
@property (weak, readonly) NSScrubber *scrubber;
@property (readonly) NSRect visibleRect;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)invalidateLayout;
@end

@interface NSScrubber : NSView {
    id _delegate;
    id _dataSource;
    NSView *_backgroundView;
    NSColor *_backgroundColor;
    NSScrubberLayout *_scrubberLayout;
    NSInteger _numberOfItems;
    NSInteger _selectedIndex;
    NSScrubberAlignment _itemAlignment;
    NSScrubberMode _mode;
    BOOL _continuous;
    BOOL _showsArrowButtons;
    BOOL _showsAdditionalContentIndicators;
}
@property (assign) id dataSource;
@property (assign) id delegate;
@property (retain) NSScrubberLayout *scrubberLayout;
@property (readonly) NSInteger numberOfItems;
@property NSInteger selectedIndex;
@property NSScrubberMode mode;
@property NSScrubberAlignment itemAlignment;
@property (getter=isContinuous) BOOL continuous;
@property BOOL showsArrowButtons;
@property BOOL showsAdditionalContentIndicators;
@property (copy) NSColor *backgroundColor;
@property (retain) NSView *backgroundView;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex;
@end

@interface NSScrubberFlowLayout : NSScrubberLayout {
    CGFloat _itemSpacing;
    NSSize _itemSize;
}
@property CGFloat itemSpacing;
@property NSSize itemSize;
@end

@interface NSScrubberProportionalLayout : NSScrubberLayout {
    NSInteger _numberOfVisibleItems;
}
@property NSInteger numberOfVisibleItems;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
@end

@interface NSScrubberSelectionStyle : NSObject <NSCoding>
- (instancetype)initWithCoder:(NSCoder *)coder;
@end
