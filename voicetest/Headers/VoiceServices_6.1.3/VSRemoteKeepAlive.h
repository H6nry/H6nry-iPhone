/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/VoiceServices.framework/VoiceServices
 */

#import <Foundation/Foundation.h>


@protocol VSRemoteKeepAlive <NSObject>
-(oneway void)cancel;
-(oneway void)maintainWithAudioType:(int)audioType keepAudioSessionActive:(BOOL)active;
@end