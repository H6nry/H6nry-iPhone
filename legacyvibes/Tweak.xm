#import "Tweak.h"

static NSMutableDictionary* pulsePatternsDict;

%hook UITouch
/*-(id) init {
	id ret = %orig;
	objc_setAssociatedObject(ret, "alreadyVibed", @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(ret, "startRadius", @0, OBJC_ASSOCIATION_RETAIN_NONATOMIC); //Must not be set to 0 after this.
	return ret;
}*/

-(void)setTapCount:(unsigned)arg1 {
	%orig;
	//%log;

	if (arg1 >= 1) {
		//UIView *view = self.view;
		//if ([view isKindOfClass:[%c(UIKeyboardLayoutStar) class]]) {
			AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, pulsePatternsDict);
		//}
		//NSLog(@"Class: %@ super %@ supersuper %@", [view class], [view superclass], [[view superclass] superclass]);
	}
}

//This is more force touch approach.
/*-(void)_setPathMajorRadius:(float)arg1 {
	%orig;
	%log;
	if ((arg1 > 0 && arg1 / [objc_getAssociatedObject(self, "startRadius") floatValue] >= 1.10f) && ([objc_getAssociatedObject(self, "alreadyVibed") isEqual:@NO] || objc_getAssociatedObject(self, "alreadyVibed") == nil)) {
		//objc_setAssociatedObject(self, "alreadyVibed", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		//objc_setAssociatedObject(self, "startRadius", @(arg1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, pulsePatternsDict);
	}

	if (arg1 > 0 && ([objc_getAssociatedObject(self, "startRadius") isEqual:@0] || objc_getAssociatedObject(self, "startRadius") == nil)) objc_setAssociatedObject(self, "startRadius", @(arg1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}*/
%end

%ctor {
	pulsePatternsDict = [@{} mutableCopy];
	NSMutableArray* pulsePatternsArray = [@[] mutableCopy];

	/*[pulsePatternsArray addObject:@(NO)];
	[pulsePatternsArray addObject:@(30)];*/

	[pulsePatternsArray addObject:@(YES)];
	[pulsePatternsArray addObject:@(30)];

	[pulsePatternsArray addObject:@(NO)];
	[pulsePatternsArray addObject:@(1)];

	[pulsePatternsDict setObject:pulsePatternsArray forKey:@"VibePattern"];
	[pulsePatternsDict setObject:[NSNumber numberWithFloat:0.001f] forKey:@"Intensity"];
}
