#import "Tweak.h"
#define NF_VERSION_STRING @"NCForward/2.3-dev"

%group main
@interface NSString (NCForwardCategory)
-(NSString *) addToNFString:(NSString *)string;
-(NSString *) addNFField:(NSString *)string;
@end

@interface NFSending : NSObject <NSURLConnectionDataDelegate> {
	int _socket;
}
@property (nonatomic, copy) NSString *targetIP;
@property BOOL enabled;
@property BOOL pushbulletEnabled;
@property (nonatomic, copy) NSString *pushbulletAccessToken;
@property (strong, nonatomic) NSMutableArray *targetDevices;
@property (strong, nonatomic) NSMutableArray *sourceApplicationIDs;

+(id) sharedInstance;
-(BOOL) sendBulletin:(BBBulletin *)bulletin;
-(BOOL) sendBulletinToLan:(BBBulletin *)bulletin;
-(BOOL) sendBulletinToPushbullet:(BBBulletin *)bulletin;
-(BOOL) sendMessageToLan:(NSString *)message;
-(void) loadPreferences;
@end


static NSArray *allApplications;

static void loadPrefs() { //Stupid callback because Foundation cannot access DarwinNotifyCenter.
	[[NFSending sharedInstance] loadPreferences];
}

static void NFUpdatePreferenceAppList() {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		//As we already hook into SpringBoard here, we can load a list of installed applications as well.
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"];
		if (prefs == nil) {
			prefs = [NSMutableDictionary dictionaryWithCapacity:1];
		}

		NSMutableDictionary *sendFromDictionary = [prefs objectForKey:@"sendFrom"]; //Read existing sendFrom dictionary.
		if (sendFromDictionary == nil) {
			sendFromDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
		}

		for (SBApplication *app in allApplications) { //Iterate through all existing applications and parse them into the sendFrom dictionary.
			NSMutableDictionary *oldAppName = [sendFromDictionary objectForKey:[app bundleIdentifier]];
			if (oldAppName == nil) {
				oldAppName = [NSMutableDictionary dictionaryWithCapacity:1];
				[oldAppName setObject:@YES forKey:@"enabled"]; //By default, set app enabled.
			}

			NSMutableDictionary *preparedAppName = [NSMutableDictionary dictionaryWithCapacity:2];

			[preparedAppName setObject:[oldAppName objectForKey:@"enabled"] forKey:@"enabled"];
			[preparedAppName setObject:([app displayName] ? [app displayName] : @"No name") forKey:@"name"];
			[preparedAppName setObject:([app bundleIdentifier] ? [app bundleIdentifier] : @"no.bundle.id") forKey:@"bundle-id"];

			[sendFromDictionary setObject:preparedAppName forKey:[app bundleIdentifier]];
		}

		[prefs setObject:sendFromDictionary forKey:@"sendFrom"];
		[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist" atomically:YES];
	});
}



//Some convenient stuff to make creating messages easier.
@implementation NSString (NCForwardCategory)
-(NSString *) addToNFString:(NSString *)string {
	if (string == NULL) {
		self = [[self stringByAppendingString:@"%!"] stringByAppendingString:@"NULL"];
	} else {
		self = [[self stringByAppendingString:@"%!"] stringByAppendingString:string];
	}

	return self;
}

-(NSString *) addNFField:(NSString *)string {
	string = [[NSString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] encoding:NSUTF8StringEncoding];

	if (string == NULL) {
		self = [self stringByAppendingString:@"00000"];
	} else {
		NSString *length = [NSString stringWithFormat:@"%05lu", (unsigned long)string.length];
		self = [[self stringByAppendingString:length] stringByAppendingString:string];
	}

	return self;
}
@end



//The class for sending (and receiving) NCForward messages.
static NFSending *_sharedInstance = nil;

@implementation NFSending
+(id) sharedInstance {
	@synchronized(self) {
		if (!_sharedInstance) {
			_sharedInstance = [[self alloc] init];
		}
		return _sharedInstance;
	}
}

-(id) init {
	if (self=[super init]) {
		//Initialize all properties with "valid" values.
		self.targetIP = @"255.255.255.255";
		self.enabled = 0;
		self.pushbulletEnabled = 0;
		self.pushbulletAccessToken = @"n.NOACC3SST0KEN";
		self.sourceApplicationIDs = [[NSMutableArray alloc] init];
		self.targetDevices = [[NSMutableArray alloc] init];

		[self loadPreferences]; //Load the serious preferences.
	}
	return self;
}

-(BOOL) sendBulletin:(BBBulletin *)bulletin {
	if ([self.sourceApplicationIDs indexOfObject:bulletin.sectionID] != NSNotFound) {
		if (self.enabled) [self sendBulletinToLan:bulletin];
		if (self.pushbulletEnabled) [self sendBulletinToPushbullet:bulletin];
		NSLog(@"NCForward: Sent notification to LAN: %i and Pushbullet: %i.", self.enabled, self.pushbulletEnabled);
		return YES;
	}

	return NO;
}

-(BOOL) sendBulletinToLan:(BBBulletin *)bulletin {
	//IMPORTANT: This is depreceated as of protocol version 2, but due to compatibility reasons retained for a short time here.
	NSString *BulletinMessageToSend = @"NCFV1_PV1";
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.sectionDisplayName];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.topic];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.sectionID];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.content.title];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.content.subtitle];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.content.message];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:[bulletin.date description]];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"This is depreceated. Use protocol version 2 instead."];

	[self sendMessageToLan:BulletinMessageToSend];

	//IMPORTANT: Rely on this as of now.
	NSString *messageToSend = @"NCFV2_PV21B";
	messageToSend = [messageToSend addNFField:bulletin.content.title];
	messageToSend = [messageToSend addNFField:bulletin.content.message];
	messageToSend = [messageToSend addNFField:bulletin.sectionID];
	messageToSend = [messageToSend addNFField:bulletin.bulletinID];

	[self sendMessageToLan:messageToSend];

	return NO;
}

-(BOOL) sendBulletinToPushbullet:(BBBulletin *)bulletin { //TODO: Implement device selectivity.
	if ([bulletin.sectionID isEqualToString:@"com.pushbullet.client"]) return NO; //Pushbullet is deactivated by default.
	BOOL allSuccess = 1;

	for (NSString *deviceID in self.targetDevices) {
		NSMutableDictionary *post = [[NSMutableDictionary alloc] initWithCapacity:3]; //The JSON object dictionary. Quite convenient, eh?
	   	[post setObject:@"note" forKey:@"type"];
	   	[post setObject:deviceID forKey:@"target_device_iden"];
	   	if (bulletin.content.title) [post setObject:bulletin.content.title forKey:@"title"]; //That 'if' prevents a very rare crash, i had once.
	   	if (bulletin.content.message) [post setObject:bulletin.content.message forKey:@"body"];
		NSData *postData = [NSJSONSerialization dataWithJSONObject:post options:0 error:NULL]; //Definitely convenient.

		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:@"https://api.pushbullet.com/v2/pushes"]];
		[request setHTTPMethod:@"POST"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

		[request setValue:self.pushbulletAccessToken forHTTPHeaderField:@"Access-Token"];
		[request setValue:NF_VERSION_STRING forHTTPHeaderField:@"User-Agent"]; //So they know who is the boss.
		[request setHTTPBody:postData];

		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

		if (!conn) {
			NSLog(@"NCForward: Error, NSURLConnection cannot be initialized.");
			allSuccess = 0;
		}
	}

	return allSuccess;
}

-(BOOL) sendMessageToLan:(NSString *)message {
	if (_socket <= 0) {
		_socket = socket(AF_INET, SOCK_DGRAM, 0); //Create a new BSD socket
		if (_socket <= 0) {
			NSLog(@"NCForward: Failed creating socket.");
			return NO;
		}
	}

	NSMutableString *ipp = [NSMutableString stringWithString:self.targetIP]; //Is this really neccessary?

	if (!ipp.length) {
		[ipp setString:@"255.255.255.255"];
	}

	NSData *messaged = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

	struct sockaddr_in addr; //Create structure of type sockaddr_in named addr
	memset(&addr, 0, sizeof(addr)); //Initialize memory region to 0
	addr.sin_len = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_port = htons(3156); //NCForward port is 3156
	inet_aton([ipp cStringUsingEncoding:NSASCIIStringEncoding], &addr.sin_addr);

	ssize_t sent = sendto(_socket, [messaged bytes], [messaged length], MSG_DONTWAIT, (const sockaddr *)&addr, sizeof(addr)); //Send it to heaven or to hell.

	if (sent < 0) {
		NSLog(@"NCForward: Failed to send message to lan.");
	}

	return (sent > 0);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//TODO: Maybe check here if everything went right, not important, though.
}

-(void) loadPreferences {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.prefs.plist"]; //One shall not use this for manually set preferences.

	self.targetIP = [prefs objectForKey:@"ip"];
	self.enabled = [[prefs objectForKey:@"enable"] boolValue];
	self.pushbulletEnabled = [[prefs objectForKey:@"enablepushbullet"] boolValue];

	NSDictionary *pbPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"]; //This is the dictionary for all manually set preferences.
	if (pbPrefs == nil) {
		pbPrefs = [NSDictionary dictionary];
	}
	self.pushbulletAccessToken = [pbPrefs objectForKey:@"access_token"];

	NSDictionary *sendFromDictionary = [pbPrefs objectForKey:@"sendFrom"];
	if (sendFromDictionary == nil) {
		sendFromDictionary = [NSDictionary dictionary];
	}
	[self.targetDevices removeAllObjects];
	for (NSString *appID in sendFromDictionary) {
		if ([[[sendFromDictionary objectForKey:appID] objectForKey:@"enabled"] isEqual:@YES]) {
			[self.sourceApplicationIDs addObject:appID];
		}
	}

	NSDictionary *sendToDictionary = [pbPrefs objectForKey:@"sendTo"];
	if (sendToDictionary == nil) {
		sendToDictionary = [NSDictionary dictionary];
	}
	[self.targetDevices removeAllObjects];
	for (NSString *deviceID in sendToDictionary) {
		if ([[[sendToDictionary objectForKey:deviceID] objectForKey:@"enabled"] isEqual:@YES]) {
			[self.targetDevices addObject:deviceID];
		}
	}
}
@end



%hook SBBulletinBannerController
- (void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(NSUInteger)feed { //<8.3
	[[NFSending sharedInstance] sendBulletin:bulletin];
	NSLog(@"NCForward: Tried forwarding notification on <8.3.");

	%orig;
}

-(void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(unsigned)feed playLightsAndSirens:(BOOL)sirens withReply:(id)reply { //>=8.3
	[[NFSending sharedInstance] sendBulletin:bulletin];
	NSLog(@"NCForward: Tried forwarding notification on >=8.3.");

	%orig;
}
%end

%hook SBApplicationController //Anyone knows how to solve it better?? Tried with dispatch_async but I was too stupid :(
-(id) init {
	id ret = %orig;
	allApplications = [self allApplications];
	NFUpdatePreferenceAppList();

	return ret;
}
%end

/*%hook SBVoiceControlController
-(BOOL)handleHomeButtonHeld {
	[[NFSending sharedInstance] sendMessageToLan:@"NCFV2_PV21B00005Hello00015This is a test.00017org.h6nry.testapp00003315"];

	return nil;
}
%end *///Test and debug stuff! Hold home button to fire notification to LAN.
%end




%ctor {
	@autoreleasepool {
		%init(main);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.h6nry.ncforward.prefs/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}


/*
---------------------
NCForward Protocol V3 - dev
---------------------

----- Not implemented yet, subject to change! -----

There is a huge change in NCForward now! Servers are now allowed to be asked wether they can be connected to or not.
This means, that NCForward (in reality it is the preference panel) will send a "ping" to available servers in your LAN
and if the server responds, the user will be able to choose wether he allows NCForward to send notifications to that
server or not. The technical details have to be worked out yet. Also, the user will still be able to manually specify
an IP address in the preference panel.

At the packets, we stay mostly with protocol V.2.
New thing is that NCForward will send images now. The coressponding field will be appended to the end of the body.
This assures 100% backward compatibility with protocol V.2.

Another *concept* is to send a device identifier with the packets, this has to be worked out yet.
Sense behind this is that the servers could identify devices (when you have multiple NCForward-enabled devices in your network).


---------------------
NCForward Protocol V2
---------------------

We stay with UDP packets, they are the fastest.

The Header stays the same as well:
- 3 chars NCF as magic
- 1 char V for version
- 1 char revision number
- 1 char _ as separator
- 2 chars PV for protocol version
- 1 char protocol revision number

The rest changed, we are still char-based, this prevents too much confusion and byte-madness:
- 1 char 1 or 0 to indicate if this packet was already sent with another protocol revision. this is for backwards-compatibility
- 1 char B to indicate body
- 5 chars to indicate the length of the first field: title
- X chars for the title of the notification
- 5 chars length of field: message
- X chars for the message
- 5 chars length of field: bundle-id
- X chars for the bundle-id of the app the notification was sent from
- 5 chars length of field: bulletin-id
- X chars for the bulletin-id of the notification

Example message:
@"NCFV2_PV21B00005Hello00015This is a test.00017org.h6nry.testapp00003315"

Example message with protocol version 1:
@"NCFV1_PV1%!BlaBlaBla%!MoreBlaBla%!com.bla.bla%!Title, hello.%!Sub-bla-bla-bla%!Message, this is a test%!13:05 UTC bla%!This is depreceated. Use protocol version 2 instead."

Advantage of this technique is that there is no critical sequence anymore, so you cannot break NCForward protocol with malformed messages.
Also, we have shrinked the transmitted size to only relevant information as well.
Why exactly five chars for the length of one field? A UDP packet's maximum size in theory would be something around 65000 bytes. So i thought 5 chars are the perfect size, 4 would be not enough, and 6 just overhead.
Why did you choose to implement it like this? Why don't just send JSON objects? Because of overhead. NCForward protocol is build for speed, a key-value-coding would be too much, although extendable.

*/
