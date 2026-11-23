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

#import <AppKit/AppKitExport.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

typedef NSString *NSVoiceGenderName;

APPKIT_EXPORT NSVoiceGenderName const NSVoiceGenderFemale;
APPKIT_EXPORT NSVoiceGenderName const NSVoiceGenderMale;

typedef NSString *NSVoiceAttributeKey;

APPKIT_EXPORT NSVoiceAttributeKey const NSVoiceName;
APPKIT_EXPORT NSVoiceAttributeKey const NSVoiceGender;
APPKIT_EXPORT NSVoiceAttributeKey const NSVoiceLocaleIdentifier;

typedef NSString *NSSpeechPropertyKey;

APPKIT_EXPORT NSSpeechPropertyKey const NSSpeechRateProperty;
APPKIT_EXPORT NSSpeechPropertyKey const NSSpeechPitchBaseProperty;
APPKIT_EXPORT NSSpeechPropertyKey const NSSpeechVolumeProperty;

typedef NSString *NSSpeechSynthesizerVoiceName;

@protocol NSSpeechSynthesizerDelegate;

@interface NSSpeechSynthesizer : NSObject {
    id<NSSpeechSynthesizerDelegate> _delegate;
    NSSpeechSynthesizerVoiceName _voice;
    float _rate;
    float _volume;
}

+ (NSArray *) availableVoices;
+ (NSSpeechSynthesizerVoiceName) defaultVoice;
+ (NSDictionary *) attributesForVoice: (NSSpeechSynthesizerVoiceName) voice;

- (instancetype) initWithVoice: (NSSpeechSynthesizerVoiceName) voice;
- (id<NSSpeechSynthesizerDelegate>) delegate;
- (void) setDelegate: (id<NSSpeechSynthesizerDelegate>) delegate;
- (float) rate;
- (void) setRate: (float) rate;
- (float) volume;
- (void) setVolume: (float) volume;
- (NSSpeechSynthesizerVoiceName) voice;
- (BOOL) setVoice: (NSSpeechSynthesizerVoiceName) voice;
- (BOOL) startSpeakingString: (NSString *) text;
- (void) stopSpeaking;

@end

@protocol NSSpeechSynthesizerDelegate <NSObject>
@optional
- (void) speechSynthesizer: (NSSpeechSynthesizer *) sender
         didFinishSpeaking: (BOOL) finishedSpeaking;
@end