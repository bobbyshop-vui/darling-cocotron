#import <Foundation/Foundation.h>
#import <AppKit/AppKitExport.h>

@interface NSAccessibilityCustomAction : NSObject {
    NSString *_name;
    id<NSObject> _target;
    BOOL (^_handler)(void);
    SEL _selector;
}

- (instancetype)initWithName:(NSString *)name handler:(BOOL (^)(void))handler;
- (instancetype)initWithName:(NSString *)name target:(id<NSObject>)target selector:(SEL)selector;

@property(copy) NSString *name;
@property(copy) BOOL (^handler)(void);
@property(assign) id<NSObject> target;
@property SEL selector;

@end
