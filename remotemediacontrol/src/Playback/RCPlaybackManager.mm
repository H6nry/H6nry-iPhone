#import "RCPlaybackManager.h"

// Implementation to be done yet.

@implementation RCPlaybackManager
-(void) startReceiving {
	DLog();
	return;
}
-(void) togglePlayback:(BOOL)playback {
	DLog();
	_t = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(testAsync) userInfo:nil repeats:NO];

	return;
}
-(void)testAsync {
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
	info[@"song"] = @"Soul Kitchen";
	info[@"artist"] = @"The Doors";

	[self.delegate updatedNowPlayingInformation:info];
}
@end
