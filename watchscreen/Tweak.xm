#import "Tweak.h"

%group watchscreenFrontend //WSFrontend grouped. watchscreen frontend group. This should not differ between iOS versions. Strict rule: Is not allowed to call a backend method! {
%subclass WSIconView : SBIconView //WSGFrontend grouped.
-(BOOL)_delegateTapAllowed { //called when user taps and leaves icon, no move, unlimited time.
	return %orig;
}
-(void)_delegateTouchEnded:(BOOL)ended {
	%log;
	%orig;
}
-(id)iconImageView {
	SBIconImageView *view = %orig;
	view.image = [view.image circularCropImage];

	return view;
}

-(void)updateIconOverlayView {
	%orig;

	UIImageView *overlayView = MSHookIvar<UIImageView *>(self, "_iconDarkeningOverlay");
	overlayView.image = [overlayView.image circularCropImage]; //Make dark selection overlay round as well
}
%end

@implementation UIImage (circularCropCategory)
-(UIImage*) circularCropImage {
	UIImage *image = self;
	if (!image) return nil;

	CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;

    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageHeight), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    //Create and clip circular path
    CGFloat radius = imageWidth/2;
	CGFloat movey;

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) { //iOS 7 and above
		radius = radius-3;
		movey = 0;
	} else { //iOS 6 and downwards
		radius = radius-3;
		movey = 1;
	}

    CGContextBeginPath (context);
    CGContextAddArc (context, imageWidth/2, imageHeight/2-movey, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);

    //Paint to UIImage
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}
@end


NSIndexPath* ws_getIndexPathOfObject(id object) { //WSGBackend grouped.
	return objc_getAssociatedObject(object, "indexPath");
}

void ws_setIndexPathOfObject(id object, NSIndexPath *path) { //WSGBackend grouped
	objc_setAssociatedObject(object, "indexPath", path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@implementation WSView //WSGFrontend grouped.   really should get its own controller!!!
- (void)layoutSubviews {
	[super layoutSubviews];
	//NSLog(@"watchscreen: [WSView layoutSubviews] called.");
}

- (void)addSubview:(UIView *)view {
	//NSLog(@"watchscreen: [WSView addSubview:view] called. view: %@", view);
	[super addSubview:view];
}
@end


@implementation WSScrollView { //WSGFrontend grouped.
	WSView *_contentView;
}
- (void)setContentView:(WSView *)view {
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self addSubview:view];
	_contentView = view;
}

- (WSView *)contentView {
	return _contentView;
}
@end


static WSViewController *_sharedInstancec = nil;

@implementation WSViewController { //WSGBackend grouped.
	NSMutableDictionary *_relativePositionsForIndexPaths;
	NSMutableDictionary *_scrollViewSizeForIconCount;
}
//TODO: setposition method
+ (id)sharedInstance { //Don't call this directly! Let everything inherit from WSManager...
	@synchronized(self) {
		if (!_sharedInstancec) {
			_sharedInstancec = [[self alloc] init];
		}
		return _sharedInstancec;
	}
}

- (id)init {
	if (self = [super init]) {
		self.homeScreenIcons = 0;
		_relativePositionsForIndexPaths = [[NSMutableDictionary alloc] init];
		_scrollViewSizeForIconCount = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	WSScrollView *scrollView = (WSScrollView *)self.view;

	const float xCenter = scrollView.frame.size.width/2;
	const float yCenter = scrollView.frame.size.height/2;
	const CGFloat zoomScale = scrollView.zoomScale;
	const CGPoint offset = scrollView.contentOffset;

	float zoomFactor = (10*pow(zoomScale-1.2, 2)-2);
	if (zoomFactor > 1) zoomFactor = 1;
	if (zoomFactor < 0) zoomFactor = 0;

	for (SBIconView *iconView in [scrollView.contentView subviews]) {
		float transform; //Defined on the interval [0; 1]

		if (zoomFactor == 1) {
			transform = 1;
		} else {
			float cx = iconView.center.x * zoomScale - offset.x;
			float cy = iconView.center.y * zoomScale - offset.y;

			float diff = sqrt(pow(xCenter-cx,2) + pow(yCenter-cy,2)); //Distance between icon center and screen center

			//Calculate the transform as a stepped function, 1 big function is too imperformant
			if (diff <= 128) {
				transform = 1 - pow(diff*0.003, 2);
			} else if (diff <= 162) {
				transform = 1 - pow((diff-80)*0.008, 2);
			} else if (diff <= 205) {
				transform = 0.8f - pow(diff*0.003, 2);
			} else if (diff <= 221 ){
				transform = 1 - pow((diff-110)*0.008, 2);
			} else {
				transform = 0.4f - pow(diff*0.002, 2);
			}

			if (transform < 0) transform = 0; //Correct some mistake calculations

			transform = transform + ((1-transform) * zoomFactor); //Apply the zoom factor, when heavily zoomed out/in, do not transform
		}

		iconView.transform = CGAffineTransformMakeScale(transform, transform);

		//Hide icon label, depending on size
		if ((zoomScale * transform) <= 0.5) {
			[iconView setIconLabelAlpha:0.0];
		} else {
			[iconView setIconLabelAlpha:1.0];
		}
	}
}

- (void)loadView {
	WSView *wsView = [[WSView alloc] initWithFrame:CGRectZero];
	wsView.backgroundColor = [UIColor clearColor];

	WSScrollView *scrollView = [[WSScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	scrollView.scrollsToTop = NO;
	scrollView.alwaysBounceVertical = YES;
	scrollView.alwaysBounceHorizontal = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.contentView = wsView;
	scrollView.delegate = self;
	scrollView.minimumZoomScale = 0.5;
	scrollView.maximumZoomScale = 1.5;

	self.view=scrollView;
}

- (void)addIcon:(SBIcon *)icon {
	if (self.view) {
		if ([ws_getIndexPathOfObject(icon) length] == 1) {
			WSIconView *iconView = [[%c(WSIconView) alloc] initWithDefaultSize];
			[iconView setIcon:icon];
			iconView.delegate = self;
			iconView.exclusiveTouch = NO; //Stop icons from catching all the touches

			iconView.transform = CGAffineTransformMakeScale(1, 1); //Scaling the icon to standard size...

			//Add the iconView to the homescreen
			WSScrollView *scrollView = (WSScrollView *)self.view;
			[scrollView.contentView addSubview:iconView];

			//Increment the counter
			self.homeScreenIcons = self.homeScreenIcons+1;

			//Realign every icon to the new icon index count, cause too lazy
			for (SBIconView *siconView in [scrollView.contentView subviews]) {
				siconView.center = [self iconPositionWithIndexPath:ws_getIndexPathOfObject(siconView.icon)];
			}

			//Resize the contentSize and contentView's size appropriately. Wondering this works.
			CGRect frame = scrollView.contentView.frame;
			unsigned long int scrollViewSize = [self contentSize];
			scrollView.contentView.frame = CGRectMake(frame.origin.x, frame.origin.y, scrollViewSize, scrollViewSize);
			scrollView.contentSize = CGSizeMake(scrollViewSize, scrollViewSize);
		} else {
			NSLog(@"watchscreen: [WSViewController addIcon:icon] path length not supported yet!");
		}
	}
}

- (void)removeIcon:(SBIcon *)icon { //TODO: Find the bug?
	if (![icon isKindOfClass:[%c(SBIcon) class]]) NSLog(@"watchscreen: [WSViewController removeIcon:icon] icon not SBIcon!");
	WSScrollView *scrollView = (WSScrollView *)self.view;

	NSUInteger index = [[scrollView.contentView subviews] indexOfObjectPassingTest:^BOOL(id object, NSUInteger index, BOOL *stop) { //Not beautiful. Ask WSManager.
		if ([[(SBIconView *)object icon] isEqual:icon]) {
			return *stop = YES;
		}
		return NO;
	}];

	if(index == NSNotFound) {
		NSLog(@"watchscreen: [WSViewController removeIcon:icon] icon for some reason not found?");
	} else {
		[[[scrollView.contentView subviews] objectAtIndex:index] removeFromSuperview];

		//Decrement the counter
		self.homeScreenIcons = self.homeScreenIcons-1;

		//Realign every icon to the new icon index count, cause too lazy
		for (SBIconView *siconView in [scrollView.contentView subviews]) {
			siconView.center = [self iconPositionWithIndexPath:ws_getIndexPathOfObject(siconView.icon)];
		}

		//Resize the contentSize and contentView's size appropriately. Wondering this works.
		CGRect frame = scrollView.contentView.frame;
		unsigned long int scrollViewSize = [self contentSize];
		scrollView.contentView.frame = CGRectMake(frame.origin.x, frame.origin.y, scrollViewSize, scrollViewSize);
		scrollView.contentSize = CGSizeMake(scrollViewSize, scrollViewSize);

		DLog(@"watchscreen: [WSViewController removeIcon:icon] removed icon successfully!");
	}
}

- (CGPoint)iconPositionWithIndexPath:(NSIndexPath *)path {
	const unsigned long int scrollViewSize = [(WSScrollView *)self.view contentSize].width;
	const float xCenter = scrollViewSize / 2; //Center
	const float yCenter = scrollViewSize / 2; //Center


	id dictionaryValue;
	CGPoint position;

	//Trying to be lazy, maybe we find the calculated size somewhere...
	if ([_relativePositionsForIndexPaths count] > 0) {
		dictionaryValue = [_relativePositionsForIndexPaths objectForKey:path];
		position = [dictionaryValue CGPointValue];
		if (dictionaryValue) {
			position = CGPointMake(position.x + xCenter, position.y + yCenter); //Make point centered
			return position;
		}
	}

	CGPoint point;


	if ([path length] != 1) {
		NSLog(@"watchscreen: [WSViewController iconPositionWithIndexPath:path] path length not supported yet!");
		return CGPointMake(0, 0);
	}
	NSUInteger index = [path indexAtPosition:0];
	if (index == NSNotFound) {
		NSLog(@"watchscreen: [WSViewController iconPositionWithIndexPath:path] index wrong, NSNotFound!");
		return CGPointMake(0, 0);
	}

	int cc = 90;
	//if ([[WSPreferences sharedInstance] iconlabels]) cc = 75;


	int cnr;

	if (index <= 0) {
		point = CGPointMake(xCenter, yCenter);
		[_relativePositionsForIndexPaths setObject:[NSValue valueWithCGPoint:point] forKey:path];
		return point;
	} else {
		cnr = floor(sqrt((1.0f/3.0f)*index-(1.0f/12.0f))+0.5f); //Number of the current circle
	}

	int i = 3*(int)pow(cnr+1, 2)-3*(cnr+1); //All elements icluding those on this circle
	float r = cc * cnr; //Radius
	int lidx = i-index; //Number of the index on this circle

	int lowcorner = int(lidx/cnr) * cnr; //The next lower corner of the hexagon, while: cnr = aec / 6
	int upcorner = int(lidx/cnr + 1) * cnr; //The next upper corner of the hexagon, while: cnr = aec / 6
	float distfromlow = ((float)(lidx-lowcorner))/cnr; //The "distance" from the next lower corner, while: cnr = aec / 6

	CGPoint lowcoord; //Coordinates of lowcorner

	switch (lowcorner/cnr) {
		case 0:
			lowcoord = CGPointMake(r, 0);
			break;
		case 1:
			lowcoord = CGPointMake(r/2, sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		case 2:
			lowcoord = CGPointMake(-r/2, sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		case 3:
			lowcoord = CGPointMake(-r, 0);
			break;
		case 4:
			lowcoord = CGPointMake(-r/2, -sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		case 5:
			lowcoord = CGPointMake(r/2, -sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		default :
			DLog(@"watchscreen: Whoops, something went wrong, could not calculate coordinates of lowcorner no. %i.", lowcorner/cnr);
			lowcoord = CGPointZero;
			break;
	}

	CGPoint upcoord; //Coordinates of upcorner

	switch (upcorner/cnr) {
		case 6:
			upcoord = CGPointMake(r, 0);
			break;
		case 1:
			upcoord = CGPointMake(r/2, sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		case 2:
			upcoord = CGPointMake(-r/2, sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		case 3:
			upcoord = CGPointMake(-r, 0);
			break;
		case 4:
			upcoord = CGPointMake(-r/2, -sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		case 5:
			upcoord = CGPointMake(r/2, -sqrt(pow(r, 2) - pow(r/2, 2)));
			break;
		default :
			DLog(@"watchscreen: Whoops, something went wrong, could not calculate coordinates of upcorner no. %i.", upcorner/cnr);
			upcoord = CGPointZero;
			break;
	}

	if (lowcorner == lidx) { //We are on a corner
		point = lowcoord;
	} else { //We are on the side
		point = CGPointMake(lowcoord.x+(upcoord.x-lowcoord.x)*distfromlow, lowcoord.y+(upcoord.y-lowcoord.y)*distfromlow); //Linear combination of vectors
	}


	[_relativePositionsForIndexPaths setObject:[NSValue valueWithCGPoint:point] forKey:path]; //Remember calculation because lazy ass

	point = CGPointMake(point.x + xCenter, point.y + yCenter); //Make the point centered

	return point;
}

- (unsigned long int)contentSize {
	id dictionaryValue;
	int size;
	int index = self.homeScreenIcons;

	//Trying to be lazy, maybe we find the calculated size somewhere...
	if ([_scrollViewSizeForIconCount count] > 0) {
		dictionaryValue = [_scrollViewSizeForIconCount objectForKey:[NSNumber numberWithInt:index]];
		size = [dictionaryValue intValue];
		if (dictionaryValue) {
			return size;
		}
	}

	int cnr = floor(sqrt((1.0f/3.0f)*index-(1.0f/12.0f))+0.5f); //Number of the current circle

	unsigned long int scrollViewSize = 80*(cnr+1)*2+([[UIScreen mainScreen] bounds].size.height/2); //TODO: rewrite without mainscreen.bounds
	[_scrollViewSizeForIconCount setObject:[NSNumber numberWithInt:scrollViewSize] forKey:[NSNumber numberWithInt:index]];

	return scrollViewSize;
}

//WSIconView delegate. WARNING: THESE ARE ICON-VIEWS!
-(void)iconTapped:(SBIconView *)tapped { //called when touch is done, in every case..?
	WSScrollView *scrollView = (WSScrollView *)self.view;
	CGFloat zs = [scrollView zoomScale];
	CGFloat transformScale = tapped.transform.a * zs;

	if (transformScale > 0.5) {
		if ([tapped isShowingCloseBox]) { //When icon in editing mode...
			DLog();
			//Maybe implement here swapping this with another icon already in edit mode?
		} else {
			[[(SBIconView *)tapped icon] launch]; //Uh, oh, this belongs into the backend...?
		}
	} else { //Too small
		 //I somehow managed to make the zooming super smooth with this. Nice to look at.
		CGRect frame = scrollView.frame;

		CGFloat bzs = zs;
		if (zs < 1.0) {
			zs = 1;
		}
		frame = CGRectMake(tapped.center.x-(frame.size.width/zs)/2, tapped.center.y-(frame.size.height/zs)/2, frame.size.width/zs, frame.size.height/zs);
		zs = bzs;

		[UIView animateWithDuration:0.25 animations:^{
			[scrollView zoomToRect:frame animated:NO];
			[scrollView setNeedsLayout];
			[scrollView layoutIfNeeded];
		}];
	}
}

-(BOOL)iconAllowJitter:(SBIconView *)jitter {
	return YES;
}

-(BOOL)iconShouldAllowTap:(SBIconView *)icon { //If iconTapped should be called
	BOOL shouldAllow = NO;

	if ([objc_getAssociatedObject(icon, "shouldAllowTap") isEqual:@YES]) shouldAllow = YES;
	return shouldAllow;
}

-(void)iconTouchBegan:(SBIconView *)began { //Called when icon touch began
	[began setHighlighted:YES delayUnhighlight:YES];
	objc_setAssociatedObject(began, "shouldAllowTap", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)iconHandleLongPress:(SBIconView *)press { //When icon pressed long
	[press setShowsCloseBox:(![press isShowingCloseBox]) animated:YES]; //If showing close already, hide, if not, show
	objc_setAssociatedObject(press, "shouldAllowTap", @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)iconCloseBoxTapped:(SBIconView *)tapped { //When user tries to delete app
	[self.manager removeIcon:(SBIcon *)[tapped icon]]; //We could do a manager.delegate for this one...
	[self.manager uninstallIcon:(SBIcon *)[tapped icon]];
}

//WSScrollView delegate.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [(WSScrollView *)self.view contentView];
}
@end





static WSManager *_sharedInstance = nil;

@implementation WSManager { //WSGBackend grouped. This is the first (and only?) source to retrieve data releated with watchscreen. Kind of model object in MVC design.
	NSMutableArray *iconList;
	NSMutableDictionary *_indexPathForNodeIdentifier; //TODO: wirklich node identifier???
}

+ (id)sharedInstance {
	@synchronized(self) {
		if (!_sharedInstance) {
			_sharedInstance = [[self alloc] init];
		}
		return _sharedInstance;
	}
}

- (id)init {
	if (self = [super init]) {
		iconList = [[NSMutableArray alloc] init];
		_indexPathForNodeIdentifier = [[NSMutableDictionary alloc] init];
		self.viewController = [WSViewController sharedInstance];
		self.viewController.manager = self;
	}
	return self;
}

- (void)addIcon:(SBIcon *)icon {
	if (!icon) {
		NSLog(@"watchscreen: [WSManager addIcon:icon] icon is empty!");
		return;
	}

	NSIndexPath *pathForNodeIdentifier;

	if ([_indexPathForNodeIdentifier count] > 0) {
		pathForNodeIdentifier = [_indexPathForNodeIdentifier objectForKey:[icon nodeIdentifier]];
	} else {
		pathForNodeIdentifier = nil;
	}

	if (!pathForNodeIdentifier) {
		[_indexPathForNodeIdentifier setObject:[NSIndexPath indexPathWithIndex:[iconList count]] forKey:[icon nodeIdentifier]];
		ws_setIndexPathOfObject(icon, [NSIndexPath indexPathWithIndex:[iconList count]]);
	} else {
		ws_setIndexPathOfObject(icon, pathForNodeIdentifier);
	}

	if (![icon isUninstalled] && ![icon isPlaceholder] && ![icon isGrabbedIconPlaceholder] && ![icon isEmptyPlaceholder]) {
		[iconList addObject:icon];

		[[WSViewController sharedInstance] addIcon:icon];
	}
}

- (void)removeIcon:(SBIcon *)icon {
	//Never ever uninstall apps here! This will wipe all data! I learned the hard way.
	[[WSViewController sharedInstance] removeIcon:icon];
	[iconList removeObject:icon];
}

- (void) uninstallIcon:(SBIcon *)icon {
	DLog(@"----whoops, someone wants to remove an app: %@", icon);
	//[icon setUninstalled]; //Dangerous, will wipe app.
}

- (void)moveIcon:(SBIcon *)icon toIndexPath:(NSIndexPath *)path animated:(BOOL)animated {
	NSUInteger equalPaths = [iconList indexOfObjectPassingTest:^BOOL(id object, NSUInteger index, BOOL *stop) {
		if ([ws_getIndexPathOfObject(icon) isEqual:path]) {
			NSLog(@"watchscreen: [WSManager moveIcon:icon toIndexPath:path animated:animated] found an equal index to the one moving to!");
			return *stop = YES;
		}
		return NO;
	}];

	if (equalPaths != NSNotFound) { //If there is already an icon at the desired index. TODO: Maybe test here if the icon is an empty placeholder??
		ws_setIndexPathOfObject([iconList objectAtIndex:equalPaths], ws_getIndexPathOfObject(icon)); //Swap
		ws_setIndexPathOfObject(icon, path);
	} else { //If there is definitely no equal index path
		ws_setIndexPathOfObject(icon, path); //Just set it
	}
	//TODO: später: [WSViewController setposition:pos] oder so
}
@end

%end //end of group watchscreenFrontend. }



%group watchscreenBackend6 //WSBackend6 grouped. watchscreen6 backend group. More version specific watchscreen helper. Strict rule: No WSGFrontend stuff here. {
%hook SBIcon
//Very hacky. Might break because why not making it harder.
-(void)addNodeObserver:(id)observer { //When an icon is added to the homescreen
	NSHashTable *observers = (NSHashTable *)MSHookIvar<NSHashTable *>(self, "_observers");

	if ([observers count] == 0) {
		[[WSManager sharedInstance] addIcon:self];
		DLog(@"---added icon %@", self);
	}

	%orig;
}

-(void)removeNodeObserver:(id)observer { //When an icon is removed from the homescreen
	%orig;

	NSHashTable *observers = (NSHashTable *)MSHookIvar<NSHashTable *>(self, "_observers");

	if ([observers count]-1 == 0) {
		[[WSManager sharedInstance] removeIcon:self];
		DLog(@"---removed icon %@", self);
	}
}
%end

%hook SBApplicationController
- (void)loadApplicationsAndIcons:(id)icons reveal:(BOOL)reveal popIn:(BOOL)anIn {
	%log;
	%orig;
}

- (void)removeApplicationsFromModelWithBundleIdentifier:(id)bundleIdentifier {
	%log;
	%orig;
}

- (BOOL)loadApplication:(id)application {
	%log;
	return %orig;
}

- (void)uninstallApplication:(id)application {
	%log;
	%orig;
}
%end

%hook SBIconController
-(id)dockContainerView { //Hides the dock and page indicators
	UIView* view = %orig;
	view.hidden = YES;

	return view;
}
-(id)contentView { //The root homescreen view
	UIView* view = %orig;

	UIView *wsView = [[[WSManager sharedInstance] viewController] view];
	[view addSubview:wsView];

	return view;
}
-(id)currentRootIconList { //The currently visible homescreen page
	SBIconListView* iview = %orig;
	[[iview subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //TODO: Maybe make this less dirty and just hide icons with view.hidden = YES;
	iview.frame = CGRectMake(0,0,0,0);

	return iview;
}
%end

%end //end of group watchscreenBackend. }


%ctor {
	%init(watchscreenBackend6);
	%init(watchscreenFrontend);
}

/*Some words:
WSFrontend: Eveything which is graphically visible and has direct impact on the UI.
WSGFrontend: The UI and its views.
WSGBackend: Everything which modifies the UI.
WSBackend: Hooks which have no visual impact on watchscreen, this mediates between the system and watchscreen.




TODO:
- Make icons movable, deletable.
- Spotlight integration?
- onhomebuttontap
-


WSManager  hier alle infos über views, subviews, icons zusammenlaufen

WSViewController  hier alle methoden zum anzeigen und verändern zusammenlaufen
	setposition
	addwsicontowsview:icon
