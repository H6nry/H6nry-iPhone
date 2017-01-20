#import <Foundation/Foundation.h>
#import "VoiceServices_6.1.3/VSRecognitionResultHandlingThread.h"

@protocol VSRecognitionSessionDelegate <NSObject>
@optional
-(void)recognitionSession:(id)session didCompleteActionWithError:(id)error;
-(void)recognitionSession:(id)session didFinishSpeakingFeedbackStringWithError:(id)error;
-(id)recognitionSession:(id)session openURL:(id)url;
-(void)recognitionSessionDidBeginAction:(id)recognitionSession;
-(BOOL)recognitionSessionWillBeginAction:(id)recognitionSession;
//manually added...
- (void) recognitionResultHandlingThread:(VSRecognitionResultHandlingThread *) thread didHandleResults:(id) results nextAction: (id) nextAction;
@end
