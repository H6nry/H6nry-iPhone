#import "rsspeekprefs.h"

/*
 Notice: The whole preferences subproject is a huge mess. I tired my best to make it break as easy as a wine glass.
 Do not learn anything from this piece of code, please! TODO: Rewrite the whole thing without any(!) PS* classes.
 Namely, implement a custom UIKit settings kit.
*/

@interface rsspeekprefsListController: PSListController {
	PSSpecifier *_addFeedButton;
}
@end

@interface PSTableCell : UITableViewCell
@end

@protocol PreferencesTableCustomView
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end

@interface FeedItemTableViewCell : PSTableCell <PreferencesTableCustomView, UITextFieldDelegate> {

}
@property UITextField *addressBar;
@end

NSMutableArray<FeedItemTableViewCell*> *feedTableViews;
NSMutableArray<NSString*> *feedTableURLs;


@implementation rsspeekprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		//General stuff
		_specifiers = [NSMutableArray array];

		NSArray *staticSpecs  = [self loadSpecifiersFromPlistName:@"rsspeekprefs" target:self];

		//The Feed-URL table
		PSSpecifier *feedText = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		NSString *feedFooter = @"If you add many feeds, RSSPeek needs a good internet connection.";
		[feedText setProperty:feedFooter forKey:@"footerText"];
		[self addSpecifier:feedText];

		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist"];
		feedTableURLs = [NSMutableArray array];
		if (feedTableViews == nil) feedTableViews = [NSMutableArray array];
		[feedTableViews removeAllObjects];

		if (prefs != nil || [prefs objectForKey:@"feedUrls"] != nil) {
			for (NSString *url in [prefs objectForKey:@"feedUrls"]) {
				[feedTableURLs addObject:url];

				PSSpecifier *sp = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSListItemCell edit:nil];
				[sp setProperty:[FeedItemTableViewCell class] forKey:@"cellClass"];
				[self addSpecifier:sp];
			}
		}

		_addFeedButton = [PSSpecifier preferenceSpecifierNamed:@"(+) Add Feed" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		_addFeedButton->action = @selector(addFeedItem);
		[self addSpecifier:_addFeedButton];

		//General stuff, again.
		[self addSpecifiersFromArray:staticSpecs];
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

-(void) addFeedItem {
	NSUInteger i = [self.specifiers indexOfObject:_addFeedButton];
	if(i == NSNotFound) return;

	PSSpecifier *sp = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSListItemCell edit:nil];
	[sp setProperty:[FeedItemTableViewCell class] forKey:@"cellClass"];

	if (feedTableViews.count < 20) [self insertSpecifier:sp atIndex:i animated:YES];
}

-(void) setDisplayCount:(id)count specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist"];
	if (prefs == nil) prefs = [NSMutableDictionary dictionary];

	[prefs setObject:count forKey:@"displayItemCount"];
	[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist" atomically:YES];
}

-(id) getDisplayCount:(PSSpecifier*)specifier {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist"];
	if (prefs == nil) prefs = [NSMutableDictionary dictionary];

	id count = [prefs objectForKey:@"displayItemCount"]; //Seems like count is an NSNumber...
	if (count == nil) count = @20;

	return count;
}
@end


@implementation FeedItemTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	if (self) {
		if (feedTableViews == nil) feedTableViews = [NSMutableArray array];
		[feedTableViews addObject:self];

		self.addressBar = [[UITextField alloc] initWithFrame:CGRectMake(15, 11, self.bounds.size.width-30, self.bounds.size.height-23)];
		[self.addressBar setFont:[UIFont systemFontOfSize:17]];
		[self.addressBar setClearButtonMode:UITextFieldViewModeWhileEditing];
		[self.addressBar setBackgroundColor:[UIColor clearColor]];
		[self.addressBar setPlaceholder:@"Feed URL"];
		self.addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.addressBar.autocorrectionType = UITextAutocorrectionTypeNo;
		self.addressBar.keyboardType = UIKeyboardTypeURL;
		self.addressBar.returnKeyType = UIReturnKeyDone;
		self.addressBar.userInteractionEnabled = YES;
		self.addressBar.delegate = self;

		if (feedTableURLs && feedTableURLs.count >= feedTableViews.count) {
			NSString *text = [feedTableURLs objectAtIndex:feedTableViews.count-1];
			if (text) self.addressBar.text = text;
		}

		[self addSubview:self.addressBar];
	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 60.f;
}

//UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSMutableArray<NSString*> *urls = [NSMutableArray array];

	for (FeedItemTableViewCell *cell in feedTableViews) {
		NSString *url = cell.addressBar.text;

		if (url == nil || [url isEqualToString:@""]) continue;
		[urls addObject:url];
	}

	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist"];
	if (prefs == nil) prefs = [NSMutableDictionary dictionary];

	[prefs setObject:urls forKey:@"feedUrls"];
	[prefs writeToFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist" atomically:YES];
}
@end
