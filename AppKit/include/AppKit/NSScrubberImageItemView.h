#import <AppKit/NSScrubberItemView.h>
#import <AppKit/NSImageCell.h>

@class NSImage, NSImageView;

@interface NSScrubberImageItemView : NSScrubberItemView {
    NSImageView *_imageView;
    NSImageAlignment _alignment;
}

@property (strong, readonly) NSImageView *imageView;
@property (copy) NSImage *image;
@property NSImageAlignment imageAlignment;

- (NSImageView *)imageView;
- (NSImage *)image;
- (void)setImage:(NSImage *)image;
- (NSImageAlignment)imageAlignment;
- (void)setImageAlignment:(NSImageAlignment)alignment;

@end
