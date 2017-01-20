#import <UIKit/UIKit.h>

@interface UITouch ()
-(void)setTapCount:(unsigned)arg1;
-(void)setPhase:(int)arg1;
@end

//static unsigned long long count = 0;

%hook UITouch
-(void)setPhase:(int)arg1 {
	%orig;

	if (arg1 == UITouchPhaseBegan ) {
		CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("org.h6nry.tapcounter/tapped"), NULL, NULL, false);
		//count++;
		/*if ((int)[[NSDate date] timeIntervalSince1970] % 5 == 0) { //Flush the collected counts.
			NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.tapcounter.more.plist"];
			if (!prefs) prefs = [NSMutableDictionary dictionaryWithCapacity:1];

			NSUInteger num = [[prefs objectForKey:@"count"] integerValue];
			num = num + 1;

			[prefs setObject:[NSNumber numberWithInteger:num] forKey:@"count"];

			[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.tapcounter.more.plist" atomically:YES];

			//count = 0;

			NSLog(@"Tapcounter: Now flushing to file.");
		}*/
	}
}
%end
