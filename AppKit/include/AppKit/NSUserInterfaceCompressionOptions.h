/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKitExport.h>

@interface NSUserInterfaceCompressionOptions : NSObject <NSCopying, NSCoding> {
    NSSet *_identifiers;
}

- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (instancetype)initWithCompressionOptions:(NSSet *)options;

- (BOOL)containsOptions:(NSUserInterfaceCompressionOptions *)options;
- (BOOL)intersectsOptions:(NSUserInterfaceCompressionOptions *)options;

@property(readonly, getter = isEmpty) BOOL empty;
- (BOOL)isEmpty;

- (NSUserInterfaceCompressionOptions *)optionsByAddingOptions:(NSUserInterfaceCompressionOptions *)options;
- (NSUserInterfaceCompressionOptions *)optionsByRemovingOptions:(NSUserInterfaceCompressionOptions *)options;

@property(class, readonly, copy) NSUserInterfaceCompressionOptions *hideImagesOption;
@property(class, readonly, copy) NSUserInterfaceCompressionOptions *hideTextOption;
@property(class, readonly, copy) NSUserInterfaceCompressionOptions *reduceMetricsOption;
@property(class, readonly, copy) NSUserInterfaceCompressionOptions *breakEqualWidthsOption;
@property(class, readonly, copy) NSUserInterfaceCompressionOptions *standardOptions;

@end
