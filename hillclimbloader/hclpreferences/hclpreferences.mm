/*#import <Preferences/Preferences.h>

@interface hclpreferencesListController: PSListController {
}
@end

@implementation hclpreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"hclpreferences" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
*/

#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#define ApS(a, b) [a stringByAppendingString:b]

@interface UIApplication ()
-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended;
@end

@interface hclpreferencesListController: PSListController {
}
-(NSArray*)dataFromTarget:(id)target;
-(NSArray*)titlesFromTarget:(id)target;
@end

@implementation hclpreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"hclpreferences" target:self] retain];
	}
	return _specifiers;
}

-(NSArray*)dataFromTarget:(id)target {
	
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Themes/" error:nil];
	
	NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.theme'"];
	NSArray *onlyThemes = [dirContents filteredArrayUsingPredicate:fltr];
	
	NSMutableArray *finals = [[NSMutableArray alloc] init];
	[finals addObject:@""]; //Stub for no theme at all
	
	for (NSString *name in onlyThemes) {
		NSRange needleRange = NSMakeRange(0,name.length-6);

		NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile: ApS(@"/Library/Themes/", ApS(name, @"/Info.plist")) ];
		NSLog(@"HCL: %@", prefs);
		if ([[prefs objectForKey:@"WBSoundCapability"] boolValue]) {
			[finals addObject:[name substringWithRange:needleRange]];
		}
	}
	
	NSArray* array = [[NSArray alloc] initWithArray:finals];
	
	return array;
}

-(NSArray*)titlesFromTarget:(id)target {
	NSMutableArray *fonts = [NSMutableArray arrayWithArray:[self dataFromTarget:target]];
	[fonts replaceObjectAtIndex:0 withObject:@"Default (no theming)"]; //Stub
	
	return fonts;
}

- (void)apply {
	system("killall -9 Hill\\ Climb\\ Racing");
	//[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.fingersoft.hillclimbracing" suspended:NO];
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/H6nry_/"]];
}

- (void)mail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:henry.anonym@gmail.com"]];
}
@end