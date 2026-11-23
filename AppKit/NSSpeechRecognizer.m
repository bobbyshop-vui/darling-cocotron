#import <AppKit/NSSpeechRecognizer.h>

@implementation NSSpeechRecognizer

- (instancetype)init
{
    if ((self = [super init]) != nil) {
        _listensInForegroundOnly = YES;
    }
    return self;
}

- (void)dealloc
{
    [_commands release];
    [_displayedCommandsTitle release];
    [super dealloc];
}

// No speech engine is available: listening state is tracked but nothing is recognized.
- (void)startListening
{
    _listening = YES;
}

- (void)stopListening
{
    _listening = NO;
}

- (id<NSSpeechRecognizerDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<NSSpeechRecognizerDelegate>)delegate
{
    _delegate = delegate;
}

- (NSArray *)commands
{
    return _commands;
}

- (void)setCommands:(NSArray *)commands
{
    if (_commands != commands) {
        [_commands release];
        _commands = [commands copy];
    }
}

- (NSString *)displayedCommandsTitle
{
    return _displayedCommandsTitle;
}

- (void)setDisplayedCommandsTitle:(NSString *)title
{
    if (_displayedCommandsTitle != title) {
        [_displayedCommandsTitle release];
        _displayedCommandsTitle = [title copy];
    }
}

- (BOOL)listensInForegroundOnly
{
    return _listensInForegroundOnly;
}

- (void)setListensInForegroundOnly:(BOOL)flag
{
    _listensInForegroundOnly = flag;
}

- (BOOL)blocksOtherRecognizers
{
    return _blocksOtherRecognizers;
}

- (void)setBlocksOtherRecognizers:(BOOL)flag
{
    _blocksOtherRecognizers = flag;
}

@end
