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

#import <AppKit/AppKitExport.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSGeometry.h>

@protocol NSPasteboardWriting;

typedef NSString *NSDraggingImageComponentKey;

APPKIT_EXPORT NSDraggingImageComponentKey const NSDraggingImageComponentIconKey;
APPKIT_EXPORT NSDraggingImageComponentKey const NSDraggingImageComponentLabelKey;

@interface NSDraggingImageComponent : NSObject {
    NSDraggingImageComponentKey _key;
    id _contents;
    NSRect _frame;
}
- (instancetype)initWithKey:(NSDraggingImageComponentKey)key;
- (NSDraggingImageComponentKey)key;
- (void)setKey:(NSDraggingImageComponentKey)key;
- (id)contents;
- (void)setContents:(id)contents;
- (NSRect)frame;
- (void)setFrame:(NSRect)frame;
@end

@interface NSDraggingItem : NSObject {
    id _item;
    NSRect _draggingFrame;
    NSArray *_imageComponents;
    NSArray *(^_imageComponentsProvider)(void);
}
- (instancetype)initWithPasteboardWriter:(id<NSPasteboardWriting>)pasteboardWriter;
- (id)item;
- (NSRect)draggingFrame;
- (void)setDraggingFrame:(NSRect)frame;
- (void)setDraggingFrame:(NSRect)frame contents:(id)contents;
- (NSArray *)imageComponents;
@end
