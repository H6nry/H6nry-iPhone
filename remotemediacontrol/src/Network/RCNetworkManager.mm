#import "RCNetworkManager.h"

//Helper category. Here for convenience.
@interface NSString (RMCCategory)
-(NSString *) addRMC1Field:(NSString *)string;
@end

@implementation NSString (RMCCategory)
-(NSString *) addRMC1Field:(NSString *)string {
	NSString *newString;
	string = [[NSString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] encoding:NSUTF8StringEncoding];

	if (string == NULL) {
		newString = [self stringByAppendingString:@"00000"];
	} else {
		NSString *length = [NSString stringWithFormat:@"%05lu", (unsigned long)string.length];
		newString = [[self stringByAppendingString:length] stringByAppendingString:string];
	}

	return newString;
}
@end


static void cfBonjourCallback(CFNetServiceRef theService, CFStreamError * error, void  *cself) {
	NSLog(@"RMC: Bonjour callback! Error: %i.", (int)error->error);
}

static void cfSocketCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *cself) {
	//If we got an accept callback.
	if (callbackType == kCFSocketAcceptCallBack) {
		CFSocketNativeHandle nativeHandle = *(CFSocketNativeHandle *)data;
		[NSThread detachNewThreadSelector:@selector(handleAcceptCallback:) toTarget:(__bridge id)cself withObject:[NSNumber numberWithInteger:nativeHandle]];
	} else {
		DLog(@"Callbacktype %lu", callbackType);
	}
}


@implementation RCNetworkManager
-(id) init {
	if (self = [super init]) {
		//Allocate and connect the IPV4/IPV6 sockets. TODO: Add checks if the connection was successful.
		CFSocketContext context = {
			.version = 0,
			.info = (void *)CFBridgingRetain(self), //Here we specify our instance which is sent to all callbacks.
			.retain = NULL,
			.release = NULL,
			.copyDescription = NULL
		};

		_cfSocket4 = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, cfSocketCallback, &context);
		_cfSocket6 = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, cfSocketCallback, &context);

		//IPV4
		struct sockaddr_in sa = { sizeof(sa), AF_INET };

		CFDataRef addr = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8*)&sa, sizeof(sa), kCFAllocatorNull);
		CFSocketSetAddress(_cfSocket4, addr);
		CFRelease(addr);

		addr = CFSocketCopyAddress(_cfSocket4);
		memmove(&sa, CFDataGetBytePtr(addr), sizeof(sa));
		CFRelease(addr);

		//IPV6
		struct sockaddr_in sa6 = { sizeof(sa6), AF_INET };
		sa6.sin_port = sa.sin_port;

		addr = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8*)&sa6, sizeof(sa6), kCFAllocatorNull);
		CFSocketSetAddress(_cfSocket6, addr);
		CFRelease(addr);

		addr = CFSocketCopyAddress(_cfSocket6);
		memmove(&sa6, CFDataGetBytePtr(addr), sizeof(sa6));
		CFRelease(addr);

		//Bonjour / Zeroconf / NSNetService / CFNetService / mDNSResponder , whatever.
		CFNetServiceClientContext bContext = {
			.version = 0,
			.info = (void*)CFBridgingRetain(self),
			.retain = NULL,
			.release = NULL,
			.copyDescription = NULL
		};

		_cfBonjourService = CFNetServiceCreate(kCFAllocatorDefault, CFSTR(""), CFSTR("_rmcp._tcp"), CFSTR("iPhone MediaRemote control"), ntohs(sa.sin_port));

		CFNetServiceSetClient(_cfBonjourService, cfBonjourCallback, &bContext);
	}
	return self;
}

-(void) startReceiving {
	if (!_socketLoopSource4) {
		_socketLoopSource4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _cfSocket4, 0);
	}
	if (!_socketLoopSource6) {
		_socketLoopSource6 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _cfSocket6, 0);
	}

	CFRunLoopAddSource(CFRunLoopGetCurrent(), _socketLoopSource4, kCFRunLoopCommonModes);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), _socketLoopSource4, kCFRunLoopCommonModes);

	CFNetServiceScheduleWithRunLoop(_cfBonjourService, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	CFNetServiceRegisterWithOptions(_cfBonjourService, 0, NULL); //Register the Bonjour service on the network.
}

-(void) stopReceiving {
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _socketLoopSource4, kCFRunLoopCommonModes);
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _socketLoopSource4, kCFRunLoopCommonModes);

	CFNetServiceUnscheduleFromRunLoop(_cfBonjourService, CFRunLoopGetCurrent(), kCFRunLoopCommonModes); //Not sure if this is enough, docs say to make service unavailable by calling some more functions... TODO
}

-(void) receivedData:(NSData *)data {
	DLog(@"RMC: Received %@.", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

	NSDictionary *message = [self parseDataToMessage:data];
	[self.delegate receivedMessage:message];
}

-(void) sendMessage:(NSDictionary *)message {
	DLog(@"RMC: Send message: %@", message);

	NSData *data = [self parseMessageToData:message];
	if (!_queuedMessages) _queuedMessages = [NSMutableArray array];
	[_queuedMessages addObject:data];
}

-(NSDictionary *) parseDataToMessage:(NSData *)data {
	NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	int cursor = 0;

	NSString *senderVersion = [string substringWithRange:NSMakeRange(cursor, 10)]; //TODO: Bounds check, outsource to a second function/class.
	cursor = cursor + 10;
	message[@"versionString"] = senderVersion;

	if ([senderVersion isEqualToString:@"RMCV01PV01"]) {
		NSString *body = [string substringWithRange:NSMakeRange(cursor, 1)];
		cursor = cursor + 1;
		if (![body isEqualToString:@"B"]) return message; //We are wrong. Better exit now.

		NSUInteger typeLength = [[string substringWithRange:NSMakeRange(cursor, 5)] integerValue];
		cursor = cursor + 5;
		NSString *type = [string substringWithRange:NSMakeRange(cursor, typeLength)];
		cursor = cursor + typeLength;
		message[@"type"] = type;
	}

	return message;
}

-(NSData *) parseMessageToData:(NSDictionary *)message {
	NSString *string = NULL;

	if ([message[@"versionString"] isEqualToString:@"RMCV01PV01"]) { //Use protocol version 1 to parse.
		string = message[@"versionString"]; //Magic
		string = [string stringByAppendingString:@"B"]; // Body indicator
		string = [string addRMC1Field:message[@"type"]]; //Type field
		string = [string stringByAppendingString:@"EOF"]; //EOF
	}

	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return data;
}

-(void) handleAcceptCallback:(NSNumber *)native {
	//Open read and write streams.
	CFReadStreamRef readSt;
	CFWriteStreamRef writeSt;

	CFSocketNativeHandle ns = (CFSocketNativeHandle)[native integerValue];

	CFStreamCreatePairWithSocket(kCFAllocatorDefault, ns, &readSt, &writeSt);
	CFReadStreamOpen(readSt);
	CFWriteStreamOpen(writeSt);

	//As long as everthing is fine, just wait for bytes from the read stream
	while (1) {
		unsigned char *buffer;
		size_t num_read;
		size_t buffer_size;
		CFIndex bytes_recvd;
		CFAbsoluteTime lastSockOperation = 0;

		//Dynamically allocate 100 bytes to be filled with received data.
		buffer_size = 100;
		buffer = (unsigned char *)malloc(buffer_size);
		num_read = 0;

		//As long as we do not receive an 'E' 'O' 'F' sequence, just parse data into that buffer.
		while (!(buffer[num_read-3] == 'E' && buffer[num_read-2] == 'O' && buffer[num_read-1] == 'F')) {
			UInt8 dummy[1];

			//If we can read bytes without blocking, read them.
			if (CFReadStreamHasBytesAvailable(readSt)) {
				//Read exactly one single byte at a time.
				bytes_recvd = CFReadStreamRead(readSt, dummy, 1);

				//When there is some kind of error, close streams, close sockets, and free buffer.
				if (bytes_recvd < 0) {
					CFReadStreamClose(readSt);
					CFWriteStreamClose(writeSt);
					CFRelease(readSt);
					CFRelease(writeSt);
					close(ns);
					free(buffer);
					DLog(@"RMC: ERROR with sockt read.");
					return;
				}

				//If the buffer is to small, reallocate it to double size.
				if (num_read >= buffer_size) {
					unsigned char *new_buffer;
					buffer_size *= 2;
					new_buffer = (unsigned char *)realloc(buffer, buffer_size);

					if (new_buffer == NULL) {
						CFReadStreamClose(readSt);
						CFWriteStreamClose(writeSt);
						CFRelease(readSt);
						CFRelease(writeSt);
						close(ns);
						free(buffer);
						DLog(@"RMC: ERROR with buffer size. Too big.");
						return;
					}

					buffer = new_buffer;
				}

				//Save new byte to the buffer.
				buffer[num_read] = dummy[0];
				num_read++;

				//Update the last socket operation with the current time.
				lastSockOperation = CFAbsoluteTimeGetCurrent();
			} else {
				//There are no bytes available. Count down from 10, and then stop this all. Maybe the client just went away without telling us :'(
				if (lastSockOperation == 0) lastSockOperation = CFAbsoluteTimeGetCurrent();
				CFDateRef now = CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
				CFDateRef last = CFDateCreate(kCFAllocatorDefault, lastReadOperation);

				if (CFDateGetTimeIntervalSinceDate(now, last) >= 10.0) {
					CFReadStreamClose(readSt);
					CFWriteStreamClose(writeSt);
					CFRelease(readSt);
					CFRelease(writeSt);
					close(ns);
					free(buffer);
					DLog(@"RMC: Read stream timed out.");
					return;
				}
				CFRelease(now);
				CFRelease(last);
			}

			//Write the queued messages to the write stream.
			if (_queuedMessages.count > 0 && CFWriteStreamCanAcceptBytes(writeSt)) { //_queuedMessages.count > 0 is double code. But for the sake of performance, it is okay.
				while (_queuedMessages.count > 0) {
					NSData *buffer = _queuedMessages[0];
					[_queuedMessages removeObjectAtIndex:0];

					CFWriteStreamWrite(writeSt, (UInt8 *)[buffer bytes], [buffer length]);
				}

				//Update the last socket operation with the current time.
				lastSockOperation = CFAbsoluteTimeGetCurrent();
			}
		}

		NSData *data = [NSData dataWithBytes:buffer length:num_read];

		//Test if we received a PING package. If we did, respond with a PONG package.
		NSDictionary *package = [self parseDataToMessage:data];
		if ([package[@"type"] isEqualToString:@"PING"]) {
			NSMutableDictionary *pong = [NSMutableDictionary dictionaryWithCapacity:2];
			pong[@"versionString"] = @"RMCV01PV01";
			pong[@"type"] = @"PONG";
			[self sendMessage:pong];
		} else {
			//Just forward the received data (one package at a time) to the network manager class.
			[self performSelectorOnMainThread:@selector(receivedData:) withObject:data waitUntilDone:NO];
		}

		free(buffer);
	}
}
@end

/*
---------------------
RemoteMediaControl Protocol - dev
---------------------
!Subject to heavy change!

Concept:
- Socket is created on some port.
- Bonjour advertises the socket in the local area network.
- When a client connects, it does so via bonjour.
- The client opens r/w streams, as well as the server does
- They both communicate via packages
- A package is an UTF8 encoded c string, it is good practice to only use ascii compatible strings, though
- A package starts  with a magic ("RMCV01PV01B" for RMC version 1 protocol version 1) and ends with "EOF"
- In between you have several data fields, all prepended by a number with the format 00009 or 00013 describing the length of the following filed in chars.
- The first data field describes the command to be sent. For example to toggle play/pause, use "00009PLAYPAUSE"
- Discussion: Yes, it would be possible to not use human readable commands, it would also be possible to remove the length indicator. But for the sake of development speed, it is just much easier for understanding and debugging etc.

Package RMC version 1, protocol version 1:
- Valid (UTF8-encoded) C string, preferably ASCII only characters.
- 1. Header with magic and version info.
- 2. Control char "B", to check that the header is closed now.
- 3. Package fields, containing different data for different purpose. Every field is prepended with a 5-char left-aligned number filled up with "0"s to the right. This indicates the length of the following field.
-- 3.1. The first field always describes the package type. It is an ASCII string containing a "human-readable" description of the package type. Valid types are:
---- 3.1.1. "PLAYPAUSE": Toggles playback on the server device. No more fields to append.
---- 3.1.2. "PING": The client shall send this periodically in a time frame small enough that the server receives it AT LEAST every 10 seconds. The server responds then with a "PONG". No more fields to append.
---- 3.1.3. "PONG": The server sends this package as a response to a client "PING" package. No more fields to append.
- 4. An "EOF" character sequence indicating the end of a single logical package. It is allowed to send an "EOF" package with all fields 0 to make sure no zombie packages are waited for on client/server side.
- Example package:

                   RMCV01PV01B00009PLAYPAUSEEOF
				   [_][_][__]_[___][_______][_]
				    |  |  |  | |    |        |
					|  |  |  | |    |        *------ The obligatory EOF sequence. If you do not send it, the package will not be recognized as such!
					|  |  |  | |    *--------------- The package type field, containing the package type "PLAYPAUSE".
					|  |  |  | *-------------------- The field's length, this means: the following field is exactly 9 characters long.
					|  |  |  *---------------------- The body indicator. You can use this to make sure that you are still right
					|  |  *------------------------- "PV01", this indicates that protocol version 1 is used here.
					|  *---------------------------- "V01", this indicates that this RemoteMediaControl build has major number 1.
					*------------------------------- "RMC", the package magic. Use this to differentiate from other programs which might send something to you by accident.

!!!!!!!!!!!!!! EOF darf dann aber auf keinen Fall irgendwo außer am ende vorkommen! NICHT GUT!!!!!!!!!!!
*/
