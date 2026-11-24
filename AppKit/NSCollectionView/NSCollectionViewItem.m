/* Copyright (c) 2009 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSCollectionViewItem.h>
#import <AppKit/NSRaise.h>
#import <Foundation/NSKeyedArchiver.h>
#import <AppKit/NSView.h>

// Archiver used to deep copy a prototype view: it leaves out everything that
// points out of the view's own subtree (superview, window, responder chain,
// key view loop), which would otherwise drag the whole window along.
@interface _NSCollectionViewItemViewArchiver : NSKeyedArchiver
@end

@implementation _NSCollectionViewItemViewArchiver

- (void) encodeObject: (id) object forKey: (NSString *) key {
    if ([key isEqualToString: @"NSSuperview"] || [key isEqualToString: @"NSWindow"] ||
        [key isEqualToString: @"NSNextResponder"] || [key isEqualToString: @"NSNextKeyView"])
        object = nil;
    [super encodeObject: object forKey: key];
}

@end

// Path of subview indexes leading from root to view, or nil if view is not
// inside root. The root itself has the empty path.
static NSArray *NSCollectionViewItemPathToView(NSView *root, NSView *view) {
    if (view == nil)
        return nil;
    if (root == view)
        return [NSArray array];
    NSArray *subviews = [root subviews];
    for (NSUInteger i = 0; i < [subviews count]; i++) {
        NSArray *sub = NSCollectionViewItemPathToView([subviews objectAtIndex: i], view);
        if (sub != nil) {
            NSMutableArray *path = [NSMutableArray arrayWithObject: [NSNumber numberWithUnsignedInteger: i]];
            [path addObjectsFromArray: sub];
            return path;
        }
    }
    return nil;
}

static NSView *NSCollectionViewItemViewAtPath(NSView *root, NSArray *path) {
    if (path == nil)
        return nil;
    NSView *view = root;
    for (NSNumber *index in path) {
        NSArray *subviews = [view subviews];
        if ([index unsignedIntegerValue] >= [subviews count])
            return nil;
        view = [subviews objectAtIndex: [index unsignedIntegerValue]];
    }
    return view;
}

static NSView *NSCollectionViewItemCopyView(NSView *view) {
    NSView *result = nil;
    @try {
        NSMutableData *data = [NSMutableData data];
        _NSCollectionViewItemViewArchiver *archiver =
            [[_NSCollectionViewItemViewArchiver alloc] initForWritingWithMutableData: data];
        [archiver encodeObject: view forKey: @"root"];
        [archiver finishEncoding];
        [archiver release];

        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
        result = [[unarchiver decodeObjectForKey: @"root"] retain];
        [unarchiver finishDecoding];
        [unarchiver release];
    } @catch (NSException *exception) {
        [result release];
        result = nil;
    }
    if (![result isKindOfClass: [NSView class]]) {
        [result release];
        // Could not archive the view: an empty view of the same size is
        // better than sharing one view between several items.
        result = [[NSView alloc] initWithFrame: [view frame]];
        [result setAutoresizingMask: [view autoresizingMask]];
    }
    return result;
}

@implementation NSCollectionViewItem

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder: coder];

    if ([coder allowsKeyedCoding]) {
        [coder encodeObject: [self nibName] forKey: @"NSNibName"];
        [coder encodeObject: [self title] forKey: @"NSTitle"];
        [coder encodeObject: [[self nibBundle] bundleIdentifier]
                     forKey: @"NSNibBundleIdentifier"];
        [coder encodeBool: _isSelected forKey: @"NSIsSelected"];
    } else {
        [NSException raise: NSInvalidArchiveOperationException
                    format: @"%@ does not support unkeyed encoding",
                            [self class]];
    }
}

- initWithCoder: (NSCoder *) coder {
    self = [super initWithCoder: coder];
    if (self == nil)
        return nil;

    if ([coder allowsKeyedCoding]) {
        _isSelected = [coder decodeBoolForKey: @"NSIsSelected"];
    } else {
        [NSException raise: NSInvalidArgumentException
                    format: @"-[%@ %s] is not implemented for coder %@",
                            [self class], sel_getName(_cmd), coder];
    }

    return self;
}

- copyWithZone: (NSZone *) zone {
    NSCollectionViewItem *copy = NSCopyObject(self, 0, zone);

    copy->_nibName = [_nibName copy];
    copy->_nibBundle = [_nibBundle retain];
    copy->_representedObject = [_representedObject retain];
    copy->_title = [_title copy];
    copy->_identifier = [_identifier copy];
    copy->_nextResponder = nil;
    copy->_vcxParentViewController = nil;
    copy->_vcxChildViewControllers = nil;
    copy->_vcxPresentingViewController = nil;
    copy->_vcxPresentedViewControllers = nil;
    copy->_editors = [[NSMutableArray alloc] init];
    copy->_vcxPresentationObject = nil;
    copy->_collectionView = nil;

    copy->_view = nil;
    copy->_imageView = nil;
    copy->_textField = nil;
    copy->_vcxDidLoadView = NO;
    copy->_isSelected = NO;

    if (_nibName == nil && _view != nil) {
        // Like AppKit, the copy gets a deep copy of the prototype's view, with
        // the textField/imageView outlets pointing into the copied subviews.
        NSView *viewCopy = NSCollectionViewItemCopyView(_view);
        copy->_view = viewCopy;
        copy->_vcxDidLoadView = YES;
        copy->_textField = (NSTextField *) NSCollectionViewItemViewAtPath(
            viewCopy, NSCollectionViewItemPathToView(_view, (NSView *) _textField));
        copy->_imageView = (NSImageView *) NSCollectionViewItemViewAtPath(
            viewCopy, NSCollectionViewItemPathToView(_view, (NSView *) _imageView));
    }

    return copy;
}

- (NSCollectionView *) collectionView {
    return _collectionView;
}

- (BOOL) isSelected {
    return _isSelected;
}

- (void) setSelected: (BOOL) value {
    _isSelected = value;
}

- (NSImageView *) imageView {
    return _imageView;
}

- (void) setImageView: (NSImageView *) value {
    _imageView = value;
}

- (NSTextField *) textField {
    return _textField;
}

- (void) setTextField: (NSTextField *) value {
    _textField = value;
}

- (NSInteger) highlightState {
    return _highlightState;
}

- (void) setHighlightState: (NSInteger) value {
    _highlightState = value;
}

- (void) prepareForReuse {
}

- (void) _setCollectionView: (NSCollectionView *) value {
    _collectionView = value;
}

@end
