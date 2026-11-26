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
#import <AppKit/NSFont.h>
#import <AppKit/NSParagraphStyle.h>
#import <AppKit/NSTypesetter.h>

@class NSTextContainer, NSRangeArray;

// The concrete system typesetter ([NSTypesetter alloc] returns one); Xcode's
// DVTFoldingTypesetter subclasses it.
@interface NSATSTypesetter : NSTypesetter {
    IMP _layoutNextFragment;

    NSUInteger _nextGlyphLocation;
    NSUInteger _numberOfGlyphs;
    NSRange _glyphCacheRange;
    NSUInteger _glyphCacheCapacity;
    NSGlyph *_glyphCache;
    unichar *_characterCache;

    NSUInteger _bidiLevelsCapacity;
    uint8_t *_bidiLevels;
    uint8_t _currentBidiLevel;
    uint8_t _currentParagraphBidiLevel;

    BOOL _paragraphBreak;

    NSTextContainer *_container;
    NSSize _containerSize;

    NSDictionary *_attributes;
    NSRange _attributesRange;
    NSRange _attributesGlyphRange;
    NSFont *_font;
    CGFloat _fontAscender;
    CGFloat _fontDefaultLineHeight;
    NSPoint (*_positionOfGlyph)(NSFont *, SEL, NSGlyph, NSGlyph, BOOL *);
    NSTextAlignment _alignment;
    NSLineBreakMode _lineBreakMode;
    CGFloat _whitespaceAdvancement;

    NSRange _lineRange;
    NSRangeArray *_glyphRangesInLine;
    NSGlyph _previousGlyph;
    NSRect _scanRect;
    NSRect _wordWrapScanRect;
    NSRect _fullLineRect;
    CGFloat _maxAscender;

    NSRange _wordWrapRange;
    CGFloat _wordWrapWidth;
    NSGlyph _wordWrapPreviousGlyph;
}

+ (NSATSTypesetter *) sharedTypesetter;

@end
