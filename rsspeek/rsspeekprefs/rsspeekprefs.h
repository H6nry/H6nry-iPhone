#import <UIKit/UIKit.h>

typedef enum PSCellType {
	PSGroupCell,
	PSLinkCell,
	PSLinkListCell,
	PSListItemCell,
	PSTitleValueCell,
	PSSliderCell,
	PSSwitchCell,
	PSStaticTextCell,
	PSEditTextCell,
	PSSegmentCell,
	PSGiantIconCell,
	PSGiantCell,
	PSSecureEditTextCell,
	PSButtonCell,
	PSEditTextViewCell,
} PSCellType;

extern NSString* PSDeletionActionKey;
extern NSString *const PSActionKey; // @"action"

@interface PSSpecifier : NSObject {
@public
	SEL action;
}
@property(retain) NSMutableDictionary* properties;
@property(retain) NSString* name;
@property(retain) id userInfo;
@property(retain) id titleDictionary;
@property(retain) id shortTitleDictionary;
@property(retain) NSArray* values;

+(id)preferenceSpecifierNamed:(NSString*)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
-(id)propertyForKey:(NSString*)key;
-(void)setProperty:(id)property forKey:(NSString*)key;
@end



@interface PSViewController : UIViewController
@end

@interface PSListController : PSViewController{
    NSArray* _specifiers;
}
@property(retain) NSArray* specifiers;
-(NSArray*)loadSpecifiersFromPlistName:(NSString*)plistName target:(id)target;
-(void)addSpecifier:(PSSpecifier*)specifier;
-(void)addSpecifier:(PSSpecifier*)specifier animated:(BOOL)animated;
-(void)addSpecifiersFromArray:(NSArray*)array;
-(void)addSpecifiersFromArray:(NSArray*)array animated:(BOOL)animated;
-(void)insertSpecifier:(PSSpecifier*)specifier atIndex:(int)index;
-(void)insertSpecifier:(PSSpecifier*)specifier atIndex:(int)index animated:(BOOL)animated;
@end

@interface PSEditableListController : PSListController
@end
