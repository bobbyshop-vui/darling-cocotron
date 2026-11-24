#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSFontCollection.h>
#import <AppKit/NSLayoutConstraint.h>
#import <AppKit/NSMovie.h>
#import <AppKit/NSPrinter.h>
#import <AppKit/NSSlider.h>
#import <AppKit/NSSplitViewItem.h>
#import <AppKit/NSTextAttachment.h>
#import <AppKit/NSTextBlock.h>
#import <AppKit/NSTextList.h>
#import <AppKit/NSTrackingArea.h>
#import <Foundation/NSData.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSLayoutAnchor.h>
#import <Foundation/NSLayoutConstraint.h>
#import <Foundation/NSValue.h>
#import <objc/runtime.h>
#import <string.h>

@interface NSLayoutAnchor (XcodeCodingAppKit1Private)
- (instancetype)initWithItem:(id)item
                    attribute:(NSLayoutAttribute)attribute
                         name:(NSString *)name;
- (NSLayoutAttribute)_layoutAttribute;
@end

@interface NSEvent (XcodeCodingAppKit1Private)
- (void)_xcodeSetCodingStateWithType:(NSEventType)type
                            location:(NSPoint)location
                       modifierFlags:(NSEventModifierFlags)flags
                           timestamp:(NSTimeInterval)timestamp
                        windowNumber:(NSInteger)windowNumber;
@end

static NSEvent *XcodeEventWithState(NSEventType type, NSPoint location,
                                    NSEventModifierFlags flags,
                                    NSTimeInterval timestamp,
                                    NSInteger windowNumber,
                                    NSString *characters,
                                    unsigned short keyCode)
{
    NSEvent *event = nil;

    if (type == NSEventTypeKeyDown || type == NSEventTypeKeyUp) {
        event = [NSEvent keyEventWithType:type
                                 location:location
                            modifierFlags:flags
                                timestamp:timestamp
                             windowNumber:windowNumber
                                  context:nil
                               characters:characters
              charactersIgnoringModifiers:characters
                                isARepeat:NO
                                  keyCode:keyCode];
    } else {
        switch (type) {
        case NSEventTypeLeftMouseDown:
        case NSEventTypeLeftMouseUp:
        case NSEventTypeRightMouseDown:
        case NSEventTypeRightMouseUp:
        case NSEventTypeMouseMoved:
        case NSEventTypeLeftMouseDragged:
        case NSEventTypeRightMouseDragged:
        case NSEventTypeMouseEntered:
        case NSEventTypeMouseExited:
        case NSEventTypeScrollWheel:
            event = [NSEvent mouseEventWithType:type
                                       location:location
                                  modifierFlags:flags
                                      timestamp:timestamp
                                   windowNumber:windowNumber
                                        context:nil
                                    eventNumber:0
                                     clickCount:0
                                       pressure:0.0];
            break;
        default:
            event = [NSEvent otherEventWithType:type
                                       location:location
                                  modifierFlags:flags
                                      timestamp:timestamp
                                   windowNumber:windowNumber
                                        context:nil
                                        subtype:0
                                          data1:0
                                          data2:0];
            break;
        }
    }

    if (event == nil)
        return nil;

    // Some existing event factories resolve the window number through NSApp
    // and the key event factory currently assigns a fresh timestamp.
    [event _xcodeSetCodingStateWithType:type
                               location:location
                          modifierFlags:flags
                              timestamp:timestamp
                           windowNumber:windowNumber];
    return [event retain];
}

@implementation NSEvent (XcodeCodingAppKit1)

- (void)_xcodeSetCodingStateWithType:(NSEventType)type
                            location:(NSPoint)location
                       modifierFlags:(NSEventModifierFlags)flags
                           timestamp:(NSTimeInterval)timestamp
                        windowNumber:(NSInteger)windowNumber
{
    _type = type;
    _locationInWindow = location;
    _modifierFlags = flags;
    _timestamp = timestamp;
    _windowNumber = windowNumber;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSEventType type = (NSEventType)[coder decodeIntegerForKey:@"NSEventType"];
    NSPoint location = [coder decodePointForKey:@"NSEventLocation"];
    NSEventModifierFlags flags =
            (NSEventModifierFlags)[coder decodeIntegerForKey:@"NSEventModifierFlags"];
    NSTimeInterval timestamp = [coder decodeDoubleForKey:@"NSEventTimestamp"];
    NSInteger windowNumber = [coder decodeIntegerForKey:@"NSEventWindowNumber"];
    NSString *characters = [coder decodeObjectForKey:@"NSEventCharacters"];
    unsigned short keyCode =
            (unsigned short)[coder decodeIntegerForKey:@"NSEventKeyCode"];
    NSEvent *decoded = XcodeEventWithState(type, location, flags, timestamp,
                                           windowNumber, characters, keyCode);

    [self release];
    return decoded;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:(NSInteger)[self type] forKey:@"NSEventType"];
    [coder encodePoint:[self locationInWindow] forKey:@"NSEventLocation"];
    [coder encodeInteger:(NSInteger)[self modifierFlags]
                  forKey:@"NSEventModifierFlags"];
    [coder encodeDouble:[self timestamp] forKey:@"NSEventTimestamp"];
    [coder encodeInteger:[self windowNumber] forKey:@"NSEventWindowNumber"];
    [coder encodeObject:[self characters] forKey:@"NSEventCharacters"];
    [coder encodeInteger:[self keyCode] forKey:@"NSEventKeyCode"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return XcodeEventWithState([self type], [self locationInWindow],
                               [self modifierFlags], [self timestamp],
                               [self windowNumber], [self characters],
                               [self keyCode]);
}

@end

static char XcodeFontCollectionQueryDescriptorsKey;

static void XcodeSetFontCollectionQueryDescriptors(NSFontCollection *collection,
                                                   id descriptors)
{
    objc_setAssociatedObject(collection, &XcodeFontCollectionQueryDescriptorsKey,
                             descriptors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@implementation NSFontCollection (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil) {
        NSArray *descriptors = [coder decodeObjectForKey:@"NSFontCollectionQueryDescriptors"];
        id descriptorCopy = [descriptors copy];
        XcodeSetFontCollectionQueryDescriptors(self, descriptorCopy);
        [descriptorCopy release];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:objc_getAssociatedObject(
                                self, &XcodeFontCollectionQueryDescriptorsKey)
                 forKey:@"NSFontCollectionQueryDescriptors"];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSFontCollection *copy = [[[self class] allocWithZone:zone] init];
    id descriptors = objc_getAssociatedObject(
            self, &XcodeFontCollectionQueryDescriptorsKey);
    id descriptorCopy = [descriptors copy];
    XcodeSetFontCollectionQueryDescriptors(copy, descriptorCopy);
    [descriptorCopy release];
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Class mutableClass = NSClassFromString(@"NSMutableFontCollection");
    if (mutableClass == Nil)
        mutableClass = [self class];

    NSFontCollection *copy = [[mutableClass allocWithZone:zone] init];
    id descriptors = objc_getAssociatedObject(
            self, &XcodeFontCollectionQueryDescriptorsKey);
    id descriptorCopy = [descriptors mutableCopy];
    XcodeSetFontCollectionQueryDescriptors(copy, descriptorCopy);
    [descriptorCopy release];
    return copy;
}

@end

@implementation NSTextAttachment (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSFileWrapper *fileWrapper = [coder decodeObjectForKey:@"NSTextAttachmentFileWrapper"];
    self = [self initWithFileWrapper:fileWrapper];
    if (self != nil) {
        [self setBounds:[coder decodeRectForKey:@"NSTextAttachmentBounds"]];
        [self setFileType:[coder decodeObjectForKey:@"NSTextAttachmentFileType"]];

        id<NSTextAttachmentCell> cell =
                [coder decodeObjectForKey:@"NSTextAttachmentCell"];
        if (cell != nil)
            [self setAttachmentCell:cell];

        NSImage *image = [coder decodeObjectForKey:@"NSTextAttachmentImage"];
        if (image != nil)
            [self setImage:image];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self fileWrapper]
                 forKey:@"NSTextAttachmentFileWrapper"];
    [coder encodeObject:[self attachmentCell]
                 forKey:@"NSTextAttachmentCell"];
    [coder encodeRect:[self bounds] forKey:@"NSTextAttachmentBounds"];
    [coder encodeObject:[self fileType]
                 forKey:@"NSTextAttachmentFileType"];
    [coder encodeObject:[self image] forKey:@"NSTextAttachmentImage"];
}

@end

static NSData *XcodeDataFromBytes(const void *bytes, NSUInteger length)
{
    return [NSData dataWithBytes:bytes length:length];
}

static void XcodeDecodeBytes(NSCoder *coder, NSString *key, void *destination,
                             NSUInteger length)
{
    NSData *data = [coder decodeObjectForKey:key];
    if ([data isKindOfClass:[NSData class]] && [data length] == length)
        memcpy(destination, [data bytes], length);
}

@implementation NSTextBlock (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil) {
        _backgroundColor = [[coder decodeObjectForKey:@"NSTextBlockBackgroundColor"] copy];
        _borderColors = [[coder decodeObjectForKey:@"NSTextBlockBorderColors"] mutableCopy];
        _verticalAlignment = (NSTextBlockVerticalAlignment)
                [coder decodeIntegerForKey:@"NSTextBlockVerticalAlignment"];
        _contentWidth = [coder decodeDoubleForKey:@"NSTextBlockContentWidth"];
        _contentWidthValueType = (NSTextBlockValueType)
                [coder decodeIntegerForKey:@"NSTextBlockContentWidthValueType"];
        XcodeDecodeBytes(coder, @"NSTextBlockDimensionValues", _dimensionValues,
                         sizeof(_dimensionValues));
        XcodeDecodeBytes(coder, @"NSTextBlockDimensionValueTypes",
                         _dimensionValueTypes, sizeof(_dimensionValueTypes));
        XcodeDecodeBytes(coder, @"NSTextBlockLayerWidths", _layerWidths,
                         sizeof(_layerWidths));
        XcodeDecodeBytes(coder, @"NSTextBlockLayerValueTypes", _layerValueTypes,
                         sizeof(_layerValueTypes));
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_backgroundColor forKey:@"NSTextBlockBackgroundColor"];
    [coder encodeObject:_borderColors forKey:@"NSTextBlockBorderColors"];
    [coder encodeInteger:_verticalAlignment
                  forKey:@"NSTextBlockVerticalAlignment"];
    [coder encodeDouble:_contentWidth forKey:@"NSTextBlockContentWidth"];
    [coder encodeInteger:_contentWidthValueType
                  forKey:@"NSTextBlockContentWidthValueType"];
    [coder encodeObject:XcodeDataFromBytes(_dimensionValues,
                                           sizeof(_dimensionValues))
                 forKey:@"NSTextBlockDimensionValues"];
    [coder encodeObject:XcodeDataFromBytes(_dimensionValueTypes,
                                           sizeof(_dimensionValueTypes))
                 forKey:@"NSTextBlockDimensionValueTypes"];
    [coder encodeObject:XcodeDataFromBytes(_layerWidths, sizeof(_layerWidths))
                 forKey:@"NSTextBlockLayerWidths"];
    [coder encodeObject:XcodeDataFromBytes(_layerValueTypes,
                                           sizeof(_layerValueTypes))
                 forKey:@"NSTextBlockLayerValueTypes"];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSTextBlock *copy = [[self class] allocWithZone:zone];
    copy->_backgroundColor = [_backgroundColor copy];
    copy->_borderColors = [_borderColors mutableCopy];
    copy->_verticalAlignment = _verticalAlignment;
    copy->_contentWidth = _contentWidth;
    copy->_contentWidthValueType = _contentWidthValueType;
    memcpy(copy->_dimensionValues, _dimensionValues, sizeof(_dimensionValues));
    memcpy(copy->_dimensionValueTypes, _dimensionValueTypes,
           sizeof(_dimensionValueTypes));
    memcpy(copy->_layerWidths, _layerWidths, sizeof(_layerWidths));
    memcpy(copy->_layerValueTypes, _layerValueTypes, sizeof(_layerValueTypes));
    return copy;
}

@end

@implementation NSTextList (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithMarkerFormat:[coder decodeObjectForKey:@"NSTextListMarkerFormat"]
                              options:(unsigned)[coder decodeIntegerForKey:@"NSTextListOptions"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self markerFormat] forKey:@"NSTextListMarkerFormat"];
    [coder encodeInteger:[self listOptions] forKey:@"NSTextListOptions"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone]
            initWithMarkerFormat:[self markerFormat]
                          options:[self listOptions]];
}

@end

@implementation NSTrackingArea (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithRect:[coder decodeRectForKey:@"NSTrackingAreaRect"]
                      options:(NSTrackingAreaOptions)[coder decodeIntegerForKey:@"NSTrackingAreaOptions"]
                        owner:[coder decodeObjectForKey:@"NSTrackingAreaOwner"]
                     userInfo:[coder decodeObjectForKey:@"NSTrackingAreaUserInfo"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeRect:[self rect] forKey:@"NSTrackingAreaRect"];
    [coder encodeInteger:(NSInteger)[self options]
                  forKey:@"NSTrackingAreaOptions"];
    [coder encodeObject:[self owner] forKey:@"NSTrackingAreaOwner"];
    [coder encodeObject:[self userInfo] forKey:@"NSTrackingAreaUserInfo"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone]
            initWithRect:[self rect]
                  options:[self options]
                    owner:[self owner]
                 userInfo:[self userInfo]];
}

@end

@implementation NSMovie (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithURL:[coder decodeObjectForKey:@"NSMovieURL"]
                 byReference:YES];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self URL] forKey:@"NSMovieURL"];
}

@end

@implementation NSPrinter (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil) {
        _name = [[coder decodeObjectForKey:@"NSPrinterName"] copy];
        _type = [[coder decodeObjectForKey:@"NSPrinterType"] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_name forKey:@"NSPrinterName"];
    [coder encodeObject:_type forKey:@"NSPrinterType"];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPrinter *copy = [[[self class] allocWithZone:zone] init];
    copy->_name = [_name copy];
    copy->_type = [_type copy];
    return copy;
}

@end

@implementation NSSliderAccessory (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self != nil) {
        [self setBehavior:[coder decodeObjectForKey:@"NSSliderAccessoryBehavior"]];
        [self setEnabled:[coder decodeBoolForKey:@"NSSliderAccessoryEnabled"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self behavior] forKey:@"NSSliderAccessoryBehavior"];
    [coder encodeBool:[self isEnabled] forKey:@"NSSliderAccessoryEnabled"];
}

@end

@interface NSSliderAccessoryBehavior (XcodeCodingAppKit1Private)
- (instancetype)_initWithKind:(NSInteger)kind;
@end

@implementation NSSliderAccessoryBehavior (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self _initWithKind:[coder decodeIntegerForKey:@"NSSliderAccessoryBehaviorKind"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:_kind forKey:@"NSSliderAccessoryBehaviorKind"];
}

@end

@implementation NSSplitViewItem (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self != nil) {
        [self setViewController:[coder decodeObjectForKey:@"NSSplitViewItemViewController"]];
        _behavior = (NSSplitViewItemBehavior)
                [coder decodeIntegerForKey:@"NSSplitViewItemBehavior"];
        [self setCanCollapse:[coder decodeBoolForKey:@"NSSplitViewItemCanCollapse"]];
        [self setCollapsed:[coder decodeBoolForKey:@"NSSplitViewItemCollapsed"]];
        [self setHoldingPriority:(NSLayoutPriority)
                [coder decodeDoubleForKey:@"NSSplitViewItemHoldingPriority"]];
        [self setSpringLoaded:[coder decodeBoolForKey:@"NSSplitViewItemSpringLoaded"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self viewController]
                 forKey:@"NSSplitViewItemViewController"];
    [coder encodeInteger:[self behavior] forKey:@"NSSplitViewItemBehavior"];
    [coder encodeBool:[self canCollapse]
               forKey:@"NSSplitViewItemCanCollapse"];
    [coder encodeBool:[self isCollapsed]
               forKey:@"NSSplitViewItemCollapsed"];
    [coder encodeDouble:[self holdingPriority]
                 forKey:@"NSSplitViewItemHoldingPriority"];
    [coder encodeBool:[self isSpringLoaded]
               forKey:@"NSSplitViewItemSpringLoaded"];
}

@end

@implementation NSLayoutAnchor (XcodeCodingAppKit1)

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithItem:[coder decodeObjectForKey:@"NSLayoutAnchorItem"]
                    attribute:(NSLayoutAttribute)[coder decodeIntegerForKey:@"NSLayoutAnchorAttribute"]
                         name:[coder decodeObjectForKey:@"NSLayoutAnchorName"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self item] forKey:@"NSLayoutAnchorItem"];
    [coder encodeInteger:[self _layoutAttribute]
                  forKey:@"NSLayoutAnchorAttribute"];
    [coder encodeObject:_name forKey:@"NSLayoutAnchorName"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone]
            initWithItem:[self item]
                attribute:[self _layoutAttribute]
                     name:_name];
}

@end
