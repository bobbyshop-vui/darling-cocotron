#import <AppKit/NSView.h>

@class NSMovie;

@interface NSMovieView : NSView {
    NSMovie *_movie;
    float _rate;
    float _volume;
    BOOL _playing;
    BOOL _editable;
    BOOL _controllerVisible;
}

- (void) setMovie: (NSMovie *) movie;
- (NSMovie *) movie;
- (void) start: (id) sender;
- (void) stop: (id) sender;
- (BOOL) isPlaying;
- (void) stepForward: (id) sender;
- (void) setRate: (float) rate;
- (float) rate;
- (void) setVolume: (float) volume;
- (float) volume;
- (BOOL) isControllerVisible;
- (void) setEditable: (BOOL) editable;
- (BOOL) isEditable;
- (void) cut: (id) sender;
- (void) copy: (id) sender;
- (void) paste: (id) sender;
- (void) delete: (id) sender;
- (void) selectAll: (id) sender;
- (void) clear: (id) sender;

@end
