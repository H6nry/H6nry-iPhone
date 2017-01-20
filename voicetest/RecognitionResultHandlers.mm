#import <Foundation/Foundation.h>
#import "VSRecognitionResultHandler-Protocol.h"
#import "Headers/VSRecognitionSpeakAction.h"

@interface VSVoicenchancerTestResultHandler : NSObject <VSRecognitionResultHandler> {

}
- (VSRecognitionAction *)actionForRecognitionResults:(NSArray *)arg1;
//- (VSRecognitionAction *)actionForRecognitionResult:(VSRecognitionResult *)arg1;
@end

@implementation VSVoicenchancerTestResultHandler
- (VSRecognitionAction *)actionForRecognitionResults:(NSArray *)arg1 {
    NSLog(@"received result!!!! %@", arg1);

    VSRecognitionAction *act = [[VSRecognitionSpeakAction alloc] initWithSpokenFeedbackString:@"Test zurück!" willTerminate:0];

    return act;
}

/* //Not used?
- (VSRecognitionAction *)actionForRecognitionResult:(VSRecognitionResult *)arg1 {
    NSLog(@"yey2!!!!");
    VSRecognitionAction *act = [[VSRecognitionSpeakAction alloc] initWithSpokenFeedbackString:@"Hurra!" willTerminate:0];

    return act;
}*/
@end

__attribute__((constructor)) static void ctor() {
    NSLog(@"Voicenchancer loaded!");
}
