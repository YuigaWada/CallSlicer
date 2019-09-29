#line 1 "Tweak.x"
#import "Tweak.h"


static dispatch_queue_t getBBServerQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        void *handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t *pointer = (dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) {
                queue = *pointer;
            }
            dlclose(handle);
        }
    });
    return queue;
}




static id LINE = nil;
static bool isOnLockscreen = true;

static bool isConnected() {
    NSLog(@"%@", LINE);

    if(LINE == nil)
    {
        NSLog(@"LINE is nil.");
        return false;
    }
    
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = LINE;
        [session activateSession];
        
        NSLog(@"WCSession is supported.");
        return session.paired && session.reachable;
    }
    return false;
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class BBAction; @class BBSound; @class AppDelegate; @class SBDashBoardViewController; @class BBBulletin; @class SpringBoard; @class CXProvider; @class BBServer; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static AppDelegate* _logos_method$_ungrouped$AppDelegate$init(_LOGOS_SELF_TYPE_INIT AppDelegate*, SEL) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$SBDashBoardViewController$viewWillAppear$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBDashBoardViewController$viewWillAppear$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$_ungrouped$CXProvider$reportNewIncomingCallWithUUID$update$completion$)(_LOGOS_SELF_TYPE_NORMAL CXProvider* _LOGOS_SELF_CONST, SEL, id, id, id ); static void _logos_method$_ungrouped$CXProvider$reportNewIncomingCallWithUUID$update$completion$(_LOGOS_SELF_TYPE_NORMAL CXProvider* _LOGOS_SELF_CONST, SEL, id, id, id ); static void (*_logos_orig$_ungrouped$BBServer$publishBulletin$destinations$)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, NSUInteger); static void _logos_method$_ungrouped$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, NSUInteger); static BBServer* (*_logos_orig$_ungrouped$BBServer$init)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$init(_LOGOS_SELF_TYPE_INIT BBServer*, SEL) _LOGOS_RETURN_RETAINED; static BBServer* (*_logos_orig$_ungrouped$BBServer$initWithQueue$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* (*_logos_orig$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id, id, id, id, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id, id, id, id, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$BBServer$dealloc)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$BBServer$dealloc(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBSound(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBSound"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBAction(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBAction"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBBulletin(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBBulletin"); } return _klass; }
#line 46 "Tweak.x"
static BBSound *getBBSound()
{
    BBSound *sound = [[_logos_static_class_lookup$BBSound() alloc] initWithToneAlert:1 toneIdentifier:nil vibrationIdentifier:@"Accent"];
    [sound setRepeats:false];
    
    return sound;
}


static id bbServer = nil;
static void fakeNotification(NSString *sectionID, NSString *message) {
    BBBulletin *bulletin = [[_logos_static_class_lookup$BBBulletin() alloc] init];
    NSDate *date = [NSDate date];
    
    bulletin.title = @"CallSlicer";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    
    
    bulletin.sound = getBBSound(); 
    bulletin.defaultAction = [_logos_static_class_lookup$BBAction() actionWithLaunchBundleID:sectionID callblock:nil];
    
    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
        });
    } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4];
        });
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [bulletin.sound release];
        NSLog(@"release sound");
    });
}


static void sliceNotification() 
{
    if(isOnLockscreen)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            fakeNotification(@"jp.naver.line", @"You are receiving a Call!");
        });
    }
}







static void displayStatus(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    isOnLockscreen = true;
    NSLog(@"isOnLockscreen: %d", isOnLockscreen);
}

static void lockstate(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    isOnLockscreen = false;
    NSLog(@"isOnLockscreen: %d", isOnLockscreen);
}






static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
}





static AppDelegate* _logos_method$_ungrouped$AppDelegate$init(_LOGOS_SELF_TYPE_INIT AppDelegate* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    NSLog(@"AppDeleagte init");
    LINE = self;
    
    return self;
}






static void _logos_method$_ungrouped$SBDashBoardViewController$viewWillAppear$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL animated) {
    _logos_orig$_ungrouped$SBDashBoardViewController$viewWillAppear$(self, _cmd, animated);
    
    isOnLockscreen = !self.authenticated;
    NSLog(@"isOnLockscreen: %d", isOnLockscreen);
    
    




}







static void _logos_method$_ungrouped$CXProvider$reportNewIncomingCallWithUUID$update$completion$(_LOGOS_SELF_TYPE_NORMAL CXProvider* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2, id  arg3) {
    
    bool needSlicing = isConnected();
    NSLog(@"AppleWarch: %d",needSlicing);
    
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.yuigawada.calllslicer/push-notification", nil, nil, true);
    _logos_orig$_ungrouped$CXProvider$reportNewIncomingCallWithUUID$update$completion$(self, _cmd, arg1, arg2, arg3);
}








static void _logos_method$_ungrouped$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BBBulletin * bulletin, NSUInteger destinations) {
    _logos_orig$_ungrouped$BBServer$publishBulletin$destinations$(self, _cmd, bulletin, destinations);
    
    
    BBSound *sound = bulletin.sound;
    NSLog(@"BBServer publishBulletin\nTitle: %@\nSubtitle: %@\nMessage: %@\nBulletin: %@\ndestinations: %@", bulletin.title, bulletin.subtitle, bulletin.message, bulletin, @(destinations).stringValue);
    NSLog(@"BBSound: %@, \nVibration Pattern: %@ \nVibration Identifier: %@", sound, [sound vibrationPattern], [sound vibrationIdentifier]);
}





static BBServer* _logos_method$_ungrouped$BBServer$init(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    id me = _logos_orig$_ungrouped$BBServer$init(self, _cmd);
    bbServer = me;
    return me;
}

static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1) _LOGOS_RETURN_RETAINED {
    bbServer = _logos_orig$_ungrouped$BBServer$initWithQueue$(self, _cmd, arg1);
    return bbServer;
}

static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) _LOGOS_RETURN_RETAINED {
    bbServer = _logos_orig$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(self, _cmd, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
    return bbServer;
}

static void _logos_method$_ungrouped$BBServer$dealloc(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if (bbServer == self) {
        bbServer = nil;
    }
    _logos_orig$_ungrouped$BBServer$dealloc(self, _cmd);
}






static __attribute__((constructor)) void _logosLocalCtor_e96ed478(int __unused argc, char __unused **argv, char __unused **envp)
{
    NSString *processName = [NSProcessInfo processInfo].processName;
    bool isSpringboard = [@"SpringBoard" isEqualToString:processName];
    
    if (isSpringboard) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)sliceNotification,
                                        (CFStringRef)@"com.yuigawada.calllslicer/push-notification",
                                        NULL,
                                        (CFNotificationSuspensionBehavior)kNilOptions);
        
        
        
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        displayStatus,
                                        CFSTR("com.apple.iokit.hid.displayStatus"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        lockstate,
                                        CFSTR("com.apple.springboard.lockstate"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        
    }
    
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);Class _logos_class$_ungrouped$AppDelegate = objc_getClass("AppDelegate"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$AppDelegate, @selector(init), (IMP)&_logos_method$_ungrouped$AppDelegate$init, _typeEncoding); }Class _logos_class$_ungrouped$SBDashBoardViewController = objc_getClass("SBDashBoardViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardViewController, @selector(viewWillAppear:), (IMP)&_logos_method$_ungrouped$SBDashBoardViewController$viewWillAppear$, (IMP*)&_logos_orig$_ungrouped$SBDashBoardViewController$viewWillAppear$);Class _logos_class$_ungrouped$CXProvider = objc_getClass("CXProvider"); MSHookMessageEx(_logos_class$_ungrouped$CXProvider, @selector(reportNewIncomingCallWithUUID:update:completion:), (IMP)&_logos_method$_ungrouped$CXProvider$reportNewIncomingCallWithUUID$update$completion$, (IMP*)&_logos_orig$_ungrouped$CXProvider$reportNewIncomingCallWithUUID$update$completion$);Class _logos_class$_ungrouped$BBServer = objc_getClass("BBServer"); MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(publishBulletin:destinations:), (IMP)&_logos_method$_ungrouped$BBServer$publishBulletin$destinations$, (IMP*)&_logos_orig$_ungrouped$BBServer$publishBulletin$destinations$);MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(init), (IMP)&_logos_method$_ungrouped$BBServer$init, (IMP*)&_logos_orig$_ungrouped$BBServer$init);MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(initWithQueue:), (IMP)&_logos_method$_ungrouped$BBServer$initWithQueue$, (IMP*)&_logos_orig$_ungrouped$BBServer$initWithQueue$);MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(initWithQueue:dataProviderManager:syncService:dismissalSyncCache:observerListener:utilitiesListener:conduitListener:systemStateListener:settingsListener:), (IMP)&_logos_method$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$, (IMP*)&_logos_orig$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$);MSHookMessageEx(_logos_class$_ungrouped$BBServer, sel_registerName("dealloc"), (IMP)&_logos_method$_ungrouped$BBServer$dealloc, (IMP*)&_logos_orig$_ungrouped$BBServer$dealloc);} }
#line 253 "Tweak.x"
