#import <AppKit/NSMovieView.h>
#import <AppKit/NSMovie.h>

// There is no QuickTime playback engine; the view keeps the state the API
// exposes so that setters round-trip.
@implementation NSMovieView

- (id) initWithFrame: (NSRect) frame {
    if ((self = [super initWithFrame: frame]) != nil) {
        _rate = 1.0f;
        _volume = 1.0f;
    }
    return self;
}

- (id) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder]) != nil) {
        _rate = 1.0f;
        _volume = 1.0f;
    }
    return self;
}

- (void) dealloc {
    [_movie release];
    [super dealloc];
}

- (void) setMovie: (NSMovie *) movie {
    movie = [movie retain];
    [_movie release];
    _movie = movie;
    _playing = NO;
    [self setNeedsDisplay: YES];
}

- (NSMovie *) movie {
    return _movie;
}

- (void) start: (id) sender {
    if (_movie != nil)
        _playing = YES;
}

- (void) stop: (id) sender {
    _playing = NO;
}

- (BOOL) isPlaying {
    return _playing;
}

- (void) stepForward: (id) sender {
    _playing = NO;
}

- (void) setRate: (float) rate {
    _rate = rate;
}

- (float) rate {
    return _rate;
}

- (void) setVolume: (float) volume {
    if (volume < 0.0f)
        volume = 0.0f;
    if (volume > 1.0f)
        volume = 1.0f;
    _volume = volume;
}

- (float) volume {
    return _volume;
}

- (BOOL) isControllerVisible {
    return _controllerVisible;
}

- (void) setEditable: (BOOL) editable {
    _editable = editable;
}

- (BOOL) isEditable {
    return _editable;
}

- (void) cut: (id) sender {
}

- (void) copy: (id) sender {
}

- (void) paste: (id) sender {
}

- (void) delete: (id) sender {
}

- (void) selectAll: (id) sender {
}

- (void) clear: (id) sender {
    [self delete: sender];
}

@end
