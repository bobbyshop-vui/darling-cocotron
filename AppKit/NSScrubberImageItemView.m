#import <AppKit/NSScrubberImageItemView.h>
#import <AppKit/NSImageView.h>
#import <AppKit/NSImage.h>

@implementation NSScrubberImageItemView

- (instancetype)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]) != nil) {
        _alignment = NSImageAlignCenter;
    }
    return self;
}

- (void)dealloc
{
    [_imageView removeFromSuperview];
    [_imageView release];
    [super dealloc];
}

- (NSImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[NSImageView alloc] initWithFrame:[self bounds]];
        [_imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [_imageView setImageAlignment:_alignment];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (NSImage *)image
{
    return [[self imageView] image];
}

- (void)setImage:(NSImage *)image
{
    [[self imageView] setImage:[[image copy] autorelease]];
}

- (NSImageAlignment)imageAlignment
{
    return _alignment;
}

- (void)setImageAlignment:(NSImageAlignment)alignment
{
    _alignment = alignment;
    [[self imageView] setImageAlignment:alignment];
}

@end
