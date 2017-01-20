#import <Foundation/Foundation.h>


//FOUNDATION_EXTERN SInt32 CFUserNotificationDisplayAlert ( CFTimeInterval timeout, CFOptionFlags flags, CFURLRef iconURL, CFURLRef soundURL, CFURLRef localizationURL, CFStringRef alertHeader, CFStringRef alertMessage, CFStringRef defaultButtonTitle, CFStringRef alternateButtonTitle, CFStringRef otherButtonTitle, CFOptionFlags *responseFlags );
typedef struct __CFUserNotification *CFUserNotificationRef;
FOUNDATION_EXTERN CFUserNotificationRef CFUserNotificationCreate ( CFAllocatorRef allocator, CFTimeInterval timeout, CFOptionFlags flags, SInt32 *error, CFDictionaryRef dictionary );
FOUNDATION_EXTERN SInt32 CFUserNotificationReceiveResponse ( CFUserNotificationRef userNotification, CFTimeInterval timeout, CFOptionFlags *responseFlags );
FOUNDATION_EXTERN CFDictionaryRef CFUserNotificationGetResponseDictionary ( CFUserNotificationRef userNotification );


BOOL canContinue = NO;
NSString *currentVersionId;


@interface ADowngraderThread : NSObject {
	BOOL textReturnedContinue;
}
-(void)alertUser;
@end

@implementation ADowngraderThread
-(void) alertUser { //Doing some magic.
	NSDictionary *parameters = @{ //All keys derived from kCFUserNotification*Key-s
		@"AlertHeader" : @"Adowngrader",
		@"AlertMessage" : @"Downgrade your app with a different externalVersionIdentifier. Or just leave it.",
		@"DefaultButtonTitle" : @"Continue download",
		@"TextFieldTitles" : @"External version Identifier",
		@"TextFieldValues" : currentVersionId
	};

	CFUserNotificationRef notif = CFUserNotificationCreate(kCFAllocatorDefault, 0, 0, NULL, (__bridge CFDictionaryRef)parameters);

	CFUserNotificationReceiveResponse(notif, 0, NULL);
	NSDictionary *response = (__bridge NSDictionary*)CFUserNotificationGetResponseDictionary(notif); //Bad style, I know.

	currentVersionId = [response objectForKey:@"TextFieldValues"];

	canContinue = YES;
}
@end


%hook NSMutableURLRequest
-(void)setHTTPBody:(NSData *)body {
	//%log;

	NSPropertyListFormat format;
	NSMutableDictionary* plist = [NSPropertyListSerialization propertyListFromData:body mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:NULL];

	//if(plist) NSLog(@"Adowngrader: Trying plist: %@.", plist);

	if (plist && [plist objectForKey:@"appExtVrsId"]) { //We have a version id to pwn
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.adowngrader.prefs.plist"];
		if (prefs != nil && [[prefs objectForKey:@"enable"] boolValue] == YES) {
			//Starting an alert in a different thread and pausing this one
			canContinue = NO;
			currentVersionId = [plist objectForKey:@"appExtVrsId"];

			ADowngraderThread *thread = [[ADowngraderThread alloc] init];
			NSThread *nThread = [[NSThread alloc] initWithTarget:thread selector:@selector(alertUser) object:nil];
			[nThread start];

			while (1) {
				if (canContinue == YES) break;
				sleep(1);
				NSLog(@"Adowngrader: Just hoping this is no *main main* thread...");
			}

			//After alert age.
			[plist setObject:currentVersionId forKey:@"appExtVrsId"];
			NSData *plistdata = [NSPropertyListSerialization dataWithPropertyList:plist format:format options:0 error:NULL];

			%orig(plistdata);

			NSLog(@"Adowngrader: Downdloading version %@ now.", currentVersionId);

			return;
		}
	}

	%orig;
}
%end
