#import <Foundation/Foundation.h>

@class NSAccessibilityCustomRotor, NSAccessibilityCustomRotorItemResult, NSAccessibilityCustomRotorSearchParameters;
@protocol NSAccessibilityCustomRotorItemSearchDelegate;

typedef NS_ENUM(NSInteger, NSAccessibilityCustomRotorSearchDirection) {
    NSAccessibilityCustomRotorSearchDirectionPrevious,
    NSAccessibilityCustomRotorSearchDirectionNext,
};

typedef NS_ENUM(NSInteger, NSAccessibilityCustomRotorType) {
    NSAccessibilityCustomRotorTypeCustom = 0,
    NSAccessibilityCustomRotorTypeAny = 1,
    NSAccessibilityCustomRotorTypeAnnotation,
    NSAccessibilityCustomRotorTypeBoldText,
    NSAccessibilityCustomRotorTypeHeading,
    NSAccessibilityCustomRotorTypeHeadingLevel1,
    NSAccessibilityCustomRotorTypeHeadingLevel2,
    NSAccessibilityCustomRotorTypeHeadingLevel3,
    NSAccessibilityCustomRotorTypeHeadingLevel4,
    NSAccessibilityCustomRotorTypeHeadingLevel5,
    NSAccessibilityCustomRotorTypeHeadingLevel6,
    NSAccessibilityCustomRotorTypeImage,
    NSAccessibilityCustomRotorTypeItalicText,
    NSAccessibilityCustomRotorTypeLandmark,
    NSAccessibilityCustomRotorTypeLink,
    NSAccessibilityCustomRotorTypeList,
    NSAccessibilityCustomRotorTypeMisspelledWord,
    NSAccessibilityCustomRotorTypeTable,
    NSAccessibilityCustomRotorTypeTextField,
    NSAccessibilityCustomRotorTypeUnderlinedText,
    NSAccessibilityCustomRotorTypeVisitedLink,
};

@interface NSAccessibilityCustomRotor : NSObject {
    NSAccessibilityCustomRotorType _type;
    NSString *_label;
    id<NSAccessibilityCustomRotorItemSearchDelegate> _itemSearchDelegate;
    id _itemLoadingDelegate;
}

- (instancetype)initWithLabel:(NSString *)label itemSearchDelegate:(id<NSAccessibilityCustomRotorItemSearchDelegate>)itemSearchDelegate;
- (instancetype)initWithRotorType:(NSAccessibilityCustomRotorType)rotorType itemSearchDelegate:(id<NSAccessibilityCustomRotorItemSearchDelegate>)itemSearchDelegate;

- (NSAccessibilityCustomRotorType)type;
- (void)setType:(NSAccessibilityCustomRotorType)type;
- (NSString *)label;
- (void)setLabel:(NSString *)label;
- (id<NSAccessibilityCustomRotorItemSearchDelegate>)itemSearchDelegate;
- (void)setItemSearchDelegate:(id<NSAccessibilityCustomRotorItemSearchDelegate>)delegate;
- (id)itemLoadingDelegate;
- (void)setItemLoadingDelegate:(id)delegate;

@end

@interface NSAccessibilityCustomRotorSearchParameters : NSObject {
    NSAccessibilityCustomRotorItemResult *_currentItem;
    NSAccessibilityCustomRotorSearchDirection _searchDirection;
    NSString *_filterString;
}

- (NSAccessibilityCustomRotorItemResult *)currentItem;
- (void)setCurrentItem:(NSAccessibilityCustomRotorItemResult *)item;
- (NSAccessibilityCustomRotorSearchDirection)searchDirection;
- (void)setSearchDirection:(NSAccessibilityCustomRotorSearchDirection)direction;
- (NSString *)filterString;
- (void)setFilterString:(NSString *)filterString;

@end

@protocol NSAccessibilityCustomRotorItemSearchDelegate <NSObject>
@required
- (NSAccessibilityCustomRotorItemResult *)rotor:(NSAccessibilityCustomRotor *)rotor resultForSearchParameters:(NSAccessibilityCustomRotorSearchParameters *)searchParameters;
@end
