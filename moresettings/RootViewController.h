#import <UIKit/UIKit.h>

@interface RootViewController: UIViewController {
	UISwitch *_toggleHostBlocker;
}
-(void) toggleHostBlocker:(UISwitch *)blocker;
@end
