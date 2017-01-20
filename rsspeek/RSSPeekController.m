#import "BBWeeAppController-Protocol.h"
#import "MWFeedParser/MWFeedParser.h"
#import "MWFeedParser/NSString+HTML.h"


@interface FeedViewController : UIViewController <UIGestureRecognizerDelegate> {
	CGRect _frame;
}
@property NSString *feedTitle;
@property NSString *feedUrl;
@property NSString *feedName;
@property NSString *feedDate;

-(id) initWithFrame:(CGRect)frame;
@end


static NSBundle *_RSSPeekWeeAppBundle = nil;

@interface RSSPeekController: NSObject <BBWeeAppController, MWFeedParserDelegate, UIScrollViewDelegate> {
	UIImageView *_backgroundView;
	UIImageView *_placeholderViewSecondLoad;
	UIScrollView *_scrollView;

	NSMutableArray<NSMutableDictionary*> *_feeds; // One of these two...
	NSMutableArray<NSMutableDictionary*> *parsedItems; // ...is too much. There must be a better way to do it...

	UIInterfaceOrientation _lastOrientation;
	int _displayedItemCount;

	NSUInteger _feedCount;
	NSUInteger _startedFeedsCount;
	NSUInteger _finishedFeedsCount;

	NSUInteger _itemNumberToDisplay;
}
@property (nonatomic, retain) UIView *view;
@end

@implementation RSSPeekController

+ (void)initialize {
	_RSSPeekWeeAppBundle = [NSBundle bundleForClass:[self class]];
}

- (void)loadFullView {
	//Load the user's feeds
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.rsspeekprefs.plist"];

	NSArray<NSString*> *feedURLStrings = @[@"https://www.apple.com/pr/feeds/pr.rss"];
	if (prefs && [prefs objectForKey:@"feedUrls"] && [(NSArray*)[prefs objectForKey:@"feedUrls"] count] > 0) feedURLStrings = [prefs objectForKey:@"feedUrls"];

	_itemNumberToDisplay = [[prefs objectForKey:@"displayItemCount"] integerValue];
	if (_itemNumberToDisplay == 0) _itemNumberToDisplay = 20;

	//Some setup stuff
	if (_feeds == nil) _feeds = [NSMutableArray array];
	[_feeds removeAllObjects];
	_scrollView = nil;

	_feedCount = [feedURLStrings count];
	_startedFeedsCount = 0;
	_finishedFeedsCount = 0;

	//Create and parse the feeds
	for (NSString *feedString in feedURLStrings) {

		NSString *cleanFeedString = [feedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (!([cleanFeedString rangeOfString:@"http://"].location == 0) || !([cleanFeedString rangeOfString:@"https://"].location != 0)) {
			cleanFeedString = [@"https://" stringByAppendingString:cleanFeedString];
		}
		if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_7_0) { //iOS <= 6, deprecated in iOS 7+, those need to manually url-encode their feeds :/
			cleanFeedString = [cleanFeedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}

		NSURL *feedURL = [NSURL URLWithString:cleanFeedString];

		MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
		feedParser.delegate = self;
		feedParser.feedParseType = ParseTypeFull;
		feedParser.connectionType = ConnectionTypeSynchronously;
		[NSThread detachNewThreadSelector:@selector(parse) toTarget:feedParser withObject:nil]; //Haxx? .~.

		NSMutableDictionary *feed = [NSMutableDictionary dictionary]; //We have parser, info, items here.
		[feed setObject:feedParser forKey:@"parser"];
		[_feeds addObject:feed];
	}
}

- (void)loadPlaceholderView {
	//Init the very basics here, and a placeholder
	_view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {316.f, [self viewHeight]}}];
	_view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UIImage *bgImg = [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"];
	UIImage *stretchableBgImg = [bgImg stretchableImageWithLeftCapWidth:floorf(bgImg.size.width / 2.f) topCapHeight:floorf(bgImg.size.height / 2.f)];
	_backgroundView = [[UIImageView alloc] initWithImage:stretchableBgImg];
	_backgroundView.frame = CGRectInset(_view.bounds, 2.f, 0.f);
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_view addSubview:_backgroundView];

	if (_placeholderViewSecondLoad != nil) {
		_backgroundView.hidden = YES;
		[_view addSubview:_placeholderViewSecondLoad];
	}
}

- (void)unloadView {
	//Do some placholder magic for the next time
	if (_view != nil && _placeholderViewSecondLoad == nil) { //_placeholderViewSecondLoad != nil is kind of hacky...
		UIGraphicsBeginImageContextWithOptions(_view.bounds.size, NO, 0.0f);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[_view.layer renderInContext:context];
		UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		_placeholderViewSecondLoad = [[UIImageView alloc] initWithImage:snapshotImage];
		_placeholderViewSecondLoad.alpha = 0.5;
	}

	//No waste of reources. TODO add _parsedItems here after merged _feeds out of code.
	_view = nil;
	_scrollView = nil;
}

- (float)viewHeight {
	return 71.f; // == viewHeight of Stocks and Weather widgets...
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//Update the content size manually. You never know.
	if (_scrollView && _view) {
		_scrollView.contentSize = CGSizeMake((_view.frame.size.width-4) * _displayedItemCount, [self viewHeight]);
	}

	//Sorry, no preview :/
	if (_placeholderViewSecondLoad && interfaceOrientation != _lastOrientation) {
		[_placeholderViewSecondLoad removeFromSuperview];
		_placeholderViewSecondLoad = nil;
		_backgroundView.hidden = NO;
	}
	_lastOrientation = interfaceOrientation;
}


// MWFeedParserDelegate. I should use #pragma marks here
- (void)feedParserDidStart:(MWFeedParser *)parser {
	@synchronized(self) { _startedFeedsCount++; }
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	@synchronized(self) {
		if (info) {
			[_feeds indexOfObjectPassingTest:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
				if ([[obj objectForKey:@"parser"] isEqual:parser]) {
					[obj setObject:info forKey:@"info"];

					return YES;
				}

				return NO;
			}];
		}
	}
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	@synchronized(self) {
		if (item) {
			[_feeds indexOfObjectPassingTest:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
				if ([[obj objectForKey:@"parser"] isEqual:parser]) {
					NSMutableArray *array = [obj objectForKey:@"items"];
					if (!array) array = [NSMutableArray array];

					[array addObject:item];
					[obj setObject:array forKey:@"items"];

					return YES;
				}

				return NO;
			}];
		}
	}
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	@synchronized(self) {
		_finishedFeedsCount++;
		if (_feedCount == _finishedFeedsCount) [self loadFeedTable];
	}
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	@synchronized(self) {
		_finishedFeedsCount++;
		if (_feedCount == _finishedFeedsCount) [self loadFeedTable];
	}
}


// RSSPeekController
-(void) loadFeedTable {
	//Make sure we are on the main thread again.
	[self performSelectorOnMainThread:@selector(_loadFeedTable) withObject:nil waitUntilDone:NO];
}

-(void) _loadFeedTable { //Get feeds, sort them, init and show scrollView & FeedViews.
	//Some control mechanisms
	if (_scrollView != nil) {
		[_scrollView removeFromSuperview];
		_scrollView = nil;
	}
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 0, _view.frame.size.width-4, [self viewHeight])];

	if (_feeds == nil || [_feeds count] <= 0) {
		NSLog(@"RSSPeek: ERROR: NO PARSED FEEDS: HANDLE ME PLS!");
	}

	_view.alpha = 1.0;

	//Some placeholder magic: undone
	[_placeholderViewSecondLoad removeFromSuperview];
	_placeholderViewSecondLoad = nil;
	_backgroundView.hidden = NO;

	//Sort the feeds
	if (parsedItems == nil) parsedItems = [NSMutableArray array];
	[parsedItems removeAllObjects];

	for (NSMutableDictionary *obj in _feeds) {
		NSArray *items = [obj objectForKey:@"items"];
		NSString *info = [obj objectForKey:@"info"];

		for (MWFeedItem *item in items) {
			NSMutableDictionary *finalItem = [NSMutableDictionary dictionary]; //We have item, info, viewController
			[finalItem setObject:item forKey:@"item"];
			[finalItem setObject:info forKey:@"info"];

			[parsedItems addObject:finalItem];
		}
	};

	[parsedItems sortUsingComparator: ^(NSMutableDictionary *obj1, NSMutableDictionary *obj2) {
		NSDate *date1 = [(MWFeedItem*)[obj1 objectForKey:@"item"] date];
		NSDate *date2 = [(MWFeedItem*)[obj2 objectForKey:@"item"] date];

		if (date2 == nil && date1 == nil) return (NSComparisonResult)NSOrderedSame;
		if (date2 == nil) return (NSComparisonResult)NSOrderedAscending;
		if (date1 == nil) return (NSComparisonResult)NSOrderedDescending;

		return [date2 compare:date1];
	}];

	if ([parsedItems count] > _itemNumberToDisplay) {
		NSRange tooMuch = {.location = _itemNumberToDisplay, .length = ([parsedItems count]<_itemNumberToDisplay ? 0 : [parsedItems count]-_itemNumberToDisplay)};
		[parsedItems removeObjectsInRange:tooMuch];
	}

	//Add the feeds as views
	_displayedItemCount = 0;

	for (NSMutableDictionary *feedDict in parsedItems) {
		MWFeedItem *feedItem = [feedDict objectForKey:@"item"];

		FeedViewController *controller = [[FeedViewController alloc] initWithFrame:CGRectMake(_displayedItemCount*(_view.frame.size.width-4), 0, _view.frame.size.width-4, [self viewHeight])];

		NSString *url = feedItem.link ? feedItem.link : @"http://amiconnectedtotheinternet.com/";
		controller.feedUrl = url;

		NSString *title = feedItem.title ? feedItem.title : @"";
		NSString *description = feedItem.summary ? feedItem.summary : url;
		description = [description stringByConvertingHTMLToPlainText];
		controller.feedTitle = [[title stringByAppendingString:@": "] stringByAppendingString:description];

		NSString *name = [(MWFeedInfo*)[feedDict objectForKey:@"info"] title] ? [(MWFeedInfo*)[feedDict objectForKey:@"info"] title] : @""; //TODO
		controller.feedName = name;

		NSString *date;
		if (feedItem.date) {
			date = [NSDateFormatter localizedStringFromDate:feedItem.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
		} else {
			date = @"";
		}
		controller.feedDate = date;

		[_scrollView addSubview:controller.view];

		[feedDict setObject:controller forKey:@"viewController"];

		_displayedItemCount++;
	}

	//Handle special case: We have nothing to show
	if ([parsedItems count] == 0) {
		UILabel *offlineView = [[UILabel alloc] initWithFrame:CGRectMake(_displayedItemCount*(_view.frame.size.width-4), 0, _view.frame.size.width-4, [self viewHeight])];
		offlineView.text = @"RSSPeek offline";
		offlineView.textColor = [UIColor whiteColor];
		offlineView.backgroundColor = [UIColor clearColor];
		offlineView.font = [UIFont boldSystemFontOfSize:18];
		offlineView.shadowColor = [UIColor blackColor];
		offlineView.shadowOffset = CGSizeMake(0, 1);
		offlineView.numberOfLines = 1;
		if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) { //iOS 5
		    PLS_NO_DEPRECATED(
				offlineView.textAlignment = UITextAlignmentCenter;
			);
		} else { //iOS 6+
			offlineView.textAlignment = NSTextAlignmentCenter;
		}

		[_scrollView addSubview:offlineView];
	}

	//Twerk - uhm, I mean tweak - the scroll view
	_scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	_scrollView.pagingEnabled = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.alwaysBounceHorizontal = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.contentSize = CGSizeMake((_view.frame.size.width-4) * _displayedItemCount, [self viewHeight]);
	_scrollView.delegate = self;
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_view addSubview:_scrollView];
}

@end


@implementation FeedViewController
-(id) initWithFrame:(CGRect)frame { //No good. Bad style. Should work.
	self = [super init];
	_frame = frame;

	return self;
}

-(void) loadView {
	//Craft a nice view for our feed content
	self.view = [[UIView alloc] initWithFrame:_frame];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGR.delegate = self;
	[self.view addGestureRecognizer:tapGR];

	UILabel *_titleView = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, self.view.bounds.size.width-6, self.view.bounds.size.height-6-20)]; //Placed at the top
	_titleView.text = self.feedTitle;
	_titleView.textColor = [UIColor whiteColor];
	_titleView.backgroundColor = [UIColor clearColor];
	_titleView.font = [UIFont systemFontOfSize:15];
	_titleView.numberOfLines = 0;
	[_titleView sizeToFit];
	CGRect frame = _titleView.frame;
	if (frame.size.height > self.view.bounds.size.height-6-20) frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.view.bounds.size.height-6-20); //Resize because too large in height
	_titleView.frame = frame;
	_titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_titleView];

	UILabel *feedNameView = [[UILabel alloc] initWithFrame:CGRectMake(3, self.view.bounds.size.height-6-20, (self.view.bounds.size.width-6)/2, 20)]; //Placed at the bottom, left
	feedNameView.text = self.feedName;
	feedNameView.textColor = [UIColor lightGrayColor];
	feedNameView.backgroundColor = [UIColor clearColor];
	feedNameView.font = [UIFont systemFontOfSize:12];
	feedNameView.numberOfLines = 1;
	feedNameView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:feedNameView];

	UILabel *dateView = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-6)/2, self.view.bounds.size.height-6-20, (self.view.bounds.size.width-6)/2, 20)]; //Placed at the bottom, right
	dateView.text = self.feedDate;
	dateView.textColor = [UIColor lightGrayColor];
	dateView.backgroundColor = [UIColor clearColor];
	dateView.font = [UIFont systemFontOfSize:12];
	dateView.numberOfLines = 1;
	if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) { //iOS 5
	    PLS_NO_DEPRECATED(
			dateView.textAlignment = UITextAlignmentRight;
		);
	} else { //iOS 6+
		dateView.textAlignment = NSTextAlignmentRight;
	}
	dateView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:dateView];
}

-(void) handleTap:(UITapGestureRecognizer *)recognizer {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.feedUrl]];
}
@end
