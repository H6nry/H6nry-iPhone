#import <UIKit/UIKit.h>
#import <math.h>
#import <substrate.h>
#import "watchscreen.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

@class WSManager;

@interface WSIconView : SBIconView
@end

@interface WSView : UIView //WSGFrontend grouped.
@end

@interface WSScrollView : UIScrollView //WSGFrontend grouped.
@property (nonatomic, retain) WSView *contentView;
@end

@interface WSViewController : UIViewController <UIScrollViewDelegate, SBIconViewDelegate> //WSGBackend grouped.
@property (nonatomic, assign) NSUInteger homeScreenIcons; //Must this be a property??
@property (nonatomic, retain) WSManager *manager; //"Call the manager, he will do the think-y stuff"
+ (id)sharedInstance;
- (CGPoint)iconPositionWithIndexPath:(NSIndexPath *)path;
- (void)addIcon:(SBIcon *)icon;
- (void)removeIcon:(SBIcon *)icon;
- (unsigned long int)contentSize;
@end

@interface WSManager : NSObject //WSGBackend grouped.
@property (nonatomic, retain) WSViewController *viewController;
+ (id)sharedInstance;
- (void)addIcon:(SBIcon *)icon;
- (void)removeIcon:(SBIcon *)icon;
- (void)moveIcon:(SBIcon *)icon toIndexPath:(NSIndexPath *)path animated:(BOOL)animated;
- (void)uninstallIcon:(SBIcon *)icon;
@end

@interface UIImage (circularCropCategory)
-(UIImage*) circularCropImage;
@end
