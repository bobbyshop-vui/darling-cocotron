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

    if (_nibName != nil) {
        copy->_view = nil;
        copy->_imageView = nil;
        copy->_textField = nil;
        copy->_vcxDidLoadView = NO;
    } else {
        copy->_view = [_view retain];
        copy->_imageView = _imageView;
        copy->_textField = _textField;
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

- (void) _setCollectionView: (NSCollectionView *) value {
    _collectionView = value;
}

@end
