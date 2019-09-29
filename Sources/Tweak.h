#import <SpringBoard/SpringBoard.h>
#import <CallKit/CallKit.h>
#import <os/log.h>
#import <objc/runtime.h>
#import "./headers/BulletinBoard/BBBulletin.h"
//#import <BulletinBoard/BBDataProvider.h>
#import <BulletinBoard/BBAction.h>
#import <dlfcn.h>
#import "./headers/BatteryCenter/BCBatteryDeviceController.h"
#import "./headers/ToneLibrary/TLAlertConfiguration.h"

@import WatchConnectivity;


@interface BBServer : NSObject
- (id)_sectionInfoForSectionID:(NSString *)sectionID effective:(BOOL)effective;
- (void)publishBulletin:(BBBulletin *)bulletin destinations:(NSUInteger)dests alwaysToLockScreen:(BOOL)lock;
- (void)publishBulletin:(BBBulletin *)bulletin destinations:(NSUInteger)dests;
@end

@interface SBBannerController : NSObject
+ (id)sharedInstance;

- (id)_bannerContext;
- (void)_replaceIntervalElapsed;
- (void)_dismissIntervalElapsed;
@end

@interface SBBulletinBannerController : NSObject
+ (id)sharedInstance;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(NSUInteger)arg3;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(NSUInteger)arg3 playLightsAndSirens:(BOOL)arg4 withReply:(id)arg5;
@end

@interface BBSound : NSObject
- (id)initWithToneAlert:(long long)arg1;
- (id)initWithToneAlert:(long long)arg1 toneIdentifier:(id)arg2 vibrationIdentifier:(id)arg3;
- (id)initWithToneAlertConfiguration:(id)arg1;
- (void)setRepeats:(bool)arg1;
- (id)vibrationPattern;
- (id)vibrationIdentifier;
@end


@interface BBObserver : NSObject

@end

@interface NCBulletinNotificationSource : NSObject
-(BBObserver*)observer;
@end


@interface SBLockScreenNotificationListController : NSObject

+(id)sharedInstance;
-(void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3 ;
-(void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3 playLightsAndSirens:(BOOL)arg4 withReply:(/*^block*/id)arg5 ;

@end

@interface SBNCNotificationDispatcher : NSObject
-(NCBulletinNotificationSource*)notificationSource;
@end


@interface UIApplication (Notifica)
-(SBNCNotificationDispatcher*)notificationDispatcher;
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 ;

+(id)sharedInstanceIfExists;
-(UIViewController *)lockScreenViewController;

@end



@interface SBDashBoardViewController : UIViewController
@property (assign,getter=isAuthenticated,nonatomic) BOOL authenticated;
@end


@interface SBMediaController : NSObject
+(id)sharedInstance;
-(BOOL)isRingerMuted;
@end
