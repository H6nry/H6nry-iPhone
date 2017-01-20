/*
  RCController tapes together RCNetworkManager and RCPlaybackManager. Information from one is being processed and sent to the other.
  It is being inherited from the main function of the daemon.
*/

#import <Foundation/Foundation.h>
#import "Network/RCNetworkManager.h"
#import "Playback/RCPlaybackManager.h"

@interface RCController : NSObject <RCNetworkManagerDelegate, RCPlaybackManagerDelegate> {
	RCNetworkManager *_networkManager;
	RCPlaybackManager *_playbackManager;
}
// Own methods to be specified here

@end
