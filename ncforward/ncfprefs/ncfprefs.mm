#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#define NF_VERSION_STRING @"NCForward/2.2-dev"

@class PSRootController;

@interface ncfprefsListController: PSListController <UIWebViewDelegate> {
	UIView *pbView;
}
-(void) pushbullet;
-(void) hidePushbullet;
@end

@implementation ncfprefsListController //The main list controller.
-(id) specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ncfprefs" target:self] retain];
	}
	return _specifiers;
}

-(void) twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/H6nry_/"]];
}

-(void) mail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:henry.anonym@gmail.com"]];
}

-(void) website {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://h6nry.github.io/"]];
}

-(void) apply {
    system("killall -9 SpringBoard");
}

-(void) pushbullet { //TODO: outsource this to a separate PSListController without popup.
	pbView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	pbView.backgroundColor = [UIColor lightGrayColor];
	[[UIApplication sharedApplication].keyWindow addSubview:pbView];

	UIButton *closeView = [UIButton buttonWithType:UIButtonTypeSystem];
	[closeView setTitle:@"(X) Close" forState:UIControlStateNormal];
	closeView.backgroundColor = [UIColor whiteColor];
	closeView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 20);
	[closeView addTarget:self action:@selector(hidePushbullet) forControlEvents:UIControlEventTouchUpInside];
	[pbView addSubview:closeView];

	CGRect frame = CGRectMake([[UIScreen mainScreen] applicationFrame].origin.x, [[UIScreen mainScreen] applicationFrame].origin.y, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height-20);
	UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
	NSString *requestURL = [NSString stringWithFormat:@"https://www.pushbullet.com/authorize?client_id=%@&redirect_uri=%@&response_type=token", @"18vD2i4vm0iQD206CVXKHJWncEiq5dtT", @"https://h6nry.github.io/Files/pushbullet.ncforward.success.html"];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]]];
	webView.delegate = self;

	[pbView addSubview:webView];
}

-(void) hidePushbullet {
	[pbView removeFromSuperview];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { //Check if the user approved NCForward access. TODO: Error checking.
	NSURL *url = request.URL;

	NSString *basicPathString = [NSString stringWithFormat:@"%@://%@:%@%@", url.scheme, url.host, url.port, url.path];
	NSURL *cleanUrl = [[NSURL URLWithString:basicPathString] standardizedURL]; //Make the URL standarized enough.
	
	if ([cleanUrl isEqual:[[NSURL URLWithString:@"https://h6nry.github.io/Files/pushbullet.ncforward.success.html"] standardizedURL]] && url.fragment && url.fragment.length > 13) { //If we are right.
		NSString *token = [url.fragment substringFromIndex:13]; //13 length of string "access_token=".

		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"];
		if (prefs == nil) {
			prefs = [NSMutableDictionary dictionaryWithCapacity:1];
		}

		[prefs setValue:token forKey:@"access_token"]; //Maybe one should find a safer solution...
		[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist" atomically:YES];
		[webView loadHTMLString:@"Success! You can close this page right now." baseURL:[NSURL URLWithString:@"https://h6nry.github.io/"]];
	}
	
	return YES;
}
@end



@interface PBSendToListController : PSListController <NSURLConnectionDataDelegate> {
	NSURLConnection *_deviceListConnection;
	NSURLConnection *_userObjectConnection;
}
-(id) readSendToValue:(PSSpecifier *)specifier;
-(void) setSendToValue:(id)value specifier:(PSSpecifier *)specifier;
@end

@implementation PBSendToListController //The send notifications to controller. TODO: Group PSSwitchCells
-(id) specifiers { //When this settings page is loaded.
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Send notifications to" target:self] retain];

		NSDictionary *pbPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"]; //This is the dictionary for all manually set preferences.
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:@"https://api.pushbullet.com/v2/users/me"]];
		[request setValue:[pbPrefs objectForKey:@"access_token"] forHTTPHeaderField:@"Access-Token"];
		[request setValue:NF_VERSION_STRING forHTTPHeaderField:@"User-Agent"];
		
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //First request the user data.
		if (!conn) NSLog(@"NCForward-prefs: PBSendToListController failed creating NSURLConnection for user_iden.");
		_userObjectConnection = conn;

		//TODO-FUTURE: Implement Protocol V3 here.
	}
	return _specifiers;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];

	if ([connection isEqual:_userObjectConnection]) { //Process the user data.
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"];
		if (prefs == nil) {
			prefs = [NSMutableDictionary dictionaryWithCapacity:1];
		}

		[prefs setValue:[jsonData objectForKey:@"iden"] forKey:@"user_iden"];
		[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist" atomically:YES];

		
		NSDictionary *pbPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"]; //This is the dictionary for all manually set preferences.

		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:@"https://api.pushbullet.com/v2/devices?limit=10"]];
		[request setValue:[pbPrefs objectForKey:@"access_token"] forHTTPHeaderField:@"Access-Token"];
		[request setValue:NF_VERSION_STRING forHTTPHeaderField:@"User-Agent"];
		
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //Now request the device list data.
		if (!conn) NSLog(@"NCForward-prefs: PBSendToListController failed creating NSURLConnection for device_list.");
		_deviceListConnection = conn;
	}

	if ([connection isEqual:_deviceListConnection]) { //Process the device data.
		NSArray *deviceList = [jsonData objectForKey:@"devices"];
		
		for (NSDictionary *device in deviceList) { //For every device, make a new cell.
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:[device objectForKey:@"nickname"] target:self set:@selector(setSendToValue:specifier:) get:@selector(readSendToValue:) detail:Nil cell:PSSwitchCell edit:Nil]; //"set" is NOT default.
			
			if ([specifier name] == nil) specifier.name = @"NO NAME";
			[specifier setProperty:[device objectForKey:@"iden"] forKey:@"key"];
			[specifier setProperty:@"org.h6nry.ncforward.prefs/settingschanged" forKey:@"PostNotification"];

			if ([[device objectForKey:@"active"] isEqual:@NO]) { //Could never test this properly. I just hope it works...
				[self setSendToValue:@NO specifier:specifier];
				continue;
			}

			[self addSpecifier:specifier animated:YES];
		}
	}
}

-(id) readSendToValue:(PSSpecifier *)specifier { //We have to set the toggle state here.
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"];
	if (prefs == nil) {
		prefs = [NSDictionary dictionary];
	}

	NSDictionary *sendToDictionary = [prefs objectForKey:@"sendTo"];
	if (sendToDictionary == nil) {
		sendToDictionary = [NSDictionary dictionary];
	}

	NSDictionary *deviceToRead = [sendToDictionary objectForKey:[specifier propertyForKey:@"key"]]; //We look up the enabled state via the bundleIdentifier, quite convenient, eh?

	return [deviceToRead objectForKey:@"enabled"];
}

-(void) setSendToValue:(id)value specifier:(PSSpecifier *)specifier { //Here, we store the toggle value.
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"];
	if (prefs == nil) {
		prefs = [NSMutableDictionary dictionaryWithCapacity:1];
	}

	NSMutableDictionary *sendToDictionary = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"sendTo"]]; //Inside of prefs.
	if (sendToDictionary == nil) {
		sendToDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
	}

	NSMutableDictionary *objectToChange = [NSMutableDictionary dictionaryWithCapacity:2]; //Create a new object to change.
	[objectToChange setObject:(id)value forKey:@"enabled"];
	[objectToChange setObject:[specifier name] forKey:@"name"];

	[sendToDictionary setObject:objectToChange forKey:[specifier propertyForKey:@"key"]]; //Write object to coressponding dictionary.
	[prefs setObject:sendToDictionary forKey:@"sendTo"]; //Write dictionary to file.
	
	[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist" atomically:YES]; //Write file to system.
}
@end



@interface PBSendFromListController : PSListController <NSURLConnectionDataDelegate> {
}
-(id) readSendFromValue:(PSSpecifier *)specifier;
-(void) setSendFromValue:(id)value specifier:(PSSpecifier *)specifier;
@end

@implementation PBSendFromListController //The PSListController to specify the apps noftifications being sent from.
-(id) specifiers { //When this settings page is loaded.
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Send notifications from" target:self] retain]; //First, read the plist.

		NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"]; //Manually set preferences file
		if (prefs == nil) {
			prefs = [NSDictionary dictionary];
		}

		NSDictionary *sendFromDictionary = [prefs objectForKey:@"sendFrom"];
		if (sendFromDictionary == nil) {
			sendFromDictionary = [NSDictionary dictionary];
		}

		for (NSString *appID in sendFromDictionary) { //For each app, create a new PSSWitchCell.
			NSDictionary *appName = [sendFromDictionary objectForKey:appID];
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:[appName objectForKey:@"name"] target:self set:@selector(setSendFromValue:specifier:) get:@selector(readSendFromValue:) detail:Nil cell:PSSwitchCell edit:Nil]; //"set" is NOT default.

			[specifier setProperty:[appName objectForKey:@"enabled"] forKey:@"default"];
			[specifier setProperty:appID forKey:@"key"];
			[specifier setProperty:@"org.h6nry.ncforward.prefs/settingschanged" forKey:@"PostNotification"];

			[self addSpecifier:specifier animated:YES]; //Add the cell. This automatically groups the cell into the specified in the plist.
		}
	}
	return _specifiers;
}

-(id) readSendFromValue:(PSSpecifier *)specifier { //This looks stupid, but we need it, for some weird reason.
	return [specifier propertyForKey:@"default"];
}

-(void) setSendFromValue:(id)value specifier:(PSSpecifier *)specifier { //Write all stuff to the preferences file again.
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist"];
	if (prefs == nil) {
		prefs = [NSMutableDictionary dictionaryWithCapacity:1];
	}

	NSMutableDictionary *sendFromDictionary = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"sendFrom"]];
	if (sendFromDictionary == nil) {
		sendFromDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
	}

	NSMutableDictionary *objectToChange = [NSMutableDictionary dictionaryWithCapacity:2];
	[objectToChange setObject:value forKey:@"enabled"];
	[objectToChange setObject:[specifier name] forKey:@"name"];
	[objectToChange setObject:[specifier propertyForKey:@"key"] forKey:@"bundle-id"];

	[sendFromDictionary setObject:objectToChange forKey:[specifier propertyForKey:@"key"]];
	[prefs setObject:sendFromDictionary forKey:@"sendFrom"];
	
	[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.more.plist" atomically:YES];
}
@end
