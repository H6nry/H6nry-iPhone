#import <Preferences/Preferences.h>

@interface watchscreenpreferencesListController: PSListController {
}
@end

@implementation watchscreenpreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"watchscreenpreferences" target:self] retain];
	}
	return _specifiers;
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/H6nry_/"]];
}

- (void)mail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:henry.anonym@gmail.com"]];
}

- (void)apply {
  system("killall -9 SpringBoard");
}
@end

// vim:ft=objc
