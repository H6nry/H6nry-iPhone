#import <UIKit/UIKit.h>
#include <math.h>
#include <substrate.h>

typedef struct {
	int type;
	unsigned pathIndex;
	CGPoint location;
	CGPoint previousLocation;
	float totalDistanceTraveled;
	int interfaceOrientation;
	int previousInterfaceOrientation;
} XXStruct_DSYOgA;

typedef XXStruct_DSYOgA SBActiveTouch;

/*typedef struct __SBGestureContext* SBGestureContextRef;

@interface SBGestureRecognizer : NSObject {
	unsigned m_types;
	int m_state;
	id m_handler;
	unsigned m_activeTouchesCount;
	XXStruct_DSYOgA m_activeTouches[30];
	unsigned m_strikes;
	unsigned m_templateMatches;
	NSMutableArray* m_touchTemplates;
	BOOL m_includedInGestureRecognitionIsPossibleTest;
	BOOL m_sendsTouchesCancelledToApplication;
	id m_canBeginCondition;
}
@property(copy, nonatomic) id canBeginCondition;
@property(assign, nonatomic) BOOL sendsTouchesCancelledToApplication;
@property(assign, nonatomic) BOOL includedInGestureRecognitionIsPossibleTest;
@property(copy, nonatomic) id handler;
@property(assign, nonatomic) int state;
@property(assign, nonatomic) unsigned types;
-(void)touchesCancelled:(SBGestureContextRef)cancelled;
-(void)touchesEnded:(SBGestureContextRef)ended;
-(void)touchesMoved:(SBGestureContextRef)moved;
-(void)touchesBegan:(SBGestureContextRef)began;
-(int)templateMatch;
-(void)addTouchTemplate:(id)aTemplate;
-(void)sendTouchesCancelledToApplicationIfNeeded;
-(void)reset;
-(BOOL)shouldReceiveTouches;
-(void)dealloc;
-(id)init;
@end





@interface SBFluidSlideGestureRecognizer : SBGestureRecognizer {
	int m_degreeOfFreedom;
	unsigned m_minTouches;
	BOOL m_blocksIconController;
	float _animationDistance;
	float _commitDistance;
	float _accelerationThreshold;
	float _accelerationPower;
	int _requiredDirectionality;
	float _defaultHandSize;
	float _handSizeCompensationPower;
	float _incrementalMotion;
	float _smoothedIncrementalMotion;
	float _cumulativeMotion;
	float _cumulativeMotionEnvelope;
	float _cumulativeMotionSkipped;
	BOOL _hasSignificantMotion;
	CGPoint _movementVelocityInPointsPerSecond;
	CGPoint _centroidPoint;
}
@property(readonly, assign, nonatomic) CGPoint centroidPoint;
@property(readonly, assign, nonatomic) CGPoint movementVelocityInPointsPerSecond;
@property(readonly, assign, nonatomic) float incrementalMotion;
@property(readonly, assign, nonatomic) float cumulativeMotion;
@property(readonly, assign, nonatomic) float skippedCumulativePercentage;
@property(readonly, assign, nonatomic) float cumulativePercentage;
@property(readonly, assign, nonatomic) int degreeOfFreedom;
@property(assign, nonatomic) int requiredDirectionality;
@property(assign, nonatomic) float accelerationPower;
@property(assign, nonatomic) float accelerationThreshold;
@property(assign, nonatomic) float animationDistance;
@property(assign, nonatomic) unsigned minTouches;
-(void)touchesCancelled:(SBGestureContextRef)cancelled;
-(void)touchesEnded:(SBGestureContextRef)ended;
-(void)touchesMoved:(SBGestureContextRef)moved;
-(void)touchesBegan:(SBGestureContextRef)began;
-(void)updateActiveTouches:(SBGestureContextRef)touches;
-(void)updateForEndedOrCancelledTouches:(SBGestureContextRef)endedOrCancelledTouches;
-(void)updateForBeganOrMovedTouches:(SBGestureContextRef)beganOrMovedTouches;
-(int)completionTypeProjectingMomentumForInterval:(double)interval;
-(float)projectMotionForInterval:(double)interval;
-(void)computeCentroidPoint:(SBGestureContextRef)point;
-(void)computeHasSignificantMotionIfNeeded:(SBGestureContextRef)needed;
-(float)computeIncrementalGestureMotion:(SBGestureContextRef)motion;
-(void)computeGestureMotion:(SBGestureContextRef)motion;
-(float)computeHandSizeCompensationGain:(float)gain;
-(float)computeNonlinearSpeedGain:(float)gain;
-(void)skipCumulativeMotion;
-(void)reset;
-(id)init;
@end




@interface SBPanGestureRecognizer : SBFluidSlideGestureRecognizer {
	float _arcCenter;
	float _arcSize;
	BOOL _recognizesHorizontalPanning;
	BOOL _recognizesVerticalPanning;
}
-(void)updateForBeganOrMovedTouches:(SBGestureContextRef)beganOrMovedTouches;
-(float)computeIncrementalGestureMotion:(SBGestureContextRef)motion;
-(id)initForVerticalPanning;
-(id)initForHorizontalPanning;
-(id)init;
@end





@interface SBOffscreenSwipeGestureRecognizer : SBPanGestureRecognizer {
	int m_offscreenEdge;
	float m_edgeMargin;
	float m_falseEdge;
	int m_touchesChecked;
	CGPoint m_firstTouch;
	float m_edgeCenter;
	float m_allowableDistanceFromEdgeCenter;
	BOOL m_requiresSecondTouchInRange;
}
@property(assign, nonatomic) float edgeCenter;
@property(assign, nonatomic) BOOL requiresSecondTouchInRange;
@property(assign, nonatomic) float allowableDistanceFromEdgeCenter;
@property(assign, nonatomic) float falseEdge;
@property(assign, nonatomic) float edgeMargin;
-(void)updateForBeganOrMovedTouches:(SBGestureContextRef)beganOrMovedTouches;
-(void)_updateAnimationDistanceAndEdgeCenter;
-(BOOL)secondTouchInRange:(CGPoint)range;
-(BOOL)firstTouchInRange:(CGPoint)range;
-(void)reset;
-(id)initForOffscreenEdge:(int)offscreenEdge;
@end*/






@interface SBShowcaseController : NSObject {

	UIWindow* _hostWindow;
	UIView* _hostView;
	UIWindow* _showcaseWindow;
	UIView* _rootView;
	UIView* _contentView;
	UIControl* _blockingView;
	UIView* _clippingView;
	UIView* _showcaseView;
	UIView* _topShadowView;
	UIView* _bottomShadowView;
	UIView* _hidingView;


	float _revealAmount;
	int _orientation;
	char _isAnimating;
	int _pendingRevealMode;

}

@property (nonatomic,retain) UIView * hostView;                                          //@synthesize hostView=_hostView - In the implementation block
@property (nonatomic,retain) UIView * hidingView;                                        //@synthesize hidingView=_hidingView - In the implementation block
@property (nonatomic,readonly) UIControl * blockingView;                                 //@synthesize blockingView=_blockingView - In the implementation block
@property (nonatomic,readonly) UIWindow * window;                                        //@synthesize showcaseWindow=_showcaseWindow - In the implementation block
@property (assign,nonatomic) int orientation;                                            //@synthesize orientation=_orientation - In the implementation block
@property (assign,nonatomic) float revealAmount;                                         //@synthesize revealAmount=_revealAmount - In the implementation block
@property (assign,nonatomic) int revealMode; 
@property (assign,getter=isAnimating,nonatomic) char animating;                          //@synthesize isAnimating=_isAnimating - In the implementation block
+(float)fullRevealAmount;
-(int)revealMode;
-(float)revealAmount;
-(UIControl *)blockingView;


-(void)setHostView:(UIView *)arg1 ;
-(float)revealAmountForMode:(int)arg1 ;
-(void)willAppear;
-(void)noteRevealModeWillChange:(int)arg1 ;
-(void)setRevealMode:(int)arg1 ;
-(void)didDisappear;

-(void)setRevealAmount:(float)arg1 ;
-(CGRect)showcaseViewFrame;
-(void)setHidingView:(UIView *)arg1 ;
-(UIView *)hidingView;
-(char)transferOwnershipToOwner:(id)arg1 ;
-(float)bottomBarHeight;
-(void)_updateShowcase;
-(float)_showcaseWindowLevel;
-(void)_updateShowcaseWindowLevel;
-(float)_showcaseRevealedAmount;
-(CGRect)_portraitAdjustedFrameForFrame:(CGRect)arg1 ;
-(CGAffineTransform)_rootTransform;
-(CGRect)_hostViewFrame;
-(float)_separatorAlphaForRevealAmount:(float)arg1 ;
-(void)updateRevealMode:(int)arg1 withBlock:(/*^block*/id)arg2 ;
-(CGRect)_visibleShowcaseBounds;
-(CGRect)_adjustedContentFrameForFrame:(CGRect)arg1 ;
-(void)dismissWithFadeOfDuration:(double)arg1 ;
-(void)didAppear;
-(void)willDisappear;
-(CGRect)_contentFrame;
-(UIWindow *)window;
-(void)setHidden:(char)arg1 ;
-(void)setAlpha:(float)arg1 ;
-(int)orientation;
-(void)willRotateToInterfaceOrientation:(int)arg1 ;
-(void)willAnimateRotationToInterfaceOrientation:(int)arg1 ;
-(void)setAnimating:(char)arg1 ;
-(void)didRotateFromInterfaceOrientation:(int)arg1 ;
-(char)isAnimating;
-(void)setOrientation:(int)arg1 ;
-(UIView *)hostView;
-(void)dismissWithAnimation:(char)arg1 ;



@end





@interface SBUIController : NSObject
@property (nonatomic,retain) SBShowcaseController * showcaseController;

+(id)sharedInstance;
-(BOOL)activateSwitcher;
@end

@interface SBShowcaseViewController : NSObject
@property (assign,nonatomic) SBShowcaseController * showcase;

@end



@interface SBAppSwitcherController : SBShowcaseViewController
+(id)sharedInstance;
-(char)handleMenuButtonTap;
-(id)view;

@end
