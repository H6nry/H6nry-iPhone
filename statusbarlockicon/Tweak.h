

@interface UIStatusBarWindow : UIWindow //Stub.
@end

@interface UIScrollsToTopInitiatorView : UIView
@end

@interface UIStatusBar : UIScrollsToTopInitiatorView
@property (assign,nonatomic) UIStatusBarWindow * statusBarWindow;
@end