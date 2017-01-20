#import <Preferences/Preferences.h>
#import <substrate.h>

%hook PSListController
- (id)loadSpecifiersFromPlistName:(id)name target:(id)arg2 {
	id ret = %orig;
	if ([name isEqualToString:@"Music"]) {
		PSSpecifier *enable = [PSSpecifier preferenceSpecifierNamed:@"Crossfade" target:self set:@selector(setCValue:specifier:) get:@selector(readCValue:) detail:nil cell:PSSwitchCell edit:nil];
		[enable setProperty:@YES forKey:@"default"];
		[enable setProperty:@"MusicCrossfadeEnabledSetting" forKey:@"key"];
		[enable setProperty:@YES forKey:@"enabled"];

		[ret insertObject:enable atIndex:0];
	}
	return ret;
}

%new
-(void) setCValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.crossfade-musicprefs-hook.plist"];
	if (prefs == nil) {
		prefs = [NSMutableDictionary dictionaryWithCapacity:1];
	}
	[prefs setObject:value forKey:[specifier propertyForKey:@"key"]];
	[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.crossfade-musicprefs-hook.plist" atomically:YES];

	CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("org.h6nry.crossfade/prefs-changed"), NULL, NULL, false);
}

%new
-(id) readCValue:(PSSpecifier *)specifier {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.crossfade-musicprefs-hook.plist"];
	if (prefs == nil) {
		prefs = [NSDictionary dictionary];
	}
	id value = [prefs objectForKey:[specifier propertyForKey:@"key"]];
	if (value == nil) {
		value = @YES;
	}

	return value;
}
%end
