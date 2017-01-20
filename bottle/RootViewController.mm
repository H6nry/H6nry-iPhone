#import "RootViewController.h"

static RootViewController *_sharedInstance = nil;

@implementation RootViewController

+(id) sharedInstance {
	@synchronized(self) {
		if (!_sharedInstance)
			_sharedInstance = [[self alloc] init];

		return _sharedInstance;
	}
}

-(void) loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.view.backgroundColor = [UIColor redColor];
	browserView = [[BrowserViewClass alloc] init];
	//browserView2 = [[BrowserViewClass alloc] init];

	[self.navigationController pushViewController:browserView animated:YES];
	//[browserView release];
}

-(void) openBrowserMenu {
	UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title of Alert" message:@" " delegate:self cancelButtonTitle:@"nein!" otherButtonTitles:@"OK", nil]; //einen uialert erstellen
	[theAlert show]; //den alert anzeigen
	[theAlert release]; //und den speicher schnell wieder freigeben

	//[self.navigationController pushViewController:browserView2 animated:NO];
	//[self.navigationController popToRootViewControllerAnimated:NO];
}

@end
