/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

 Darling is free softwareyou can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http//www.gnu.org/licenses/>.
*/

#import <AppKit/NSAccessibilityElement.h>
#import <AppKit/NSResponder+XcodeAccessibility.h>
#import <Foundation/Foundation.h>

// The NSAccessibility properties (label, role, children, ...) are stored by
// the NSAccessibilityDefaults category in NSResponder+XcodeAccessibility.m.
@implementation NSAccessibilityElement

+ (id) accessibilityElementWithRole: (NSAccessibilityRole) role
                              frame: (NSRect) frame
                              label: (NSString *) label
                             parent: (id) parent {
    NSAccessibilityElement *element = [[[self alloc] init] autorelease];
    [element setAccessibilityRole: role];
    [element setAccessibilityFrame: frame];
    [element setAccessibilityLabel: label];
    [element setAccessibilityParent: parent];
    return element;
}

- (NSRect) accessibilityFrameInParentSpace {
    return _accessibilityFrameInParentSpace;
}

- (void) setAccessibilityFrameInParentSpace: (NSRect) frame {
    _accessibilityFrameInParentSpace = frame;
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) aSelector {
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void) forwardInvocation: (NSInvocation *) anInvocation {
    NSLog(@"Stub called: %@ in %@",
          NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
