#import <AppKit/NSSharingService.h>
#import <AppKit/NSImage.h>
#import <Foundation/NSError.h>
#import <Foundation/NSString.h>

NSSharingServiceName const NSSharingServiceNameAddToIPhoto = @"com.apple.share.System.add-to-iphoto";
NSSharingServiceName const NSSharingServiceNameAddToSafariReadingList = @"com.apple.share.System.add-to-safari-reading-list";
NSSharingServiceName const NSSharingServiceNameComposeEmail = @"com.apple.share.Mail.compose";
NSSharingServiceName const NSSharingServiceNameComposeMessage = @"com.apple.messages.ShareExtension";

NSSharingServiceName const NSSharingServiceNamePostOnFacebook = @"com.apple.share.Facebook.post";
NSSharingServiceName const NSSharingServiceNamePostOnTwitter = @"com.apple.share.Twitter.post";
NSSharingServiceName const NSSharingServiceNamePostOnSinaWeibo = @"com.apple.share.SinaWeibo.post";
NSSharingServiceName const NSSharingServiceNamePostOnTencentWeibo = @"com.apple.share.TencentWeibo.post";
NSSharingServiceName const NSSharingServiceNamePostOnLinkedIn = @"com.apple.share.LinkedIn.post";

@implementation NSSharingService

+ (NSArray *) sharingServicesForItems: (NSArray *) items {
    // No sharing services exist on this platform.
    return [NSArray array];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _title = @"";
        _image = [[NSImage alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_title release];
    [_subject release];
    [_accountName release];
    [_image release];
    [_alternateImage release];
    [super dealloc];
}

- (id<NSSharingServiceDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate: (id<NSSharingServiceDelegate>) delegate {
    _delegate = delegate;
}

- (NSString *) title {
    return _title;
}

- (NSImage *) image {
    return _image;
}

- (NSImage *) alternateImage {
    return _alternateImage;
}

- (NSString *) subject {
    return _subject;
}

- (void) setSubject: (NSString *) subject {
    if (_subject != subject) {
        [_subject release];
        _subject = [subject copy];
    }
}

- (NSString *) accountName {
    return _accountName;
}

- (void) performWithItems: (NSArray *) items {
    // There is nothing to share with, so report failure to the delegate.
    if ([_delegate respondsToSelector: @selector(sharingService:willShareItems:)])
        [_delegate sharingService: self willShareItems: items];

    if ([_delegate respondsToSelector: @selector(sharingService:
                                                 didFailToShareItems:error:)]) {
        NSError *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                             code: NSFeatureUnsupportedError
                                         userInfo: nil];
        [_delegate sharingService: self didFailToShareItems: items error: error];
    }
}

@end

@implementation NSSharingServicePicker

- (instancetype) initWithItems: (NSArray *) items {
    self = [super init];
    if (self)
        _items = [items copy];
    return self;
}

- (void) dealloc {
    [_items release];
    [super dealloc];
}

- (id<NSSharingServicePickerDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate: (id<NSSharingServicePickerDelegate>) delegate {
    _delegate = delegate;
}

- (void) showRelativeToRect: (NSRect) rect
                     ofView: (NSView *) view
              preferredEdge: (NSRectEdge) preferredEdge
{
    // No services to offer: the picker is dismissed with no choice.
    if ([_delegate respondsToSelector: @selector(sharingServicePicker:
                                                 didChooseSharingService:)])
        [_delegate sharingServicePicker: self didChooseSharingService: nil];
}

@end
