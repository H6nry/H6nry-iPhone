#import <Foundation/NSObject.h>

@class NSArray, VSRecognitionAction, VSRecognitionResult;

@protocol VSRecognitionResultHandler <NSObject>

@optional
- (VSRecognitionAction *)actionForRecognitionResults:(NSArray *)arg1;
- (VSRecognitionAction *)actionForRecognitionResult:(VSRecognitionResult *)arg1;
@end
