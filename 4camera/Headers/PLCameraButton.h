

@class UIImageView, UIView, UIImage, NSArray;

@interface PLCameraButton : UIButton {
	UIView *_rotationHolder;
	UIImageView *_iconView;
	BOOL _lockEnabled;
	BOOL _isLandscape;
	BOOL _dontDrawDisabled;
	UIImage *_cameraIcon;
	UIImage *_cameraIconLandscape;
	NSArray *_videoRecordingIcons;
	UIImage *_panoRecordingIcon;
	UIImage *_panoRecordingIconLandscape;
	int _buttonMode;
	BOOL _isCapturing;
	int _orientation;
	BOOL _watchingOrientationChanges;
}
+ (UIEdgeInsets)hitRectExtension;
+ (UIEdgeInsets)backgroundResizableEdgeInsets;
+ (CGRect)defaultFrame;
+ (id)videoOnIconName;
+ (id)videoOffIconName;
+ (id)photoIconLandscapeName;
+ (id)photoIconPortraitName;
+ (id)backgroundPanoOnPressedImageName;
+ (id)backgroundPanoOnImageName;
+ (id)backgroundPanoOffPressedImageName;
+ (id)backgroundPanoOffImageName;
+ (id)backgroundVideoPressedImageName;
+ (id)backgroundVideoImageName;
+ (id)backgroundPressedImageName;
+ (id)backgroundImageName;
+ (id)defaultIconName;
- (int)orientation;
- (void)setButtonOrientation:(int)orientation animated:(BOOL)animated;
- (void)_deviceOrientationChanged:(id)changed;
- (void)_stopWatchingDeviceOrientationChanges;
- (void)_startWatchingDeviceOrientationChanges;
- (void)setLockEnabled:(BOOL)enabled;
- (void)_setHighlightOnMouseDown:(BOOL)down;
- (void)setEnabled:(BOOL)enabled;
- (void)setDontShowDisabledState:(BOOL)state;
- (BOOL)pointInside:(CGPoint)inside withEvent:(id)event;
- (void)setIsCapturing:(BOOL)capturing;
- (void)setButtonMode:(int)mode;
- (void)_loadPanoLandscapeResources;
- (void)_loadPanoResources;
- (void)_loadVideoResources;
- (void)_loadStillLandscapeResources;
- (void)_loadStillResources;
- (void)dealloc;
- (void)_setIcon:(id)icon;
- (id)initWithDefaultSize;
@end

