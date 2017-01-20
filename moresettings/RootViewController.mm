#import "RootViewController.h"

@implementation RootViewController
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view setAutoresizesSubviews: YES];
	[self becomeFirstResponder];
	self.view.userInteractionEnabled = YES;

	UILabel *hostsDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 240, 30)];
	hostsDescription.text = NSLocalizedString(@"STOP_ADS", "Stop advertisements");
	hostsDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:hostsDescription];

	BOOL hostsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"hostsEnabled"];

	_toggleHostBlocker = [[UISwitch alloc] initWithFrame:CGRectMake(240, 20, 100, 100)];
	_toggleHostBlocker.on = hostsEnabled;
	[_toggleHostBlocker addTarget:self action:@selector(toggleHostBlocker:) forControlEvents:UIControlEventValueChanged];

	[self.view addSubview:_toggleHostBlocker];
}

-(void) toggleHostBlocker:(UISwitch *)blocker {
	[[NSUserDefaults standardUserDefaults] setBool:blocker.on forKey:@"hostsEnabled"];

	NSString *hostsPath;
	if (blocker.on == YES) {
		hostsPath = [[NSBundle mainBundle] pathForResource:@"hosts_block" ofType:@""];
	} else {
		hostsPath = [[NSBundle mainBundle] pathForResource:@"hosts_clear" ofType:@""];
	}
	[[NSData dataWithContentsOfFile:hostsPath] writeToFile:@"/etc/hosts" atomically:NO];


	//NSLog(@"---%i", ret);
}
@end
