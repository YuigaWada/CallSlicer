#import "Tweak.h"

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

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

//cf. http://iphonedevwiki.net/index.php/CFNotificationCenter
static bool distributedCenterIsAvailable()
{
    void *handle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
    if (handle) {
        return dlsym(handle, "CFNotificationCenterGetDistributedCenter"); // Available.
    }
    
    return false;
}




static bool isOnLockscreen = true;
static NSString *targetSectionID = @"jp.naver.line";
static bool isBeingLocked = true;

HBPreferences *preferences;
BOOL enabled = true;
//NSString *message;

static bool isConnected() {
    id naverLine = [UIApplication sharedApplication];
    
    NSLog(@"LINE instance: \n%@", naverLine);
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = naverLine;
        [session activateSession];
        
        NSLog(@"WCSession is supported.");
        return session.paired;
    }
    return true; //For debug
}

static bool isMuted() { //Must be called on SpringBoard.
    //    NSLog(@"SBMediaController sharedInstance: %@, \nisRingerMuted:%d",[%c(SBMediaController) sharedInstance], [[%c(SBMediaController) sharedInstance] isRingerMuted]);
    return [[%c(SBMediaController) sharedInstance] isRingerMuted];
}

static BBSound *getBBSound()
{
    TLAlertConfiguration *toneAlertConfig = [[%c(TLAlertConfiguration) alloc] initWithType: 1];
    [toneAlertConfig setShouldRepeat:false];
    
    BBSound *sound = [[%c(BBSound) alloc] initWithToneAlertConfiguration: toneAlertConfig];
    return sound;
}

//Thanks for Nepeta. (Notifica)
static id bbServer = nil;
static void fakeNotification(NSString *sectionID, NSString *message) {
    BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];
    NSDate *date = [NSDate date];
    
    bulletin.title = @"CallSlicer";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    
    
    bulletin.sound = getBBSound(); // If bulletin.sound is not set, AppleWatch's vibration doesn't work.
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    
    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
        });
    } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4];
        });
    }
    
    
}


static void sliceNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  //called on SpringBoard.
{
    NSLog(@"sliceNotification");
    if(enabled && isOnLockscreen && isMuted())
    {
        NSLog(@"userInfo: %@",userInfo);
        
        //メモリ管理をARCに委譲するCFBridgingReleaseを呼ぶとなぜかクラッシュするので、コード上でメモリ管理を行うよう__bridgeキャストを用いた。
        //(CFBridgingReleaseは参照カウンタを一つ減らす)
        //なお、メモリの開放については、"多分"reportNewIncomingCallWithUUID内のCFReleaseで解放できてるはず
        
        NSDictionary *reciever = (NSDictionary *)(__bridge userInfo);
        
        NSString *target = reciever[@"targetSectionID"];
        NSString *displayName = reciever[@"displayName"];
        NSLog(@"target: %@\ndisplayName:%@", target, displayName);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            fakeNotification(target,
                             [NSString stringWithFormat:@"You are receiving a Call from %@!", displayName]);
        });
    }
    
    NSLog(@"sliceNotification - end");
}





//-MARK: For CFNotificationCenter

static void displayStatus(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    isOnLockscreen = true;
    NSLog(@"displayStatus - isOnLockscreen: %d", isOnLockscreen);
}

static void lockstate(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    isOnLockscreen = isBeingLocked ? isBeingLocked : !isOnLockscreen;
    isBeingLocked = false;
    NSLog(@"lockstate - isOnLockscreen: %d", isOnLockscreen);
}

static void lockcomplete(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    isBeingLocked = true;
}
                             
                             




//-MARK: SpringBoard
%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
}

%end


%hook SBDashBoardViewController

-(void)viewWillAppear:(BOOL)animated {
    %orig;
    
    isOnLockscreen = !self.authenticated;
    NSLog(@"viewWillAppear - isOnLockscreen: %d", isOnLockscreen);
    
    //Debug
    //    id ins = [%c(BCBatteryDeviceController) sharedInstance];
    //
    //    NSLog(@"BCBatteryDevice:\n %@", ins);
    //    NSLog(@"BCBatteryDevice:\n %@", ((BCBatteryDeviceController *)ins).connectedDevices);
}

%end


//-MARK: CX
%hook CXProvider

- (void)reportNewIncomingCallWithUUID:(id)arg1 update:(id)arg2 completion:(id /* block */)arg3 {
    
    bool needSlicing = isConnected();
    NSLog(@"AppleWarch: %d",needSlicing);
    
    //    NSArray *sender = @[targetSectionID,@"displayName"];
    
    if(distributedCenterIsAvailable())
    {
        CXCallUpdate *callInfo = (CXCallUpdate *)arg2;
        NSString *displayName = callInfo.localizedCallerName;
        
        CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(dictionary, @"targetSectionID", targetSectionID);
        CFDictionaryAddValue(dictionary, @"displayName", displayName);
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)@"com.yuigawada.callslicer/push-notification", nil, dictionary, true);
        CFRelease(dictionary);
    }
    %orig;
}

%end


//-MARK: BulletinBoard
%hook BBServer

- (void)publishBulletin:(BBBulletin *)bulletin destinations:(NSUInteger)destinations
{
    BBSound *sound = bulletin.sound;
    bool hasSound = sound != nil;
    bool isLINE = [bulletin.sectionID isEqualToString: targetSectionID];
    if(!hasSound && isLINE && !enabled) { return; }
    
    %orig;
    
    //Debug
    NSLog(@"BBServer publishBulletin\nTitle: %@\nSubtitle: %@\nMessage: %@\nBulletin: %@\ndestinations: %@", bulletin.title, bulletin.subtitle, bulletin.message, bulletin, @(destinations).stringValue);
    NSLog(@"BBSound: %@, \nVibration Pattern: %@ \nVibration Identifier: %@", sound, [sound vibrationPattern], [sound vibrationIdentifier]);
    NSLog(@"hasSound: %d, \nisLINE: %d, \nbulletin.sectionID: %@, \ntargetSectionID: %@", hasSound, isLINE, bulletin.sectionID, targetSectionID);
}

%end

%hook BBServer

- (id)init {
    id me = %orig;
    bbServer = me;
    return me;
}

-(id)initWithQueue:(id)arg1 {
    bbServer = %orig;
    return bbServer;
}

-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    bbServer = %orig;
    return bbServer;
}

- (void)dealloc {
    if (bbServer == self) {
        bbServer = nil;
    }
    %orig;
}

%end


//-MARK: init

%ctor
{
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.yuigawada.callslicer"];
    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    //    [preferences registerObject:&message default:@"You are receiving a Call!" forKey:@"Message"];
    
    NSString *processName = [NSProcessInfo processInfo].processName;
    bool isSpringboard = [@"SpringBoard" isEqualToString:processName];
    if (isSpringboard && enabled) {
        
        //cf. http://iphonedevwiki.net/index.php/CFNotificationCenter
        if(distributedCenterIsAvailable())
        {
            NSLog(@"DistributedCenter is available.");
            
            CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                            NULL,
                                            sliceNotification,
                                            (CFStringRef)@"com.yuigawada.callslicer/push-notification",
                                            NULL,
                                            CFNotificationSuspensionBehaviorDeliverImmediately);
        }
        
        
        
        
        
        //For getting lockscreen info.
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        displayStatus,
                                        CFSTR("com.apple.iokit.hid.displayStatus"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        //Called when the device is being Locked or Unlocked.
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        lockstate,
                                        CFSTR("com.apple.springboard.lockstate"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        //Called ONLY when the device is being Locked.
        //(But lockcomplete is always called before lockstate being called.)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        lockcomplete,
                                        CFSTR("com.apple.springboard.lockcomplete"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
    }
    else {
        targetSectionID = [[NSBundle mainBundle] bundleIdentifier];
        NSLog(@"targetSectionID: %@",targetSectionID);
    }
    
    
    NSLog(@"Enabled: %d", enabled);
}
