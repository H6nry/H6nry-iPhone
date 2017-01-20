#import <UIKit/UIKit.h>
#include <time.h>
#import <CommonCrypto/CommonDigest.h>

@interface SCMediaView : UIImageView
@property(retain, nonatomic) UIImageView *imageView;
@end




%group main

%hook SCMediaView
-(id) imageView {
	%log;
	SCMediaView *view = %orig;

	unsigned char result[CC_MD5_DIGEST_LENGTH];
	NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(view.image, 1.0)];
	CC_MD5([imageData bytes], [imageData length], result);
	NSString *imageHash = [NSString stringWithFormat:
                       @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                       result[0], result[1], result[2], result[3],
                       result[4], result[5], result[6], result[7],
                       result[8], result[9], result[10], result[11],
                       result[12], result[13], result[14], result[15]
                       ];

	NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:imageHash] URLByAppendingPathExtension:@"jpg"];

	if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path] ) {
		[UIImageJPEGRepresentation(view.image, 1.0) writeToFile:fileURL.path atomically:YES];
	}

	return view;
}
%end

%end

%ctor {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.snapper-prefs.plist"];
	if ([[prefs objectForKey:@"Enabled"] boolValue]) {
		%init(main);
		NSLog(@"SnapPer: Let's start hax!");
	}
}
