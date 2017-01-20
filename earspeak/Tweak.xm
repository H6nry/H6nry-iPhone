/*#import <substrate.h>
#import "AudioToolbox/AudioToolbox.h"


MSHook(OSStatus, AudioSessionSetActive, Boolean active) {
	NSLog(@"AUDIOSESSIONSETACTIVE called!!!");

	UInt32 speaker = 1;
	AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(speaker), &speaker);
	return _AudioSessionSetActive(active);
}


%ctor {
	MSHookFunction(AudioSessionSetActive, MSHake(AudioSessionSetActive));
	NSLog(@"earspeak has loaded!!!");
}*/



#import <AVFoundation/AVFoundation.h>


%hook AVAudioSession
- (BOOL)setActive:(BOOL)active error:(NSError **)error {
	NSLog(@"ACTIVE!!!!------------");
	BOOL ret = %orig;

	[self setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

	return ret;
}

- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)outError {
	NSLog(@"ACTIVE!!!!------------");
	BOOL ret = %orig;

	[self setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

	return ret;
}
%end