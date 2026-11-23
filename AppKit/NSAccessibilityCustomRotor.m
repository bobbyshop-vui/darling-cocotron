#import <AppKit/NSAccessibilityCustomRotor.h>

@implementation NSAccessibilityCustomRotor

- (instancetype)initWithLabel:(NSString *)label itemSearchDelegate:(id<NSAccessibilityCustomRotorItemSearchDelegate>)itemSearchDelegate
{
    if ((self = [super init]) != nil) {
        _type = NSAccessibilityCustomRotorTypeCustom;
        _label = [label copy];
        _itemSearchDelegate = itemSearchDelegate;
    }
    return self;
}

- (instancetype)initWithRotorType:(NSAccessibilityCustomRotorType)rotorType itemSearchDelegate:(id<NSAccessibilityCustomRotorItemSearchDelegate>)itemSearchDelegate
{
    if ((self = [super init]) != nil) {
        _type = rotorType;
        _label = @"";
        _itemSearchDelegate = itemSearchDelegate;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithLabel:@"" itemSearchDelegate:nil];
}

- (void)dealloc
{
    [_label release];
    [super dealloc];
}

- (NSAccessibilityCustomRotorType)type
{
    return _type;
}

- (void)setType:(NSAccessibilityCustomRotorType)type
{
    _type = type;
}

- (NSString *)label
{
    return _label;
}

- (void)setLabel:(NSString *)label
{
    if (_label != label) {
        [_label release];
        _label = [label copy];
    }
}

- (id<NSAccessibilityCustomRotorItemSearchDelegate>)itemSearchDelegate
{
    return _itemSearchDelegate;
}

- (void)setItemSearchDelegate:(id<NSAccessibilityCustomRotorItemSearchDelegate>)delegate
{
    _itemSearchDelegate = delegate;
}

- (id)itemLoadingDelegate
{
    return _itemLoadingDelegate;
}

- (void)setItemLoadingDelegate:(id)delegate
{
    _itemLoadingDelegate = delegate;
}

@end
