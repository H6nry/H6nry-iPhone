#import "BrowserViewClass.h"

@interface RootViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIScrollViewDelegate> {
BrowserViewClass *browserView;
BrowserViewClass *browserView2;
}
+(id) sharedInstance;
-(void) openBrowserMenu;
@end