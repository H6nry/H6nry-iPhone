#import "BrowserViewClass.h"
#import "RootViewController.h"

@interface BrowserViewClass ()

@end

@implementation BrowserViewClass
-(void) loadView {
	
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

-(void) viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view setAutoresizesSubviews: YES];
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
	self.view.userInteractionEnabled = YES;
	
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
	//self.view.contentMode = UIViewContentModeScaleToFill;
	//self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	[webView setScalesPageToFit:YES]; //wichtig weil sonst zoom
	[webView setKeyboardDisplayRequiresUserAction:YES]; //tastatur nur auf befehl anzeigen
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"start" ofType:@"html"]]]]; //startseite, wie bekommt man localhost???
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:webView];
	webView.delegate = self; //das delegate definieren (sh. auch rvc.h)
	webView.scrollView.delegate = self;
	webView.scrollView.scrollsToTop = YES;
    [webView release];
	
	
	topBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
	[topBar setBackgroundColor:[UIColor whiteColor]];
	topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	topBar.userInteractionEnabled = YES;
	topBar.showsHorizontalScrollIndicator = NO;
	topBar.showsVerticalScrollIndicator = NO;
	topBar.alwaysBounceVertical = YES;
	topBar.alwaysBounceHorizontal = YES;
	topBar.directionalLockEnabled = YES;
	topBar.scrollsToTop = NO;
	[topBar setContentSize:topBar.frame.size];
	topBar.delegate = self;
	[self.view addSubview:topBar];
	[topBar release];
	
	
	addressBar = [[UITextField alloc] initWithFrame:CGRectMake(5, 9, self.view.bounds.size.width-10, 32)];
	[addressBar setFont:[UIFont systemFontOfSize:27.0]];
	[addressBar setClearButtonMode:UITextFieldViewModeWhileEditing];
	[addressBar setBackgroundColor:[UIColor clearColor]];
	[addressBar setPlaceholder:@"Bottle - of milk"];//---
	/*UISwipeGestureRecognizer* addrSwipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
	addrSwipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	UISwipeGestureRecognizer* addrSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
	addrSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;//---
	[addressBar addGestureRecognizer:addrSwipeRight];
	[addressBar addGestureRecognizer:addrSwipeLeft];*/
	//UIPanGestureRecognizer *gesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateHeightDragged:)] autorelease];
	//[addressBar addGestureRecognizer:gesture];
	addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	addressBar.autocorrectionType = UITextAutocorrectionTypeNo;
	addressBar.spellCheckingType = UITextSpellCheckingTypeYes;
	addressBar.keyboardType = UIKeyboardTypeASCIICapable;
	addressBar.returnKeyType = UIReturnKeyGo;
	addressBar.userInteractionEnabled = YES;
	addressBar.tag = 315;
	[topBar addSubview:addressBar];
	addressBar.delegate = self;
	[addressBar release];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField { //textfeld-delegate
	if(textField==addressBar) {
		[addressBar resignFirstResponder];
		
		NSString *url = textField.text;
		
		if ([url isEqualToString:@""]) return YES;
		
		if (([url containsString:@"http://"]) || (![url containsString:@" "] && [url containsString:@"."])) {
			if ([url rangeOfString:@"http://"].location == 0) {
				[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
			} else {
				[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"http://" stringByAppendingString:url]]]];
			}
		} else {
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"http://google.com/search?q=" stringByAppendingString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]]];
		}
		return NO;
	}
	return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
	[textField selectAll:nil];
}

-(void) webViewDidStartLoad:(UIWebView *)webbView { //webview-delegate
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//[addrDummie setBackgroundColor:[UIColor whiteColor]];
	//[addressBar setBackgroundColor:[UIColor whiteColor]];
}

-(void) webViewDidFinishLoad:(UIWebView *)webbView {
	//NSString *javScript = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inject" ofType:@"js"] encoding:nil error:nil];
	//NSString *javScript = [NSString stringWithContentsOfFile:@"inject.js" encoding:nil error:nil];
	//[webbView stringByEvaluatingJavaScriptFromString:javScript];
	//NSLog(@"%@",re);
	
	//if ([webbView canGoBack]) {
		[addressBar setText:[webView.request.URL absoluteString]]; 
	//} else {
	//	[addressBar setText:@""];
	//}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[self updateAdressbarColorWithComplexity:50];
}

-(void) webView:(UIWebView *)webbView didFailLoadWithError:(NSError *)error {
	//_webViewLoads--;

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)sscrollView willDecelerate:(BOOL)decelerate { //scrollview-delegate
	if ([sscrollView isEqual:[webView scrollView]]) {
		CGPoint scoff = [sscrollView contentOffset];
		
		if (scoff.y <= -30) {
			[self topBarAnimateIn:topBar];
		} else if (topBar.bounds.origin.y > -61) {
			[self topBarAnimateOut:topBar];
		}
	} else if ([sscrollView isEqual:topBar]) {
		CGPoint scoff = [sscrollView contentOffset];
		
		if (scoff.x <= -60) {
			NSLog(@"zurueck");
			if ([webView canGoBack]) {
				[webView goBack];
			}
		} else if (scoff.x >= 60) {
			NSLog(@"vor");
			if ([webView canGoForward]) {
				[webView goForward];
			}
		}
	}
}

-(void) scrollViewDidScrollToTop:(UIScrollView *)sscrollView {
	[self updateAdressbarColorWithComplexity:50]; //die farbe der adresszeile anpassen
	[self topBarAnimateIn:topBar];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)sscrollView {
	if ([sscrollView contentOffset].y == 0) {
		[self updateAdressbarColorWithComplexity:50]; //die farbe der adresszeile anpassen
	}
}

-(void) topBarAnimateIn:(UIView *)toppBar { //blende die topbar ein
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		[toppBar setFrame:(CGRectMake(0, 0, toppBar.bounds.size.width, toppBar.bounds.size.height))];
	} completion:nil];
}

-(void) topBarAnimateOut:(UIView *)toppBar { //blende die topbar aus
	if ([(UITextField *)[toppBar viewWithTag:315] isEditing]) return;
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		[toppBar setFrame:(CGRectMake(0, -66, toppBar.bounds.size.width, toppBar.bounds.size.height))];
	} completion:nil];
}

/*-(void) handleSwipeRightFrom:(UIGestureRecognizer* )recognizer { //navigations-geste zurueck
	if ([webView canGoBack]) {
		[webView goBack];
	}
}

-(void) handleSwipeLeftFrom:(UIGestureRecognizer* )recognizer { //navigations-geste vor
	if ([webView canGoForward]) {
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[addressBar setFrame:(CGRectMake(-addressBar.bounds.size.width, addressBar.bounds.origin.y, addressBar.bounds.size.width, addressBar.bounds.size.height))];
		[UIView commitAnimations];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0];
		[addressBar setFrame:(CGRectMake(addressBar.bounds.size.width, addressBar.bounds.origin.y, addressBar.bounds.size.width, addressBar.bounds.size.height))];
		[UIView commitAnimations];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[addressBar setFrame:(CGRectMake(5, addressBar.bounds.origin.y, addressBar.bounds.size.width, addressBar.bounds.size.height))];
		[UIView commitAnimations];
	
	
		[webView goForward];
	}
}*/

-(void) updateAdressbarColorWithComplexity:(NSUInteger)complexity {
	CGSize screenSize = webView.bounds.size; //die bildschirmgroesse
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB(); //einen rgb-farbraum erschaffen
	NSUInteger bytesPerPixel = 4; //die speicherplatzgroesse pro pixel
	NSUInteger bitsPerComponent = 8; //die speicherplatzgroesse pro farbanteil
	NSUInteger inputWidth = screenSize.width; // die zu berechnende breite
	NSUInteger inputHeight = complexity; //screenSize.height; // die zu berechnende hoehe
	NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth; //die speicherplatzgroesse pro zeile
	UInt32 * inputPixels; //speicherplatz
	inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32)); //speicherplatz wird reserviert
	CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight, bitsPerComponent, inputBytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); //einen neuen context im speicher erstellen
	
	[(CALayer*)webView.layer renderInContext:context]; //die aktuelle ansicht in den context schreiben
	
	double rAv = 0; //rot
	double gAv = 0; //gruen
	double bAv = 0; //blau
	int c = 0; //zaehler
	
	for (NSUInteger j = 0; j < inputHeight; j++) {
		for (NSUInteger i = 0; i < inputWidth; i++) {
			UInt32 * currentPixel = inputPixels + (j * inputWidth) + i;
			UInt32 color = *currentPixel;
			
			rAv = rAv + R(color);
			gAv = gAv + G(color);
			bAv = bAv + B(color);
			c++;
		}
	}
	rAv = ((rAv/c/255.0)+1)/2; //in einen Wert von 0 bis 1 apassen und weiss annaehern
	gAv = ((gAv/c/255.0)+1)/2; //s o
	bAv = ((bAv/c/255.0)+1)/2; //s o
	
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		[topBar setBackgroundColor:[UIColor colorWithRed:rAv green:gAv blue:bAv alpha:1]]; //die farbe setzen
	} completion:nil];
	
	CGContextRelease(context); //alles freigeben
	free(inputPixels); //alles freigeben
	CGColorSpaceRelease(colorSpaceRef); //alles freigeben
}

-(void) updateHeightDragged:(UIPanGestureRecognizer *)gesture {
	UIView *dragView = (UIView *)gesture.view;
	CGPoint translation = [gesture translationInView:dragView];
	if (dragView.center.y + translation.y > 0) {
		dragView.center = CGPointMake(dragView.center.x, dragView.center.y + translation.y);
	}
	[gesture setTranslation:CGPointZero inView:dragView];
}

@end