/*
  RCPlaybackManager is the only class to communicate with the underlying MediaRemote.framework API.
  It receives requests to control the playback and provides a protocol to notify implementing classes of changes in the playback.

  I am not sure if we should split this up further into iOS-version-specific subclassess...
*/

#import <Foundation/Foundation.h>

@protocol RCPlaybackManagerDelegate // RCPlaybackManager protocol, every class contolling playback should implement this.
-(void) updatedNowPlayingInformation:(NSDictionary *)information;
@end


@interface RCPlaybackManager : NSObject {
    NSTimer *_t;
}
@property (assign) id<RCPlaybackManagerDelegate> delegate; // The delegate protocol messages to be sent to.

-(void) startReceiving; //Naming of this is quite odd .~. TODO: Find a better name!
-(void) togglePlayback:(BOOL)playback;
@end
