#import <UIKit/UIKit.h>

@protocol BBWeeAppController <NSObject>
@required
- (id)view;
@optional
- (void)loadPlaceholderView;
- (void)loadFullView;
- (void)loadView;
- (void)unloadView;
- (void)clearShapshotImage;
- (id)launchURL;
- (id)launchURLForTapLocation:(CGPoint)tapLocation;
- (float)viewHeight;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end


#define PLS_NO_DEPRECATED(expr)                                   \
do {                                                                \
_Pragma("clang diagnostic push")                                    \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")   \
expr;                                                               \
_Pragma("clang diagnostic pop")                                     \
} while(0)
