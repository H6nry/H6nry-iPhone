#import <CoreFoundation/CoreFoundation.h>

static unsigned long long count = 0;

static void tappedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	count++;

	if ((int)[[NSDate date] timeIntervalSince1970] % 5 == 0 && count > 8) { //Flush the collected counts.
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.tapcounter.more.plist"];
		if (!prefs) prefs = [NSMutableDictionary dictionaryWithCapacity:1];

		NSUInteger num = [[prefs objectForKey:@"count"] integerValue];
		num = num + count;

		[prefs setObject:[NSNumber numberWithInteger:num] forKey:@"count"];

		[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.tapcounter.more.plist" atomically:YES];

		count = 0;
	}
}

int main(int argc, char **argv, char **envp) {
	@autoreleasepool {
		CFStringRef notificationName = CFSTR("org.h6nry.tapcounter/tapped");
		CFNotificationCenterRef notificationCenter = CFNotificationCenterGetDarwinNotifyCenter();
		CFNotificationCenterAddObserver(notificationCenter, NULL, tappedCallback, notificationName, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

		[[NSRunLoop mainRunLoop] run];
	}

	return 0;
}
