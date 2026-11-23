#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>

@class NSString, NSSpeechRecognizer;
@protocol NSSpeechRecognizerDelegate;

@interface NSSpeechRecognizer : NSObject {
    id<NSSpeechRecognizerDelegate> _delegate;
    NSArray *_commands;
    NSString *_displayedCommandsTitle;
    BOOL _listensInForegroundOnly;
    BOOL _blocksOtherRecognizers;
    BOOL _listening;
}

- (instancetype)init;

- (void)startListening;
- (void)stopListening;

- (id<NSSpeechRecognizerDelegate>)delegate;
- (void)setDelegate:(id<NSSpeechRecognizerDelegate>)delegate;
- (NSArray *)commands;
- (void)setCommands:(NSArray *)commands;
- (NSString *)displayedCommandsTitle;
- (void)setDisplayedCommandsTitle:(NSString *)title;
- (BOOL)listensInForegroundOnly;
- (void)setListensInForegroundOnly:(BOOL)flag;
- (BOOL)blocksOtherRecognizers;
- (void)setBlocksOtherRecognizers:(BOOL)flag;

@end

@protocol NSSpeechRecognizerDelegate <NSObject>
@optional
- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(NSString *)command;
@end
