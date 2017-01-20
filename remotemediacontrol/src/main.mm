#import "main.h"

int main(int argc, char **argv, char **envp) {
	@autoreleasepool {
		RCController *controller = [[RCController alloc] init];
		DLog(@"RMC: Initialized: %@", controller);
    	[[NSRunLoop mainRunLoop] run]; //Is this enough to keep the daemon alive?
	}
	NSLog(@"RMC: Terminating now...");

	return 0;
}
