#import "Tweak.h"


%hook SBHandMotionExtractor
static BOOL isTracking = NO;
BOOL openSwitcher = NO;
CGFloat touchStartx;

- (void)extractHandMotionForActiveTouches:(SBActiveTouch *)activeTouches count:(NSUInteger)count centroid:(CGPoint)centroid {
    	if (count > 1) {
    		isTracking = NO;
    		openSwitcher = NO;
    		touchStartx =  0;
    	}

    	SBActiveTouch touch = activeTouches[0];

    	CGFloat toCompareY;
    	CGFloat compareY;
    	CGFloat toCompareX;
    	CGFloat previousToCompareY;
    	CGFloat startX;
    	CGFloat totalDistance;

    	if (touch.interfaceOrientation == 1) { //Portrait
    		toCompareY = touch.location.y;
    		compareY = 460;
    		toCompareX = touch.location.x;
    		previousToCompareY = touch.previousLocation.y;
    		startX = touch.location.x;
    		totalDistance = touch.totalDistanceTraveled;
    	} else if (touch.interfaceOrientation == 3) { //Landscape ??  Swapped x and y coordinates
    		toCompareY = touch.location.x;
    		compareY = 460;
    		toCompareX = touch.location.y;
    		previousToCompareY = touch.previousLocation.x;
    		startX = touch.location.y;
    		totalDistance = touch.totalDistanceTraveled;
    	} else if (touch.interfaceOrientation == 4) { //Landscape ??  Swapped x and y coordinates, locations = max_coordinate-location
    		toCompareY = 480-touch.location.x;
    		compareY = 480-20;
    		toCompareX = 320-touch.location.y;
    		previousToCompareY = 480-touch.previousLocation.x;
    		startX = 320-touch.location.y;
    		totalDistance = touch.totalDistanceTraveled;
    	}


    	if (touch.type == 0) {
    		if (toCompareY >= compareY) {
    			//NSLog(@"--tracking");
				isTracking = YES;
				touchStartx = startX;
			}
    	} else if (isTracking) {
    		if (toCompareY > previousToCompareY || fabs(toCompareX-touchStartx) > 150 || totalDistance > 300) {
    			isTracking = NO;
				openSwitcher = NO;
				//NSLog(@"--touch failed");
    		} else if (totalDistance > 100) {
    			//NSLog(@"--open");
				openSwitcher = YES;
    		}
    	}

	%orig;
}

- (void)clear {
	if (openSwitcher) {
	    dispatch_async(dispatch_get_main_queue(), ^{
				//NSLog(@"-------switcher!");
				[[%c(SBUIController) sharedInstance] activateSwitcher];
	    });
	}
	isTracking = NO;
	openSwitcher = NO;
	touchStartx = 0;
	
    %orig;
}
%end

//static float revealAmount = -94.0f;

/*%hook SBHandMotionExtractor
static BOOL isTracking = NO;
BOOL openSwitcher = NO;

- (void)extractHandMotionForActiveTouches:(SBActiveTouch *)activeTouches count:(NSUInteger)count centroid:(CGPoint)centroid {
	SBActiveTouch touch = activeTouches[0];

	if (touch.type == 0) {
    	if (touch.location.y >= 460) {
			isTracking = YES;
			NSLog(@"--now tracking");
			[[%c(SBUIController) sharedInstance] activateSwitcher];


			UIView *view = [(SBAppSwitcherController*)[%c(SBAppSwitcherController) sharedInstance] view];
			view.hidden = NO;
			[view setAlpha:1.0f];

			CGRect frame = view.frame;
    		view.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
			NSLog(@"---view %@  %@", view, [view superview]);

			//[(SBAppSwitcherController*)[%c(SBAppSwitcherController) sharedInstance] handleMenuButtonTap];
			
		}
    } else if (isTracking) {
    	UIControl *moveView = [[(SBAppSwitcherController*)[%c(SBAppSwitcherController) sharedInstance] showcase] blockingView];

    	if (touch.location.y <= revealAmount+480) {
    		openSwitcher = YES;

    		CGRect frame = moveView.frame;
    		moveView.frame = CGRectMake(frame.origin.x, revealAmount, frame.size.width, frame.size.height);

    		NSLog(@"--okay open switcher  %f   %f", touch.location.y, revealAmount);
    	} else {
    		CGRect frame = moveView.frame;
    		moveView.frame = CGRectMake(frame.origin.x, touch.location.y, frame.size.width, frame.size.height);
    		NSLog(@"opening... %@", moveView);
    	}
    }

    %orig;
}

- (void)clear {


	isTracking = NO;
	openSwitcher = NO;
	
    %orig;
}
%end*/





/*%hook SBShowcaseController
-(void)setRevealAmount:(float)arg1 {
	%log;
	%orig;
}

-(void)didAppear {
	%log;
	%orig;
	NSLog(@"window: %@", self.blockingView); //richtiges view...
}

-(void)willAppear {
	%log;
	%orig;
	NSLog(@"window: %f", self.blockingView.frame.origin.y);
	//moveView = self.blockingView;
}

-(void)setAnimating:(char)arg1 {
	%log;
	%orig;
}

-(void)setRevealMode:(int)arg1 {
	%log;
	%orig;
}
%end*/

/*%hook SBShowcaseViewController
-(float)revealAmountForMode:(int)arg1 {
	%log;
	return %orig;
}
%end*/






