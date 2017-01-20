#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
/*
@protocol BrowserViewClassDelegate <NSObject>

@end
*/
@interface BrowserViewClass : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIScrollViewDelegate> {
UITextField *addressBar;
UIWebView *webView;
UIScrollView *topBar;
}
-(void) loadView;
-(void) viewDidLoad;
-(BOOL) textFieldShouldReturn:(UITextField *)textField;
-(void) webViewDidStartLoad:(UIWebView *)webbView;
-(void) webViewDidFinishLoad:(UIWebView *)webbView;
-(void) webView:(UIWebView *)webbView didFailLoadWithError:(NSError *)error;
-(void) scrollViewDidEndDragging:(UIScrollView *)sscrollView willDecelerate:(BOOL)decelerate;
-(void) scrollViewDidScrollToTop:(UIScrollView *)sscrollView;
-(void) scrollViewDidEndDecelerating:(UIScrollView *)sscrollView;
-(void) topBarAnimateIn:(UIView *)topBar;
-(void) topBarAnimateOut:(UIView *)topBar;
//-(void) handleSwipeRightFrom:(UIGestureRecognizer* )recognizer;
//-(void) handleSwipeLeftFrom:(UIGestureRecognizer* )recognizer;
-(void) updateAdressbarColorWithComplexity:(NSUInteger)complexity;

@end

//Just a little bit of ios 8 support to make our life easier :)
@interface NSString ( containsCategory )
-(BOOL) containsString:(NSString *)substring;
@end
@implementation NSString ( containsCategory )
-(BOOL) containsString:(NSString *)substring {    
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}
@end