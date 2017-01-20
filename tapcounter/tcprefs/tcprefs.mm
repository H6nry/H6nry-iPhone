#import <Preferences/Preferences.h>

@interface tcprefsListController: PSListController {
	BOOL _addedSpecifiers;
}
@end

@implementation tcprefsListController
- (id)specifiers {
	[super specifiers];
	NSLog(@"---- %@", _specifiers);
	if(_addedSpecifiers == NO) {
		NSNumber *name = [[NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.tapcounter.more.plist"] objectForKey:@"count"];
		PSSpecifier* specifier = [[PSSpecifier preferenceSpecifierNamed:[name stringValue] target:self set:@selector(set:specifier:) get:@selector(get) detail:nil cell:PSGroupCell edit:nil] retain];
		[self addSpecifier:specifier animated:NO];

		_addedSpecifiers = YES;
	}

	return _specifiers;
}

-(NSArray*)loadSpecifiersFromPlistName:(NSString*)plistName target:(id)target {
	NSArray *sp = [super loadSpecifiersFromPlistName:@"tcprefs" target:target];
	return sp;
}

-(void) set:(id)set specifier:(PSSpecifier *)specifier {
	return;
}

-(id) get {
	return nil;
}
@end

// vim:ft=objc
