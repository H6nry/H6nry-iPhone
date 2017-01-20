#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(unsigned long, objc_object*, NSDictionary*);

@interface UITouch ()
@property (assign,nonatomic) char isTap;


-(void)setTapCount:(unsigned)arg1;
-(void)setPhase:(int)arg1;
-(float)_pathMajorRadius;
-(void)_setPathMajorRadius:(float)arg1;
@end

@interface UIKeyboardLayout : UIView
@end
@interface UIKeyboardLayoutStar : UIKeyboardLayout
@end