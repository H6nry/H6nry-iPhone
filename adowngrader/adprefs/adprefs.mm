#import <Preferences/Preferences.h>

@interface adprefsListController: PSListController {
}
@end

@implementation adprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"adprefs" target:self] retain];

		/*PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:@"Enable" target:self set:@selector(setEnabledState:specifier:) get:@selector(getEnabledState:) detail:nil cell:PSSwitchCell edit:nil];

		[specifier setProperty:@NO forKey:@"default"];
		[specifier setProperty:@"enabled" forKey:@"key"];
		
		[self addSpecifier:specifier animated:YES]; //Add the cell. This automatically groups the cell into the specified in the plist.*/
	}
	return _specifiers;
}
@end

// vim:ft=objc
