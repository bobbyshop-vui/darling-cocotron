/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/NSSpeechSynthesizer.h>

NSVoiceGenderName const NSVoiceGenderFemale = @"VoiceGenderFemale";
NSVoiceGenderName const NSVoiceGenderMale = @"VoiceGenderMale";

NSVoiceAttributeKey const NSVoiceName = @"VoiceName";
NSVoiceAttributeKey const NSVoiceGender = @"VoiceGender";
NSVoiceAttributeKey const NSVoiceLocaleIdentifier = @"VoiceLocaleIdentifier";

NSSpeechPropertyKey const NSSpeechRateProperty = @"rate";
NSSpeechPropertyKey const NSSpeechPitchBaseProperty = @"pbas";
NSSpeechPropertyKey const NSSpeechVolumeProperty = @"volm";

static NSString *const NSSpeechVoiceIdentifierPrefix =
        @"com.apple.speech.synthesis.voice.";

@implementation NSSpeechSynthesizer

+ (NSArray *) availableVoices {
    return [NSArray arrayWithObject: [self defaultVoice]];
}

+ (NSSpeechSynthesizerVoiceName) defaultVoice {
    return [NSSpeechVoiceIdentifierPrefix stringByAppendingString: @"Alex"];
}

+ (NSDictionary *) attributesForVoice: (NSSpeechSynthesizerVoiceName) voice {
    if (voice == nil || ![[self availableVoices] containsObject: voice]) {
        return nil;
    }
    NSString *name = [voice hasPrefix: NSSpeechVoiceIdentifierPrefix]
                             ? [voice substringFromIndex:
                                              [NSSpeechVoiceIdentifierPrefix
                                                      length]]
                             : voice;
    return [NSDictionary
            dictionaryWithObjectsAndKeys: name, NSVoiceName,
                                          NSVoiceGenderMale, NSVoiceGender,
                                          @"en_US", NSVoiceLocaleIdentifier,
                                          voice, @"VoiceIdentifier", nil];
}

- (instancetype) init {
    return [self initWithVoice: nil];
}

- (instancetype) initWithVoice: (NSSpeechSynthesizerVoiceName) voice {
    if ((self = [super init])) {
        _voice = [(voice != nil ? voice : [[self class] defaultVoice]) copy];
        _rate = 175.0f;
        _volume = 1.0f;
    }
    return self;
}

- (void) dealloc {
    [_voice release];
    [super dealloc];
}

- (id<NSSpeechSynthesizerDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate: (id<NSSpeechSynthesizerDelegate>) delegate {
    _delegate = delegate;
}

- (float) rate {
    return _rate;
}

- (void) setRate: (float) rate {
    _rate = rate;
}

- (float) volume {
    return _volume;
}

- (void) setVolume: (float) volume {
    _volume = MIN(MAX(volume, 0.0f), 1.0f);
}

- (NSSpeechSynthesizerVoiceName) voice {
    return _voice;
}

- (BOOL) setVoice: (NSSpeechSynthesizerVoiceName) voice {
    if (voice == nil) {
        voice = [[self class] defaultVoice];
    }
    if (![[[self class] availableVoices] containsObject: voice]) {
        return NO;
    }
    if (voice != _voice) {
        [_voice release];
        _voice = [voice copy];
    }
    return YES;
}

/* Darling has no speech engine: nothing can be spoken, so report that
   speaking did not start. */
- (BOOL) startSpeakingString: (NSString *) text {
    return NO;
}

- (void) stopSpeaking {
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
