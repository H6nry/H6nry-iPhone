/*
@Title 4camera iOS 6 tweak
@Short The beautiful iPhone 5 (4 inch) Camera UI on iPhone 4/4S for iOS 6
@Description	A long time ago on an internet page world far, far away, a reddit user (forgot name, but thank you!) requested why
				there was never been made a tweak which changes the iOS 6 Camera UI on iPhone 4 and 4S to the UI Apple used for
				the iPhone 5. This is, due to the different screen sizes, crafted completely different. I assume it should also
				have been the default 4/4S UI but they did not choose it because there would have not been enough screen size
				left for the camera itself. Anyways, i Google-ed around a bit and found out the fact that there is indeed a
				huge difference and that the iPhone 5's UI is much more beautiful. So i sat down a day (or two) and implemented
				the UI for the iPhone 4 (and 4S, but not tested). So here you go: 4camera and its complete source code!
				You are welcome, H6nry :)
*/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "Headers/PLCameraButton.h"
#import "Headers/PLCameraButtonBar.h"


%group 4camera


@interface UIImage (HCategory)
- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha;
@end

@implementation UIImage (HCategory)
- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);

    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}
@end

%hook PLCameraButton
- (id)initWithDefaultSize {
	//%log;
	PLCameraButton *ret = %orig;

	CGRect buttonFrame = self.frame;
	buttonFrame.size = CGSizeMake(buttonFrame.size.height*2, buttonFrame.size.height*2);
	self.frame = buttonFrame;
	
	UIImageView *iconView = MSHookIvar<UIImageView *>(self, "_iconView");
	UIView *iconSuper = [iconView superview];
	iconSuper.center = [self convertPoint:self.center fromView:self.superview];


	return ret;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
	//%log;

	//Init the Context and stuff
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(84.f, 84.f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //Draw the outer, metallic circle
	CGPoint startPoint = CGPointMake(42,0);
	CGPoint endPoint = CGPointMake(42,84);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	CGFloat colors[] = {
	    0.98, 0.98, 0.98, 1.0,
	    0.69, 0.69, 0.69, 1.0
	};

	CGFloat locations[] = {
		0.0, 1.0
	};

	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);

	CGContextSaveGState(ctx);
	CGContextAddEllipseInRect(ctx, CGRectMake(0,0,84,84));
	CGContextClip(ctx);

	CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);

	CGContextRestoreGState(ctx);
	
	//Draw the middle, dark ring
	CGContextSaveGState(ctx);

	CGFloat blackColors[] = {
		0.0, 0.0, 0.0, 1.0,
		0.0, 0.0, 0.0, 1.0
	};

	CGGradientRef darkGradient = CGGradientCreateWithColorComponents(colorSpace, blackColors, locations, 2);

	CGContextSetFillColor(ctx, blackColors);
	CGContextAddEllipseInRect(ctx, CGRectMake(3, 3, 78, 78));
	CGContextClip(ctx);

	CGContextDrawLinearGradient(ctx, darkGradient, startPoint, endPoint, 0);

	CGContextRestoreGState(ctx);


	//Draw the inner, metallic ring, which should change on touch
	CGContextSaveGState(ctx);

	
	CGFloat invertedColors[] = {
	    0.69, 0.69, 0.69, 1.0,
	    0.98, 0.98, 0.98, 1.0
	};

	CGGradientRef invertedGradient = CGGradientCreateWithColorComponents(colorSpace, invertedColors, locations, 2);

	CGContextAddEllipseInRect(ctx, CGRectMake(6, 6, 72, 72));
	CGContextClip(ctx);

	if (state == UIControlStateHighlighted) {
		CGContextDrawLinearGradient(ctx, invertedGradient, startPoint, endPoint, 0);
	} else {
		CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
	}

	CGContextRestoreGState(ctx);

	//Release some stuff
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	CGGradientRelease(darkGradient);
	CGGradientRelease(invertedGradient);

    //Draw stuff back to a UIImage
    UIImage *nImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(ctx);

	%orig(nImage, state);
}
%end


%hook PLCameraButtonBar
+ (float)buttonBarHeightForTallScreen:(BOOL)tallScreen {
	//%log;
	return 54*2;
}

+ (float)defaultHeight {
	//%log;
	return 54*2;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics {
	//%log;
	UIImage *newBackground = [[backgroundImage imageByApplyingAlpha:0.5f] resizableImageWithCapInsets:UIEdgeInsetsMake(0, backgroundImage.size.width, 0, backgroundImage.size.height)  resizingMode:UIImageResizingModeStretch];
	%orig(newBackground, topOrBottom, barMetrics);
}
%end


%end

%ctor {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.4camera-prefs.plist"];
	if ([[prefs objectForKey:@"Enabled"] boolValue]) {
		%init(4camera);
	}
}






