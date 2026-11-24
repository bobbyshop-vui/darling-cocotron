/* Copyright (c) 2006-2008 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSRaise.h>
#import <AppKit/NSSound.h>
#import <AppKit/NSPasteboard.h>
#import <Foundation/NSData.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSMutableDictionary.h>
#import <Foundation/NSNumber.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSCoder.h>

static NSMutableDictionary *sSounds = nil;
static NSString *const NSSoundPasteboardType = @"NXSoundPboardType";

@implementation NSSound

+ (NSArray *) soundUnfilteredFileTypes {
    // _soundUnfilteredFileTypes is implemented in a category in the platform
    if ([self respondsToSelector: @selector(_soundUnfilteredFileTypes)])
        return [self performSelector: @selector(_soundUnfilteredFileTypes)];

    return nil;
}

+ (NSArray *) soundUnfilteredTypes {
    NSArray *types = [self soundUnfilteredFileTypes];
    if (types == nil)
        types = [NSArray arrayWithObjects: @"aiff", @"aif", @"wav", @"au",
                                           @"snd", @"mp3", @"m4a", nil];
    return types;
}

+ (BOOL) canInitWithPasteboard: (NSPasteboard *) pasteboard {
    return [[pasteboard types] containsObject: NSSoundPasteboardType];
}

+ (NSSound *) soundNamed: (NSString *) name {
    if (name == nil)
        return nil;

    if (sSounds == nil) {
        sSounds = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
    }

    NSSound *sound = nil;
    @synchronized(sSounds) {
        sound = [sSounds objectForKey: name];
        if (sound == nil) {
            NSArray *types = [NSSound soundUnfilteredTypes];
            NSString *path = nil;
            NSUInteger i, count = [types count];

            // Main bundle first
            for (i = 0; path == nil && i < count; i++)
                path = [[NSBundle mainBundle]
                        pathForResource: name
                                 ofType: [types objectAtIndex: i]];

            // Then the standard sound directories
            NSArray *dirs = [NSArray
                    arrayWithObjects: [NSHomeDirectory()
                                              stringByAppendingPathComponent:
                                                      @"Library/Sounds"],
                                      @"/Library/Sounds",
                                      @"/System/Library/Sounds", nil];
            NSFileManager *fm = [NSFileManager defaultManager];
            NSUInteger d;
            for (d = 0; path == nil && d < [dirs count]; d++) {
                NSString *dir = [dirs objectAtIndex: d];
                for (i = 0; path == nil && i < count; i++) {
                    NSString *candidate = [[dir stringByAppendingPathComponent:
                                                        name]
                            stringByAppendingPathExtension: [types
                                                                    objectAtIndex:
                                                                            i]];
                    if ([fm fileExistsAtPath: candidate])
                        path = candidate;
                }
            }

            if (path != nil) {
                sound = [[[NSSound alloc] initWithContentsOfFile: path
                                                     byReference: YES]
                        autorelease];
                if (sound != nil) {
                    sound->_name = [name copy];
                    [sSounds setObject: sound forKey: name];
                }
            }
        }
    }
    return sound;
}

- (id) copyWithZone: (NSZone *) zone {
    NSSound *copy = [[NSSound allocWithZone: zone] init];
    copy->_data = [_data copy];
    copy->_volume = _volume;
    copy->_loops = _loops;
    copy->_delegate = _delegate;
    return copy;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject: _name forKey: @"NSName"];
        [coder encodeObject: _data forKey: @"NSData"];
    } else {
        [coder encodeObject: _name];
        [coder encodeObject: _data];
    }
}

- (id) initWithCoder: (NSCoder *) coder {
    self = [self init];
    if (self) {
        if ([coder allowsKeyedCoding]) {
            _name = [[coder decodeObjectForKey: @"NSName"] copy];
            _data = [[coder decodeObjectForKey: @"NSData"] retain];
        } else {
            _name = [[coder decodeObject] copy];
            _data = [[coder decodeObject] retain];
        }
    }
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        _volume = 1.0f;
        _playing = NO;
        _paused = NO;
        _currentTime = 0.0;
    }
    return self;
}

- (id) initWithContentsOfURL: (NSURL *) url byReference: (BOOL) byReference {
    self = [self init];
    if (self) {
        _data = [[NSData alloc] initWithContentsOfURL: url];
        if (_data == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id) initWithContentsOfFile: (NSString *) path
                  byReference: (BOOL) byReference
{
    self = [self init];
    if (self) {
        _data = [[NSData alloc] initWithContentsOfFile: path];
        if (_data == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id) initWithData: (NSData *) data {
    if (data == nil) {
        [self release];
        return nil;
    }
    self = [self init];
    if (self)
        _data = [data copy];
    return self;
}

- (id) initWithPasteboard: (NSPasteboard *) pasteboard {
    NSData *data = [pasteboard dataForType: NSSoundPasteboardType];
    return [self initWithData: data];
}

- (void) writeToPasteboard: (NSPasteboard *) pasteboard {
    [pasteboard declareTypes: [NSArray arrayWithObject: NSSoundPasteboardType]
                       owner: nil];
    if (_data != nil)
        [pasteboard setData: _data forType: NSSoundPasteboardType];
}

- (void) dealloc {
    [_name release];
    [_data release];
    [super dealloc];
}

- (BOOL) setName: (NSString *) name {
    if (sSounds == nil)
        sSounds = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];

    @synchronized(sSounds) {
        if (name != nil && [sSounds objectForKey: name] != nil)
            return NO;
        if (_name != nil && [sSounds objectForKey: _name] == self)
            [sSounds removeObjectForKey: _name];
        [_name release];
        _name = [name copy];
        if (_name != nil)
            [sSounds setObject: self forKey: _name];
    }
    return YES;
}

- (NSString *) name {
    return _name;
}

- (id<NSSoundDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate: (id<NSSoundDelegate>) delegate {
    _delegate = delegate;
}

- (BOOL) isPlaying {
    return _playing;
}

- (BOOL) loops {
    return _loops;
}

- (void) setLoops: (BOOL) loops {
    _loops = loops;
}

- (float) volume {
    return _volume;
}

- (void) setVolume: (float) volume {
    if (volume < 0.0f)
        volume = 0.0f;
    else if (volume > 1.0f)
        volume = 1.0f;
    _volume = volume;
}

- (NSTimeInterval) currentTime {
    return _currentTime;
}

- (void) setCurrentTime: (NSTimeInterval) currentTime {
    _currentTime = currentTime < 0 ? 0 : currentTime;
}

- (NSTimeInterval) duration {
    // No audio decoder is available, so the length cannot be determined.
    return 0;
}

// Darling currently has no working audio output backend (AudioQueue and
// AudioServices are stubs), so playback honestly never starts.
- (BOOL) play {
    return NO;
}

- (BOOL) pause {
    return NO;
}

- (BOOL) resume {
    return NO;
}

- (BOOL) stop {
    return NO;
}

@end

@implementation NSBundle (NSSound)

- (NSString *) pathForSoundResource: (NSString *) name {
    NSArray *types = [NSSound soundUnfilteredTypes];
    int i, count = [types count];

    for (i = 0; i < count; i++) {
        NSString *type = [types objectAtIndex: i];
        NSString *path = [self pathForResource: name ofType: type];

        if (path != nil)
            return path;
    }

    return nil;
}

@end
