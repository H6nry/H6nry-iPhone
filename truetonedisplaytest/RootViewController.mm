#import "RootViewController.h"

typedef struct {
	long long value;
	int timescale;
	unsigned flags;
	long long epoch;
} SCD_Struct_CM8;

@interface AVCaptureDevice ()
-(float)whiteBalanceTemperature;
-(void)setExposureGain:(float)arg1 ;
-(void)setExposureDuration:(SCD_Struct_CM8)arg1 ;
-(void)setManualExposureSupportEnabled:(char)arg1 ;
-(void)setContrast:(float)arg1 ;
@end

@implementation RootViewController
- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.backgroundColor = [UIColor whiteColor];

	photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,160)];
	photoView.backgroundColor = [UIColor redColor];
	[self.view addSubview:photoView];
}

-(void) viewDidAppear:(BOOL)animated {
	//Create a new session
	session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetLow;

	//Some preview layer, cannot remove, crashes then :(
	/*AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];

	captureVideoPreviewLayer.frame = cameraView.bounds;
	[cameraView.layer addSublayer:captureVideoPreviewLayer];*/

	//Rear camera. TODO: Front cam.
	NSArray *devices = [AVCaptureDevice devices];

 	AVCaptureDevice *device;
	for (device in devices) {
	    if ([device hasMediaType:AVMediaTypeVideo]) {
	        if ([device position] == AVCaptureDevicePositionFront) {
	            break;
	        }
	    }
	}

	[device lockForConfiguration:nil];

	[device setWhiteBalanceMode:0];
	//[device setFocusMode:0]; //No possible on front camera
	[device setContrast:1];

	[device unlockForConfiguration];

	//We should do this everywhere... :o
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];

	//The image output
	stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[stillImageOutput setOutputSettings:outputSettings];

	[session addOutput:stillImageOutput];

	//Start the session
	[session startRunning];

	NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(updateBG:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

//Some magic I am unable to understand
#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )

-(void) updateBG:(NSTimer *)timer {
	//Connection?
	AVCaptureConnection *videoConnection;
	for (AVCaptureConnection *connection in stillImageOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([[port mediaType] isEqual:AVMediaTypeVideo] )
			{
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}

	NSLog(@"about to request a capture from: %@", videoConnection);

	[stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
		NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
		UIImage *image = [[UIImage alloc] initWithData:imageData];

		CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB(); //Create RGB color space
		NSUInteger bytesPerPixel = 4; //Memory per pixel
		NSUInteger bitsPerComponent = 8; //Bits per component R, G, B
		NSUInteger inputWidth = [image size].width;
		NSUInteger inputHeight = [image size].height;
		NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth; //Memory per line of image
		UInt32 * inputPixels; //Where we store the buffer
		inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32)); //Reserve buffer to write
		CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight, bitsPerComponent, inputBytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); //Create a bitmap context

		CGContextDrawImage(context, CGRectMake(0,0, [image size].width, [image size].height), [image CGImage]); //Render image into context

		//Calculate the average of some pixels
		double rAv = 0; //Red
		double gAv = 0; //Green
		double bAv = 0; //Blue
		int c = 0; //Calculated pixels

		for (NSUInteger j = 0; j < inputHeight; j=j+5) {
			for (NSUInteger i = 0; i < inputWidth; i=i+5) {
				UInt32 * currentPixel = inputPixels + (j * inputWidth) + i;
				UInt32 color = *currentPixel;

				//if (R(color) >= 150 || G(color) >= 150 || B(color) >= 150) {
					rAv = rAv + R(color);
					gAv = gAv + G(color);
					bAv = bAv + B(color);
					c++;
				//}
			}
		}

		//Calculate the colors within range from 0-1
		rAv = rAv/c/255.0f;
		gAv = gAv/c/255.0f;
		bAv = bAv/c/255.0f;

		//First, calculate the brightness
		double bri = 0.299 * rAv + 0.587 * gAv + 0.114 * bAv;

		NSLog(@"1----  %f  %f  %f   %f", rAv, gAv, bAv, bri);

		//Now, fit the colors to maximum brightness
		double diff;
		double max;

		if (rAv >= gAv) { //This is so ugly and I know there is a better way
			if (rAv >= bAv) {
				max = rAv;
			} else {
				max = bAv;
			}
		} else {
			if (gAv >= bAv) {
				max = gAv;
			} else {
				max = bAv;
			}
		}

		diff = 1 - max;
		rAv = rAv + diff;
		gAv = gAv + diff;
		bAv = bAv + diff;

		NSLog(@"1----  %f  %f  %f   %f", rAv, gAv, bAv, bri);

		//Update when it is bright enough to calculate a color which makes sense at all
		if (bri >= 0.4) {
			if (aR == 0) aR = rAv;
			if (aG == 0) aG = gAv;
			if (aB == 0) aB = bAv;

			aR = (rAv + aR*2)/3; //Not good.
			aG = (gAv + aG*2)/3;
			aB = (bAv + aB*2)/3;

			//TODO: Implement iomfsetgamma's functionality here
			char string[100];
			sprintf(string, "iomfsetgamma %f %f %f", aR, aG, aB);
			NSLog(@"%s", string);
			system(string);
		}

		CGImageRef myImage;
		myImage = CGBitmapContextCreateImage (context);
		photoView.image = [UIImage imageWithCGImage:myImage];

		CGContextRelease(context); //I want to ...
		free(inputPixels); //... break free ...
		CGColorSpaceRelease(colorSpaceRef); //... I want to break free ... (to be continued)
	 }];
}
@end
