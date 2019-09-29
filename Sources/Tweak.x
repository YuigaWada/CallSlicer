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


static void sliceNotification() //called on SpringBoard.
{
    if(isOnLockscreen)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            fakeNotification(@"jp.naver.line", @"You are receiving a Call!");
        });
    }
}





//-MARK: For CFNotificationCenter

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




//-MARK: SpringBoard
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    %orig;
}
%end

%hook AppDelegate

%new
-(id)init {
    NSLog(@"AppDeleagte init");
    LINE = self;
    
    return self;
}

%end


%hook SBDashBoardViewController

-(void)viewWillAppear:(BOOL)animated {
    %orig;
    
    isOnLockscreen = !self.authenticated;
    NSLog(@"isOnLockscreen: %d", isOnLockscreen);
    
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
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.yuigawada.calllslicer/push-notification", nil, nil, true);
    %orig;
}

%end


//-MARK: BulletinBoard
%hook BBServer

- (void)publishBulletin:(BBBulletin *)bulletin destinations:(NSUInteger)destinations
{
    %orig;
    
    //Debug
    BBSound *sound = bulletin.sound;
    NSLog(@"BBServer publishBulletin\nTitle: %@\nSubtitle: %@\nMessage: %@\nBulletin: %@\ndestinations: %@", bulletin.title, bulletin.subtitle, bulletin.message, bulletin, @(destinations).stringValue);
    NSLog(@"BBSound: %@, \nVibration Pattern: %@ \nVibration Identifier: %@", sound, [sound vibrationPattern], [sound vibrationIdentifier]);
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
    NSString *processName = [NSProcessInfo processInfo].processName;
    bool isSpringboard = [@"SpringBoard" isEqualToString:processName];
    
    if (isSpringboard) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)sliceNotification,
                                        (CFStringRef)@"com.yuigawada.calllslicer/push-notification",
                                        NULL,
                                        (CFNotificationSuspensionBehavior)kNilOptions);
        
        
        
        //In order to get lockscreen info.
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
