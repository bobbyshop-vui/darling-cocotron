#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NSTextFinderAction) {
    NSTextFinderActionShowFindInterface = 1,
    NSTextFinderActionNextMatch = 2,
    NSTextFinderActionPreviousMatch = 3,
    NSTextFinderActionReplaceAll = 4,
    NSTextFinderActionReplace = 5,
    NSTextFinderActionReplaceAndFind = 6,
    NSTextFinderActionSetSearchString = 7,
    NSTextFinderActionReplaceAllInSelection = 8,
    NSTextFinderActionSelectAll = 9,
    NSTextFinderActionSelectAllInSelection = 10,
    NSTextFinderActionHideFindInterface = 11,
    NSTextFinderActionShowReplaceInterface = 12,
    NSTextFinderActionHideReplaceInterface = 13
};

@protocol NSTextFinderBarContainer <NSObject>
@end

@protocol NSTextFinderClient <NSObject>
@optional
@property (readonly, strong) NSString *string;
- (NSArray *) selectedRanges;
- (void) setSelectedRanges: (NSArray *) selectedRanges;
- (void) scrollRangeToVisible: (NSRange) range;
@end

@interface NSTextFinder : NSObject <NSCoding> {
    id<NSTextFinderClient> _darlingClient;
    BOOL _darlingIncrementalSearchingEnabled;
    BOOL _darlingIncrementalSearchingShouldDimContentView;
    NSString *_darlingSearchString;
}

- (instancetype) init;
- (instancetype) initWithCoder: (NSCoder *) decoder;

@property (assign) id<NSTextFinderClient> client;
@property (getter=isIncrementalSearchingEnabled) BOOL incrementalSearchingEnabled;
@property BOOL incrementalSearchingShouldDimContentView;

- (void) performAction: (NSTextFinderAction) op;
- (BOOL) validateAction: (NSTextFinderAction) op;
- (void) cancelFindIndicator;

@end
