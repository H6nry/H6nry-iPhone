/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/VoiceServices.framework/VoiceServices
 */

#import "VoiceServices-Structs.h"


@protocol VSSpeechConnectionDelegate
-(void)connection:(id)connection speechRequest:(id)request didStopAtEnd:(BOOL)end phonemesSpoken:(id)spoken error:(id)error;
-(void)connection:(id)connection speechRequest:(id)request willSpeakMark:(int)mark inRange:(NSRange)range;
-(void)connection:(id)connection speechRequestDidContinue:(id)speechRequest;
-(void)connection:(id)connection speechRequestDidPause:(id)speechRequest;
-(void)connection:(id)connection speechRequestDidStart:(id)speechRequest;
@end

