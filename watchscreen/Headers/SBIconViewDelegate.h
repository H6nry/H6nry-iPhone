@protocol SBIconViewDelegate <NSObject>
@optional
-(BOOL)iconViewDisplaysBadges:(id)badges;
-(BOOL)iconShouldPrepareGhostlyImage:(id)icon;
-(void)iconCloseBoxTapped:(id)tapped;
-(int)closeBoxTypeForIcon:(id)icon;
-(void)icon:(id)icon openFolder:(id)folder animated:(BOOL)animated;
-(void)icon:(id)icon closeFolderAnimated:(BOOL)animated;
-(BOOL)icon:(id)icon canReceiveGrabbedIcon:(id)icon2;
-(void)iconTapped:(id)tapped;
-(BOOL)iconShouldAllowTap:(id)icon;
-(void)icon:(id)icon touchEnded:(BOOL)ended;
-(void)icon:(id)icon touchMovedWithEvent:(id)event;
-(void)iconTouchBegan:(id)began;
-(void)iconHandleLongPress:(id)press;
-(BOOL)iconPositionIsEditable:(id)editable;
-(BOOL)iconAllowJitter:(id)jitter;
@end
