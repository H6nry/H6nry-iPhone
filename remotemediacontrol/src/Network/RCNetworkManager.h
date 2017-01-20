/*
RCNetworkManager is the class to communicate with the network and the world wide web.
It provides methods to send and receive messages and a protocol which provides an easy access to received messages.

Notes on this:
- If the daemon runs for too long, it seems like mDNSResponder shuts down its bonjour service. Disabling and reenabling WiFi/Cellular data reactivates mDNSResponder. Is this still a problem?
*/

#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@protocol RCNetworkManagerDelegate // RCNetworManager protocol, every class sending messages should implement this.
-(void) receivedMessage:(NSDictionary *)message;
@end


@interface RCNetworkManager : NSObject {
	CFSocketRef _cfSocket4;
	CFSocketRef _cfSocket6;
	CFRunLoopSourceRef _socketLoopSource4;
	CFRunLoopSourceRef _socketLoopSource6;

	CFNetServiceRef _cfBonjourService;
	NSMutableArray<NSData *> *_queuedMessages;
}
@property (assign) id<RCNetworkManagerDelegate> delegate; // The delegate protocol messages to be sent to.

-(void) startReceiving;
-(void) stopReceiving;
-(void) receivedData:(NSData *)data;
-(void) sendMessage:(NSDictionary *)message;
-(NSDictionary *) parseDataToMessage:(NSData *)data;
-(void) handleAcceptCallback:(NSNumber *)sock;
@end
