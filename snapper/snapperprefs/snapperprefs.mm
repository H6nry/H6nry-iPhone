#import <Preferences/Preferences.h>

@interface snapperprefsListController: PSListController {
}
@end

@implementation snapperprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"snapperprefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
