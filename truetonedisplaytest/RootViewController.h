#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RootViewController: UIViewController {
    UIView *cameraView;
    UIImageView *photoView;
    AVCaptureStillImageOutput *stillImageOutput;
    double aR;
    double aG;
    double aB;
    AVCaptureSession *session;
}
@end
