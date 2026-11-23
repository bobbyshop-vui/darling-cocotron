/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/NSStackView.h>
#import <Foundation/Foundation.h>

// NSLayoutAttribute values used for alignment
enum {
    SVAlignLeading = 5,
    SVAlignCenterX = 9,
    SVAlignCenterY = 10
};

@interface NSStackView (Private)
- (void)_stackViewCommonInit;
- (void)_relayoutArrangedViews;
- (NSMutableArray *)_bucketForGravity:(NSStackViewGravity)gravity;
- (void)_forgetView:(NSView *)view;
@end

@implementation NSStackView

+ (instancetype)stackViewWithViews:(NSArray *)views
{
    NSStackView *stack = [[[self alloc] initWithFrame:NSZeroRect] autorelease];
    [stack setViews:views inGravity:NSStackViewGravityLeading];
    return stack;
}

- (void)_stackViewCommonInit
{
    _orientation = NSUserInterfaceLayoutOrientationHorizontal;
    _alignment = SVAlignCenterY;
    _edgeInsets = NSEdgeInsetsMake(0, 0, 0, 0);
    _distribution = NSStackViewDistributionGravityAreas;
    _spacing = 8.0;
    _clippingResistance[0] = _clippingResistance[1] = 750.0;
    _hugging[0] = _hugging[1] = 250.0;
    _detachesHiddenViews = NO;
    for (int i = 0; i < 3; i++)
        _gravityViews[i] = [[NSMutableArray alloc] init];
    _customSpacing = [[NSMutableDictionary alloc] init];
}

- (instancetype)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
        [self _stackViewCommonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
        [self _stackViewCommonInit];
    return self;
}

- (void)dealloc
{
    for (int i = 0; i < 3; i++)
        [_gravityViews[i] release];
    [_customSpacing release];
    [super dealloc];
}

- (NSMutableArray *)_bucketForGravity:(NSStackViewGravity)gravity
{
    NSInteger g = gravity;
    if (g < 1 || g > 3)
        g = 1;
    return _gravityViews[g - 1];
}

- (NSValue *)_keyForView:(NSView *)view
{
    return [NSValue valueWithNonretainedObject:view];
}

- (void)_forgetView:(NSView *)view
{
    for (int i = 0; i < 3; i++)
        [_gravityViews[i] removeObjectIdenticalTo:view];
    [_customSpacing removeObjectForKey:[self _keyForView:view]];
}

- (NSUserInterfaceLayoutOrientation)orientation { return _orientation; }

- (void)setOrientation:(NSUserInterfaceLayoutOrientation)orientation
{
    if (_orientation == orientation)
        return;
    _orientation = orientation;
    // keep the default alignment meaningful for the new axis
    if (_alignment == SVAlignCenterX || _alignment == SVAlignCenterY)
        _alignment = (orientation == NSUserInterfaceLayoutOrientationVertical) ? SVAlignCenterX : SVAlignCenterY;
    [self _relayoutArrangedViews];
}

- (NSInteger)alignment { return _alignment; }

- (void)setAlignment:(NSInteger)alignment
{
    _alignment = alignment;
    [self _relayoutArrangedViews];
}

- (NSEdgeInsets)edgeInsets { return _edgeInsets; }

- (void)setEdgeInsets:(NSEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    [self _relayoutArrangedViews];
}

- (NSStackViewDistribution)distribution { return _distribution; }

- (void)setDistribution:(NSStackViewDistribution)distribution
{
    _distribution = distribution;
    [self _relayoutArrangedViews];
}

- (CGFloat)spacing { return _spacing; }

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    [self _relayoutArrangedViews];
}

- (void)setCustomSpacing:(CGFloat)spacing afterView:(NSView *)view
{
    if (![[self arrangedSubviews] containsObject:view])
        [NSException raise:NSInvalidArgumentException format:@"-[NSStackView setCustomSpacing:afterView:]: view is not managed by the stack view"];
    if (spacing == NSStackViewSpacingUseDefault)
        [_customSpacing removeObjectForKey:[self _keyForView:view]];
    else
        [_customSpacing setObject:[NSNumber numberWithDouble:spacing] forKey:[self _keyForView:view]];
    [self _relayoutArrangedViews];
}

- (CGFloat)customSpacingAfterView:(NSView *)view
{
    if (![[self arrangedSubviews] containsObject:view])
        [NSException raise:NSInvalidArgumentException format:@"-[NSStackView customSpacingAfterView:]: view is not managed by the stack view"];
    NSNumber *n = [_customSpacing objectForKey:[self _keyForView:view]];
    return n ? [n doubleValue] : NSStackViewSpacingUseDefault;
}

- (BOOL)detachesHiddenViews { return _detachesHiddenViews; }

- (void)setDetachesHiddenViews:(BOOL)flag
{
    _detachesHiddenViews = flag;
    [self _relayoutArrangedViews];
}

- (NSArray *)arrangedSubviews
{
    NSMutableArray *all = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
        [all addObjectsFromArray:_gravityViews[i]];
    return all;
}

- (void)addArrangedSubview:(NSView *)view
{
    [self insertArrangedSubview:view atIndex:[[self arrangedSubviews] count]];
}

- (void)insertArrangedSubview:(NSView *)view atIndex:(NSInteger)index
{
    if (view == nil)
        return;
    [view retain];
    [self _forgetView:view];
    NSInteger remaining = index;
    NSInteger lastNonEmpty = -1;
    NSInteger target = -1;
    for (int i = 0; i < 3; i++) {
        NSInteger count = [_gravityViews[i] count];
        if (count > 0)
            lastNonEmpty = i;
        if (remaining < count) {
            target = i;
            break;
        }
        remaining -= count;
    }
    if (target < 0) {
        target = lastNonEmpty >= 0 ? lastNonEmpty : 0;
        remaining = [_gravityViews[target] count];
    }
    if (remaining > (NSInteger)[_gravityViews[target] count])
        remaining = [_gravityViews[target] count];
    if (remaining < 0)
        remaining = 0;
    [_gravityViews[target] insertObject:view atIndex:remaining];
    if ([view superview] != self)
        [self addSubview:view];
    [view release];
    [self _relayoutArrangedViews];
}

- (void)removeArrangedSubview:(NSView *)view
{
    [view retain];
    [self _forgetView:view];
    [view release];
    [self _relayoutArrangedViews];
}

- (NSArray *)detachedViews
{
    NSMutableArray *detached = [NSMutableArray array];
    if (_detachesHiddenViews) {
        for (NSView *v in [self arrangedSubviews])
            if ([v isHidden])
                [detached addObject:v];
    }
    return detached;
}

- (NSLayoutPriority)clippingResistancePriorityForOrientation:(NSLayoutConstraintOrientation)orientation
{
    return _clippingResistance[orientation == NSLayoutConstraintOrientationVertical ? 1 : 0];
}

- (void)setClippingResistancePriority:(NSLayoutPriority)priority forOrientation:(NSLayoutConstraintOrientation)orientation
{
    _clippingResistance[orientation == NSLayoutConstraintOrientationVertical ? 1 : 0] = priority;
}

- (NSLayoutPriority)huggingPriorityForOrientation:(NSLayoutConstraintOrientation)orientation
{
    return _hugging[orientation == NSLayoutConstraintOrientationVertical ? 1 : 0];
}

- (void)setHuggingPriority:(NSLayoutPriority)priority forOrientation:(NSLayoutConstraintOrientation)orientation
{
    _hugging[orientation == NSLayoutConstraintOrientationVertical ? 1 : 0] = priority;
}

- (void)addView:(NSView *)view inGravity:(NSStackViewGravity)gravity
{
    [self insertView:view atIndex:[[self _bucketForGravity:gravity] count] inGravity:gravity];
}

- (void)insertView:(NSView *)view atIndex:(NSUInteger)index inGravity:(NSStackViewGravity)gravity
{
    if (view == nil)
        return;
    [view retain];
    [self _forgetView:view];
    NSMutableArray *bucket = [self _bucketForGravity:gravity];
    if (index > [bucket count])
        index = [bucket count];
    [bucket insertObject:view atIndex:index];
    if ([view superview] != self)
        [self addSubview:view];
    [view release];
    [self _relayoutArrangedViews];
}

- (void)removeView:(NSView *)view
{
    [view retain];
    [self _forgetView:view];
    if ([view superview] == self)
        [view removeFromSuperview];
    [view release];
    [self _relayoutArrangedViews];
}

- (NSArray *)viewsInGravity:(NSStackViewGravity)gravity
{
    return [NSArray arrayWithArray:[self _bucketForGravity:gravity]];
}

- (void)setViews:(NSArray *)views inGravity:(NSStackViewGravity)gravity
{
    NSMutableArray *bucket = [self _bucketForGravity:gravity];
    NSArray *old = [[bucket copy] autorelease];
    NSArray *new = [[views copy] autorelease];
    for (NSView *v in old) {
        if (![new containsObject:v]) {
            [self _forgetView:v];
            if ([v superview] == self)
                [v removeFromSuperview];
        }
    }
    [bucket removeAllObjects];
    for (NSView *v in new) {
        [self _forgetView:v];
        [bucket addObject:v];
        if ([v superview] != self)
            [self addSubview:v];
    }
    [self _relayoutArrangedViews];
}

- (NSArray *)views
{
    return [self arrangedSubviews];
}

- (void)setFrameSize:(NSSize)size
{
    [super setFrameSize:size];
    [self _relayoutArrangedViews];
}

- (void)_relayoutArrangedViews
{
    BOOL vertical = (_orientation == NSUserInterfaceLayoutOrientationVertical);
    BOOL flipped = [self isFlipped];
    NSRect bounds = [self bounds];
    NSRect inner = NSMakeRect(NSMinX(bounds) + _edgeInsets.left, NSMinY(bounds) + (flipped ? _edgeInsets.top : _edgeInsets.bottom),
                              NSWidth(bounds) - _edgeInsets.left - _edgeInsets.right,
                              NSHeight(bounds) - _edgeInsets.top - _edgeInsets.bottom);

    NSMutableArray *visible = [NSMutableArray array];
    for (NSView *v in [self arrangedSubviews]) {
        if (_detachesHiddenViews && [v isHidden])
            continue;
        [visible addObject:v];
    }
    if ([visible count] == 0)
        return;

    CGFloat position = vertical ? (flipped ? NSMinY(inner) : NSMaxY(inner)) : NSMinX(inner);
    NSUInteger count = [visible count];
    for (NSUInteger i = 0; i < count; i++) {
        NSView *v = [visible objectAtIndex:i];
        NSRect f = [v frame];
        NSNumber *custom = [_customSpacing objectForKey:[self _keyForView:v]];
        CGFloat gap = custom ? [custom doubleValue] : _spacing;

        if (vertical) {
            if (!flipped)
                position -= f.size.height;
            f.origin.y = position;
            switch (_alignment) {
            case SVAlignLeading:
            case 1: // left
                f.origin.x = NSMinX(inner);
                break;
            case 2: // right
            case 6: // trailing
                f.origin.x = NSMaxX(inner) - f.size.width;
                break;
            default:
                f.origin.x = NSMinX(inner) + (NSWidth(inner) - f.size.width) / 2.0;
                break;
            }
            position = flipped ? position + f.size.height + gap : position - gap;
        } else {
            f.origin.x = position;
            switch (_alignment) {
            case 3: // top
                f.origin.y = flipped ? NSMinY(inner) : NSMaxY(inner) - f.size.height;
                break;
            case 4: // bottom
                f.origin.y = flipped ? NSMaxY(inner) - f.size.height : NSMinY(inner);
                break;
            default:
                f.origin.y = NSMinY(inner) + (NSHeight(inner) - f.size.height) / 2.0;
                break;
            }
            position += f.size.width + gap;
        }
        [v setFrame:f];
    }
}

@end
