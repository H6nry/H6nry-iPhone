#import "RootViewController.h"

@interface BottleApplication: UIApplication <UIApplicationDelegate> {
	UIWindow *_window;
	//BrowserViewClass *_viewController;
	RootViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic,retain) UINavigationController *navigationController;
@end

@implementation BottleApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application {
/*
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_viewController = [[RootViewController alloc] init];
	
	[_window setRootViewController:_viewController];
	[_window makeKeyAndVisible];*/
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_viewController = [[RootViewController alloc] init];
	
	_navigationController = [[UINavigationController alloc] init];
	_navigationController.navigationBarHidden = YES;
	[_window addSubview:_navigationController.view];
	[_navigationController pushViewController:_viewController animated:YES];
	
	[_window setRootViewController:_navigationController];
	[_window makeKeyAndVisible];
}

- (void)dealloc {
	//[_viewController release];
	[_navigationController release];
	[_window release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
	return YES;
}

@end
