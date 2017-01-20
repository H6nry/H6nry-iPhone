#import "RCController.h"

@implementation RCController
// Own methods to be implemented here
-(id) init {
	if (self = [super init]) {
		_networkManager = [[RCNetworkManager alloc] init];
		_playbackManager = [[RCPlaybackManager alloc] init];
		if (!_networkManager || !_playbackManager) DLog(@"RMC: Failed at initializing %@ or %@.", _networkManager, _playbackManager);

		_networkManager.delegate = self;
		_playbackManager.delegate = self;

		//No good style... We should put this in a second method. -(init) is not responsible for doing anything here.
		[_networkManager startReceiving];
		[_playbackManager startReceiving];
	}
	return self;
}

// RCNetworkManager delegate
-(void) receivedMessage:(NSDictionary *)message {
	//This is the bridge from network manager to playback manager. We look at the message type here and call the appropriate method in playback manager delegate.
	if ([message[@"type"] isEqualToString:@"PLAYPAUSE"]) {
		[_playbackManager togglePlayback:YES];
	}

	return;
}

// RCPlaybackManager delegate
-(void) updatedNowPlayingInformation:(NSDictionary *)information {
	//This is the bridge from playback to network manager. We use the now playing information here and put them together into a network message.
	NSMutableDictionary *message = [NSMutableDictionary dictionaryWithCapacity:2];
	message[@"versionString"] = @"RMCV01PV01";
	message[@"type"] = @"UPDATENOWPLAYING";
	message[@"song"] = information[@"song"];
	message[@"artist"] = information[@"artist"];

	[_networkManager sendMessage:message];
	return;
}

@end
