#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


@interface CRHelper : NSObject
-(void) synchronizeTimesFromCurrent:(NSDictionary *)timer;
@end

static void prefsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
BOOL prefsEnabled;

id observerToRetain = nil;
CRHelper *_helper = nil;


%group main

%hook AVQueuePlayer
- (void)insertItem:(AVPlayerItem *)itemn afterItem:(id)arg2 {
	//The caller of this method only inserts 2 items at most: The current song, and the next song.
	%orig;

	if (observerToRetain) [self removeTimeObserver:observerToRetain]; //Remove any observers. This was recommended somewhere around the internet.

	//Calculate the time when an observer block shall be called.
	Float64 duration = CMTimeGetSeconds(self.currentItem.asset.duration);
	CMTime time = CMTimeMakeWithSeconds(duration-10-2, 600);
	NSArray *times = [NSArray arrayWithObject:[NSValue valueWithCMTime:time]];

	__block AVQueuePlayer *bself = self; //Make self ready for dispatch.

	//Add the observer.
	observerToRetain = [self addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^(void) {
		//When the current song (current) passed its duration minus 12 seconds.
		AVPlayerItem *current = bself.currentItem;

		if (current && prefsEnabled) {
			NSLog(@"crossfade: Time to fade!");

			//We have to set this :( it breaks lots of other things like lockscreen music controls etc.
			UInt32 setProperty = 1;
			AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(setProperty), &setProperty); //TODO: Deprecated. Use AVFAudio objc API instead.
			//[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil]

			//Set up the cross-fade player. We need a second player due to the serial anatomy of an AVQueuePlayer, which is being used for playback in the music app.
			AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[(AVURLAsset *)current.asset URL] error:NULL];
			Float64 toSeek = CMTimeGetSeconds(current.currentTime)+2.0f; //Advance everything +2 seconds, so the system has the chance to preload everything.
			player.currentTime = toSeek;
			[player prepareToPlay];
			[player playAtTime:player.deviceCurrentTime+2.0f]; //Play precisely at this time.
			player.volume = 1.0f;

			NSDictionary *userInfo = @{
										@"player" : player,
										@"current" : current,
										@"bself" : bself,
										@"toSeek" : [NSNumber numberWithFloat:toSeek]
										};
			if (_helper == nil) _helper = [[CRHelper alloc] init];

			[NSThread detachNewThreadSelector:@selector(synchronizeTimesFromCurrent:) toTarget:_helper withObject:userInfo]; //Dispatch blocking tasks into a second thread.
		}
	}];
}
%end


@implementation CRHelper
-(void) synchronizeTimesFromCurrent:(NSDictionary *)timer {
	NSDictionary *players = timer;

	AVAudioPlayer *player = players[@"player"];
	AVPlayerItem *current = players[@"current"];
	AVQueuePlayer *bself = players[@"bself"];
	Float64 toSeek = [players[@"toSeek"] floatValue];

	BOOL madeFade = NO;
	//Block everything until a break occurs (the case when the cross-player has finished playing its last seconds).
	while (1) {
		if (player.currentTime > toSeek+0.01) {
			if ([bself.currentItem isEqual:current]) { //The cross-player is playing now. The queue-player has not advanced to the next item yet.
				//Advance to the next song, the cross-player is playing the current song now
				[bself performSelectorOnMainThread:@selector(advanceToNextItem) withObject:nil waitUntilDone:YES];
			} else { //The cross-player is playing now. The queue-player advanced to the next item.
				//Fade out the cross-player (old song).
				Float64 timeout = player.currentTime-toSeek;
				if (timeout < 0.0f) timeout = 0.0f;
				if (timeout > 10.0f) timeout = 10.0f;

				Float64 outVolume = (10.f-timeout)/10.0f;
				player.volume = outVolume;

				//Fade in the queue-player (new song).
				if (madeFade == NO) {
					[self performSelectorOnMainThread:@selector(makeFadeIn:) withObject:bself waitUntilDone:YES];
					madeFade = YES;
				}
			}
		}

		if (player.currentTime == 0.0f) break;

		[NSThread sleepForTimeInterval:0.1];
	}

	//Try to unset this one. Not possible because playback stops afterwards...
	//UInt32 setProperty = 0;
	//AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(setProperty), &setProperty);

	NSLog(@"crossfade: Faded!");
}

-(void) makeFadeIn:(AVQueuePlayer *)bself {
	//Magic. Configure the current item to fade in. Doing this via an AVAudioMix.
	NSArray *audioTracks = [bself.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
	NSMutableArray *allAudioParams = [NSMutableArray array];

	for (AVAssetTrack *track in audioTracks) {
		AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
		[audioInputParams setVolume:0.0f atTime:CMTimeMakeWithSeconds(0, 1)];
		[audioInputParams setVolume:0.2f atTime:CMTimeMakeWithSeconds(2, 1)];
		[audioInputParams setVolume:0.4f atTime:CMTimeMakeWithSeconds(4, 1)];
		[audioInputParams setVolume:0.6f atTime:CMTimeMakeWithSeconds(6, 1)];
		[audioInputParams setVolume:0.8f atTime:CMTimeMakeWithSeconds(8, 1)];
		[audioInputParams setVolume:1.0f atTime:CMTimeMakeWithSeconds(10, 1)];

		[audioInputParams setTrackID:[track trackID]];

		[allAudioParams addObject:audioInputParams];
	}

	AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
	[audioMix setInputParameters:allAudioParams];
	[bself.currentItem setAudioMix:audioMix];
}
@end

%end


static void prefsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	//Load ...blahblah... update ...blahblah...
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.crossfade-musicprefs-hook.plist"];
	if (prefs == nil) {
		prefs = [NSDictionary dictionary];
	}

	id value = prefs[@"MusicCrossfadeEnabledSetting"];
	if (value == nil || [value isEqual:@YES]) {
		prefsEnabled = YES;
	} else {
		prefsEnabled = NO;
	}
}


%ctor {
	//Register for settings change notifications.
	CFStringRef notificationName = CFSTR("org.h6nry.crossfade/prefs-changed");
	CFNotificationCenterRef notificationCenter = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(notificationCenter, NULL, prefsChangedCallback, notificationName, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	prefsChangedCallback(nil, nil, nil, nil, nil); //Call manually to update preferences once.

	if (prefsEnabled) {
		%init(main);
	}
}
