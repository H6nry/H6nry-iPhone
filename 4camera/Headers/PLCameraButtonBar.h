

@class PLCameraOptionsButton, PLCameraButton, PLCameraToggleButton, PLCameraButtonBarProtocol;

@interface PLCameraButtonBar : UIToolbar {
	PLCameraOptionsButton *_optionsButton;
	PLCameraButton *_cameraButton;
	PLCameraToggleButton *_toggleButton;
	int _buttonBarStyle;
	int _buttonBarMode;
	unsigned _isBackgroundVisible : 1;
}
@property(assign, nonatomic) int buttonBarMode;
@property(assign, nonatomic) int buttonBarStyle;
@property(retain, nonatomic) PLCameraToggleButton *toggleButton;
@property(retain, nonatomic) PLCameraButton *cameraButton;
@property(retain, nonatomic) PLCameraOptionsButton *optionsButton;
+ (float)defaultHeight;
+ (id)backgroundImage;
+ (id)backgroundImageForButtonBarStyle:(int)buttonBarStyle;
+ (float)buttonBarHeightForTallScreen:(BOOL)tallScreen;
- (void)layoutSubviews;
- (void)setButtonBarMode:(int)mode animationDuration:(double)duration;
- (void)_setVisibility:(BOOL)visibility;
- (BOOL)isBackgroundVisible;
- (void)dealloc;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame buttonBarStyle:(int)style;
@end

