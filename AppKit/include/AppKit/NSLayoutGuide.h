/*
 This file is part of Darling.

 Copyright (C) 2021 Lubos Dolezel

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

#import <AppKit/AppKitExport.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSLayoutAnchor.h>
#import <AppKit/NSLayoutConstraint.h>

@interface NSLayoutGuide : NSObject <NSCoding> {
    NSString *_identifier;
    NSLayoutAnchor *_leadingAnchor, *_trailingAnchor, *_leftAnchor,
            *_rightAnchor, *_topAnchor, *_bottomAnchor, *_centerXAnchor,
            *_centerYAnchor;
    NSLayoutDimension *_widthAnchor, *_heightAnchor;
}

- (NSString *) identifier;
- (void) setIdentifier: (NSString *) identifier;

- (NSLayoutAnchor *) leadingAnchor;
- (NSLayoutAnchor *) trailingAnchor;
- (NSLayoutAnchor *) leftAnchor;
- (NSLayoutAnchor *) rightAnchor;
- (NSLayoutAnchor *) topAnchor;
- (NSLayoutAnchor *) bottomAnchor;
- (NSLayoutDimension *) widthAnchor;
- (NSLayoutDimension *) heightAnchor;
- (NSLayoutAnchor *) centerXAnchor;
- (NSLayoutAnchor *) centerYAnchor;

- (BOOL) hasAmbiguousLayout;
- (NSArray *) constraintsAffectingLayoutForOrientation:
        (NSLayoutConstraintOrientation) orientation;

@end
