/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

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

#import <Foundation/NSBundle.h>

@class NSPasteboard;
@protocol NSSoundDelegate;

@interface NSSound : NSObject {
    NSString *_name;
    NSData *_data;
    id<NSSoundDelegate> _delegate;
    NSTimeInterval _currentTime;
    float _volume;
    BOOL _loops;
    BOOL _playing;
}

+ (NSArray *) soundUnfilteredFileTypes;
+ (NSArray *) soundUnfilteredTypes;
+ (BOOL) canInitWithPasteboard: (NSPasteboard *) pasteboard;

+ (NSSound *) soundNamed: (NSString *) name;

- (id) initWithContentsOfFile: (NSString *) path
                  byReference: (BOOL) byReference;
- (id) initWithContentsOfURL: (NSURL *) url byReference: (BOOL) byReference;
- (id) initWithData: (NSData *) data;
- (id) initWithPasteboard: (NSPasteboard *) pasteboard;
- (void) writeToPasteboard: (NSPasteboard *) pasteboard;

- (BOOL) setName: (NSString *) name;
- (NSString *) name;
- (id<NSSoundDelegate>) delegate;
- (void) setDelegate: (id<NSSoundDelegate>) delegate;
- (BOOL) isPlaying;
- (BOOL) loops;
- (void) setLoops: (BOOL) loops;
- (float) volume;
- (void) setVolume: (float) volume;
- (NSTimeInterval) currentTime;
- (void) setCurrentTime: (NSTimeInterval) currentTime;
- (NSTimeInterval) duration;

- (BOOL) play;
- (BOOL) pause;
- (BOOL) resume;
- (BOOL) stop;

@end

@interface NSBundle (NSSound)
- (NSString *) pathForSoundResource: (NSString *) sound;
@end

@protocol NSSoundDelegate <NSObject>
@optional
- (void) sound: (NSSound *) sound didFinishPlaying: (BOOL) flag;

@end
