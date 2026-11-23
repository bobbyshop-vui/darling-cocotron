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

#import <AppKit/NSView.h>
#import <AppKit/NSLayoutConstraint.h>
#import <Foundation/NSGeometry.h>

typedef NS_ENUM(NSInteger, NSUserInterfaceLayoutOrientation) {
    NSUserInterfaceLayoutOrientationHorizontal = 0,
    NSUserInterfaceLayoutOrientationVertical = 1
};

typedef NS_ENUM(NSInteger, NSStackViewGravity) {
    NSStackViewGravityTop = 1,
    NSStackViewGravityLeading = 1,
    NSStackViewGravityCenter = 2,
    NSStackViewGravityBottom = 3,
    NSStackViewGravityTrailing = 3
};

typedef NS_ENUM(NSInteger, NSStackViewDistribution) {
    NSStackViewDistributionGravityAreas = -1,
    NSStackViewDistributionFill = 0,
    NSStackViewDistributionFillEqually,
    NSStackViewDistributionFillProportionally,
    NSStackViewDistributionEqualSpacing,
    NSStackViewDistributionEqualCentering
};

#define NSStackViewSpacingUseDefault FLT_MAX

@interface NSStackView : NSView {
    NSInteger _orientation;
    NSInteger _alignment;
    NSEdgeInsets _edgeInsets;
    NSInteger _distribution;
    CGFloat _spacing;
    NSLayoutPriority _clippingResistance[2];
    NSLayoutPriority _hugging[2];
    BOOL _detachesHiddenViews;
    NSMutableArray *_gravityViews[3];
    NSMutableDictionary *_customSpacing;
}

+ (instancetype)stackViewWithViews:(NSArray *)views;

- (NSUserInterfaceLayoutOrientation)orientation;
- (void)setOrientation:(NSUserInterfaceLayoutOrientation)orientation;
- (NSInteger)alignment;
- (void)setAlignment:(NSInteger)alignment;
- (NSEdgeInsets)edgeInsets;
- (void)setEdgeInsets:(NSEdgeInsets)edgeInsets;
- (NSStackViewDistribution)distribution;
- (void)setDistribution:(NSStackViewDistribution)distribution;
- (CGFloat)spacing;
- (void)setSpacing:(CGFloat)spacing;
- (void)setCustomSpacing:(CGFloat)spacing afterView:(NSView *)view;
- (CGFloat)customSpacingAfterView:(NSView *)view;
- (BOOL)detachesHiddenViews;
- (void)setDetachesHiddenViews:(BOOL)flag;
- (NSArray *)arrangedSubviews;
- (void)addArrangedSubview:(NSView *)view;
- (void)insertArrangedSubview:(NSView *)view atIndex:(NSInteger)index;
- (void)removeArrangedSubview:(NSView *)view;
- (NSArray *)detachedViews;
- (NSLayoutPriority)clippingResistancePriorityForOrientation:(NSLayoutConstraintOrientation)orientation;
- (void)setClippingResistancePriority:(NSLayoutPriority)priority forOrientation:(NSLayoutConstraintOrientation)orientation;
- (NSLayoutPriority)huggingPriorityForOrientation:(NSLayoutConstraintOrientation)orientation;
- (void)setHuggingPriority:(NSLayoutPriority)priority forOrientation:(NSLayoutConstraintOrientation)orientation;

- (void)addView:(NSView *)view inGravity:(NSStackViewGravity)gravity;
- (void)insertView:(NSView *)view atIndex:(NSUInteger)index inGravity:(NSStackViewGravity)gravity;
- (void)removeView:(NSView *)view;
- (NSArray *)viewsInGravity:(NSStackViewGravity)gravity;
- (void)setViews:(NSArray *)views inGravity:(NSStackViewGravity)gravity;
- (NSArray *)views;

@end
