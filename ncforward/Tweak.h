#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


//Some headers which might be important
@class NSString, NSSet, BBContent, NSDate, NSTimeZone, BBSound, BBAttachments, NSMutableDictionary, NSArray, NSDictionary, NSMutableArray, BBObserver, NSData, BBAction;

@interface BBBulletin : NSObject <NSCopying, NSCoding> {

	NSString* _sectionID;
	NSSet* _subsectionIDs;
	NSString* _publisherRecordID;
	NSString* _publisherBulletinID;
	int _addressBookRecordID;
	int _sectionSubtype;
	BBContent* _content;
	BBContent* _modalAlertContent;
	NSDate* _date;
	NSDate* _endDate;
	NSDate* _recencyDate;
	int _dateFormatStyle;
	char _dateIsAllDay;
	NSTimeZone* _timeZone;
	int _accessoryStyle;
	char _clearable;
	BBSound* _sound;
	BBAttachments* _attachments;
	NSString* _unlockActionLabelOverride;
	NSMutableDictionary* _actions;
	NSArray* _buttons;
	char _expiresOnPublisherDeath;
	NSDictionary* _context;
	NSDate* _expirationDate;
	unsigned _expirationEvents;
	NSSet* _alertSuppressionContexts;
	NSString* _bulletinID;
	NSDate* _lastInterruptDate;
	char _showsMessagePreview;
	NSString* _bulletinVersionID;
	NSMutableArray* _lifeAssertions;
	BBObserver* _observer;
	unsigned realertCount_deprecated;
	NSSet* alertSuppressionAppIDs_deprecated;

}

@property (nonatomic,readonly) NSString * sectionDisplayName; 
@property (nonatomic,readonly) NSData * sectionIconData; 
@property (nonatomic,readonly) char sectionDisplaysCriticalBulletins; 
@property (nonatomic,readonly) char showsSubtitle; 
@property (nonatomic,readonly) unsigned messageNumberOfLines; 
@property (nonatomic,readonly) char usesVariableLayout; 
@property (nonatomic,readonly) char orderSectionUsingRecencyDate; 
@property (nonatomic,readonly) char showsDateInFloatingLockScreenAlert; 
@property (nonatomic,readonly) NSString * topic; 
@property (nonatomic,readonly) NSString * missedBannerDescriptionFormat; 
@property (nonatomic,readonly) NSString * fullUnlockActionLabel; 
@property (nonatomic,readonly) NSString * unlockActionLabel; 
@property (nonatomic,readonly) NSSet * alertSuppressionAppIDs; 
@property (nonatomic,readonly) char coalescesWhenLocked; 
@property (nonatomic,readonly) char suppressesMessageForPrivacy; 
@property (nonatomic,readonly) unsigned realertCount; 
@property (nonatomic,readonly) char inertWhenLocked; 
@property (nonatomic,readonly) char preservesUnlockActionCase; 
@property (nonatomic,readonly) char bannerShowsSubtitle; 
@property (nonatomic,readonly) char visuallyIndicatesWhenDateIsInFuture; 
@property (nonatomic,readonly) unsigned subtypePriority; 
@property (nonatomic,readonly) int iPodOutAlertType; 
@property (nonatomic,copy) NSString * bulletinID;                                     //@synthesize bulletinID=_bulletinID - In the implementation block
@property (nonatomic,copy) NSString * section; 
@property (nonatomic,copy) NSString * sectionID;                                      //@synthesize sectionID=_sectionID - In the implementation block
@property (nonatomic,copy) NSSet * subsectionIDs;                                     //@synthesize subsectionIDs=_subsectionIDs - In the implementation block
@property (nonatomic,copy) NSString * recordID;                                       //@synthesize publisherRecordID=_publisherRecordID - In the implementation block
@property (nonatomic,copy) NSString * publisherBulletinID;                            //@synthesize publisherBulletinID=_publisherBulletinID - In the implementation block
@property (assign,nonatomic) int addressBookRecordID;                                 //@synthesize addressBookRecordID=_addressBookRecordID - In the implementation block
@property (assign,nonatomic) int sectionSubtype;                                      //@synthesize sectionSubtype=_sectionSubtype - In the implementation block
@property (nonatomic,copy) NSString * title; 
@property (nonatomic,copy) NSString * subtitle; 
@property (nonatomic,copy) NSString * message; 
@property (nonatomic,retain) BBContent * modalAlertContent;                           //@synthesize modalAlertContent=_modalAlertContent - In the implementation block
@property (nonatomic,retain) NSDate * date;                                           //@synthesize date=_date - In the implementation block
@property (nonatomic,retain) NSDate * endDate;                                        //@synthesize endDate=_endDate - In the implementation block
@property (nonatomic,retain) NSDate * recencyDate;                                    //@synthesize recencyDate=_recencyDate - In the implementation block
@property (assign,nonatomic) int dateFormatStyle;                                     //@synthesize dateFormatStyle=_dateFormatStyle - In the implementation block
@property (assign,nonatomic) char dateIsAllDay;                                       //@synthesize dateIsAllDay=_dateIsAllDay - In the implementation block
@property (nonatomic,retain) NSTimeZone * timeZone;                                   //@synthesize timeZone=_timeZone - In the implementation block
@property (assign,nonatomic) int accessoryStyle;                                      //@synthesize accessoryStyle=_accessoryStyle - In the implementation block
@property (assign,nonatomic) char clearable;                                          //@synthesize clearable=_clearable - In the implementation block
@property (nonatomic,retain) BBSound * sound;                                         //@synthesize sound=_sound - In the implementation block
@property (nonatomic,readonly) int primaryAttachmentType; 
@property (nonatomic,copy) BBAction * defaultAction; 
@property (nonatomic,copy) BBAction * alternateAction; 
@property (nonatomic,copy) BBAction * acknowledgeAction; 
@property (nonatomic,copy) NSArray * buttons;                                         //@synthesize buttons=_buttons - In the implementation block
@property (nonatomic,copy) NSSet * alertSuppressionContexts;                          //@synthesize alertSuppressionContexts=_alertSuppressionContexts - In the implementation block
@property (assign,nonatomic) char expiresOnPublisherDeath;                            //@synthesize expiresOnPublisherDeath=_expiresOnPublisherDeath - In the implementation block
@property (nonatomic,retain) NSDictionary * context;                                  //@synthesize context=_context - In the implementation block
@property (nonatomic,retain) NSDate * lastInterruptDate;                              //@synthesize lastInterruptDate=_lastInterruptDate - In the implementation block
@property (nonatomic,retain) BBContent * content;                                     //@synthesize content=_content - In the implementation block
@property (nonatomic,retain) BBAttachments * attachments;                             //@synthesize attachments=_attachments - In the implementation block
@property (nonatomic,copy) NSString * unlockActionLabelOverride;                      //@synthesize unlockActionLabelOverride=_unlockActionLabelOverride - In the implementation block
@property (nonatomic,retain) NSMutableDictionary * actions;                           //@synthesize actions=_actions - In the implementation block
@property (assign,nonatomic) char showsMessagePreview;                                //@synthesize showsMessagePreview=_showsMessagePreview - In the implementation block
@property (nonatomic,copy) NSString * bulletinVersionID;                              //@synthesize bulletinVersionID=_bulletinVersionID - In the implementation block
@property (nonatomic,retain) NSDate * expirationDate;                                 //@synthesize expirationDate=_expirationDate - In the implementation block
@property (assign,nonatomic) unsigned expirationEvents;                               //@synthesize expirationEvents=_expirationEvents - In the implementation block
@property (nonatomic,copy) BBAction * expireAction; 
@property (nonatomic,retain) BBObserver * observer;                                   //@synthesize observer=_observer - In the implementation block
@property (assign,nonatomic) unsigned realertCount_deprecated; 
@property (nonatomic,copy) NSSet * alertSuppressionAppIDs_deprecated; 
@property (nonatomic,retain) NSMutableArray * lifeAssertions;                         //@synthesize lifeAssertions=_lifeAssertions - In the implementation block
+(void)killSounds;
+(void)removeBulletinFromCache:(id)arg1 ;
+(id)copyCachedBulletinWithBulletinID:(id)arg1 ;
+(void)addBulletinToCache:(id)arg1 ;
+(id)bulletinWithBulletin:(id)arg1 ;
-(/*^block*/id)defaultActionBlockWithOrigin:(int)arg1 canBypassPinLock:(char*)arg2 requiresUnlock:(char*)arg3 shouldDeactivateAwayController:(char*)arg4 suitabilityFilter:(/*^block*/id)arg5 ;
-(/*^block*/id)defaultActionBlockWithOrigin:(int)arg1 ;
-(/*^block*/id)actionBlockForButton:(id)arg1 withOrigin:(int)arg2 ;
-(char)playSound;
-(void)killSound;
-(/*^block*/id)defaultActionBlock;
-(/*^block*/id)actionBlockForButton:(id)arg1 ;
-(BBAction *)defaultAction;
-(NSDate *)endDate;
-(void)setEndDate:(NSDate *)arg1 ;
-(NSMutableDictionary *)actions;
-(void)setActions:(NSMutableDictionary *)arg1 ;
-(void)setAttachments:(BBAttachments *)arg1 ;
-(NSDate *)expirationDate;
-(void)setExpirationDate:(NSDate *)arg1 ;
-(void)setButtons:(NSArray *)arg1 ;
-(int)accessoryStyle;
-(void)setAccessoryStyle:(int)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(void)setTitle:(NSString *)arg1 ;
-(void)setTimeZone:(NSTimeZone *)arg1 ;
-(NSDate *)date;
-(NSDictionary *)context;
-(NSString *)title;
-(void)setContext:(NSDictionary *)arg1 ;
-(NSString *)section;
-(void)setDate:(NSDate *)arg1 ;
-(void)setSubtitle:(NSString *)arg1 ;
-(NSString *)subtitle;
-(NSTimeZone *)timeZone;
-(BBContent *)content;
-(void)setMessage:(NSString *)arg1 ;
-(NSArray *)buttons;
-(NSString *)message;
-(void)setSection:(NSString *)arg1 ;
-(void)setBulletinID:(NSString *)arg1 ;
-(NSString *)bulletinID;
-(NSMutableArray *)lifeAssertions;
-(void)setLifeAssertions:(NSMutableArray *)arg1 ;
-(void)_fillOutCopy:(id)arg1 withZone:(NSZone*)arg2 ;
-(NSString *)sectionID;
-(void)setSectionID:(NSString *)arg1 ;
-(unsigned)numberOfAdditionalAttachments;
-(unsigned)numberOfAdditionalAttachmentsOfType:(int)arg1 ;
-(id)attachmentsCreatingIfNecessary:(char)arg1 ;
-(id)_actionKeyForButtonIndex:(unsigned)arg1 ;
-(/*^block*/id)responseSendBlock;
-(id)_responseForActionKey:(id)arg1 ;
-(BBAction *)expireAction;
-(void)deliverResponse:(id)arg1 ;
-(NSSet *)subsectionIDs;
-(void)setSubsectionIDs:(NSSet *)arg1 ;
-(NSString *)publisherBulletinID;
-(void)setPublisherBulletinID:(NSString *)arg1 ;
-(int)addressBookRecordID;
-(void)setAddressBookRecordID:(int)arg1 ;
-(int)sectionSubtype;
-(void)setSectionSubtype:(int)arg1 ;
-(char)showsMessagePreview;
-(void)setShowsMessagePreview:(char)arg1 ;
-(BBContent *)modalAlertContent;
-(void)setModalAlertContent:(BBContent *)arg1 ;
-(NSDate *)recencyDate;
-(void)setRecencyDate:(NSDate *)arg1 ;
-(int)dateFormatStyle;
-(void)setDateFormatStyle:(int)arg1 ;
-(char)dateIsAllDay;
-(void)setDateIsAllDay:(char)arg1 ;
-(char)clearable;
-(void)setClearable:(char)arg1 ;
-(BBSound *)sound;
-(void)setSound:(BBSound *)arg1 ;
-(NSString *)unlockActionLabelOverride;
-(void)setUnlockActionLabelOverride:(NSString *)arg1 ;
-(unsigned)expirationEvents;
-(void)setExpirationEvents:(unsigned)arg1 ;
-(NSSet *)alertSuppressionContexts;
-(void)setAlertSuppressionContexts:(NSSet *)arg1 ;
-(NSDate *)lastInterruptDate;
-(void)setLastInterruptDate:(NSDate *)arg1 ;
-(NSString *)bulletinVersionID;
-(void)setBulletinVersionID:(NSString *)arg1 ;
-(unsigned)realertCount_deprecated;
-(void)setRealertCount_deprecated:(unsigned)arg1 ;
-(NSSet *)alertSuppressionAppIDs_deprecated;
-(void)setAlertSuppressionAppIDs_deprecated:(NSSet *)arg1 ;
-(int)primaryAttachmentType;
-(void)setDefaultAction:(BBAction *)arg1 ;
-(BBAction *)alternateAction;
-(void)setAlternateAction:(BBAction *)arg1 ;
-(BBAction *)acknowledgeAction;
-(void)setAcknowledgeAction:(BBAction *)arg1 ;
-(void)setExpireAction:(BBAction *)arg1 ;
-(id)responseForDefaultAction;
-(id)responseForAcknowledgeAction;
-(id)responseForButtonActionAtIndex:(unsigned)arg1 ;
-(id)responseForExpireAction;
-(void)addLifeAssertion:(id)arg1 ;
-(char)expiresOnPublisherDeath;
-(void)setExpiresOnPublisherDeath:(char)arg1 ;
-(unsigned)realertCount;
-(NSString *)sectionDisplayName;
-(NSData *)sectionIconData;
-(char)showsSubtitle;
-(unsigned)messageNumberOfLines;
-(char)usesVariableLayout;
-(char)orderSectionUsingRecencyDate;
-(char)showsDateInFloatingLockScreenAlert;
-(NSString *)missedBannerDescriptionFormat;
-(NSString *)fullUnlockActionLabel;
-(NSString *)unlockActionLabel;
-(NSSet *)alertSuppressionAppIDs;
-(char)coalescesWhenLocked;
-(char)suppressesMessageForPrivacy;
-(char)inertWhenLocked;
-(char)preservesUnlockActionCase;
-(char)bannerShowsSubtitle;
-(char)visuallyIndicatesWhenDateIsInFuture;
-(unsigned)subtypePriority;
-(int)iPodOutAlertType;
-(char)sectionDisplaysCriticalBulletins;
-(id)composedAttachmentImageForKey:(id)arg1 withObserver:(id)arg2 ;
-(CGSize)composedAttachmentImageSizeForKey:(id)arg1 withObserver:(id)arg2 ;
-(id)composedAttachmentImageForKey:(id)arg1 ;
-(CGSize)composedAttachmentImageSizeForKey:(id)arg1 ;
-(id)composedAttachmentImageWithObserver:(id)arg1 ;
-(CGSize)composedAttachmentImageSizeWithObserver:(id)arg1 ;
-(id)composedAttachmentImage;
-(CGSize)composedAttachmentImageSize;
-(BBObserver *)observer;
-(void)setObserver:(BBObserver *)arg1 ;
-(NSString *)topic;
-(BBAttachments *)attachments;
-(void)setRecordID:(NSString *)arg1 ;
-(NSString *)recordID;
-(id)init;
-(void)dealloc;
-(id)copyWithZone:(NSZone*)arg1 ;
-(id)description;
-(void)setContent:(BBContent *)arg1 ;
@end


@interface BBContent : NSObject <NSCopying, NSCoding> {

	NSString* _title;
	NSString* _subtitle;
	NSString* _message;

}

@property (nonatomic,copy) NSString * title;                 //@synthesize title=_title - In the implementation block
@property (nonatomic,copy) NSString * subtitle;              //@synthesize subtitle=_subtitle - In the implementation block
@property (nonatomic,copy) NSString * message;               //@synthesize message=_message - In the implementation block
+(id)contentWithTitle:(id)arg1 subtitle:(id)arg2 message:(id)arg3 ;
-(id)initWithCoder:(id)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(void)setTitle:(NSString *)arg1 ;
-(NSString *)title;
-(void)setSubtitle:(NSString *)arg1 ;
-(NSString *)subtitle;
-(void)setMessage:(NSString *)arg1 ;
-(NSString *)message;
-(char)isEqualToContent:(id)arg1 ;
-(void)dealloc;
-(id)copyWithZone:(NSZone*)arg1 ;
-(id)description;
@end


@interface SBApplicationController : NSObject { //Incomplete.
}
+(id)sharedInstance;
-(id)allApplications;
@end

@interface SBApplication : NSObject {
}
-(id)displayName;
-(id)bundleIdentifier;
@end
