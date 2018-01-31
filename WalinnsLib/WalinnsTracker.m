//
//  WalinnsTracker.m
//  WalinnsLib
//
//  Created by Walinns Innovation on 08/12/17.
//  Copyright © 2017 Walinns Innovation. All rights reserved.
//
#ifndef AMPLITUDE_ERROR
#if AMPLITUDE_LOG_ERRORS
#   define WALINNS_ERROR(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define WALINNS_ERROR(...)
#endif
#endif

#import "WalinnsTracker.h"
#import "WalinnsUtils.h"
#import "WalDefaultConst.h"
#import "AMPARCMacros.h"
#import "WalDeviceInfo.h"
#import "ApiClient.h"
#import "UserDefaultsHelper.h"


@interface WalinnsTracker()

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, strong) NSOperationQueue *backgroundQueue;
@property (nonatomic, strong) NSOperationQueue *initializerQueue;


@end

 

@implementation WalinnsTracker

BOOL _inForeground;
WalDeviceInfo *_deviceInfo;
BOOL _useAdvertisingIdForDeviceId;
static NSString *const BACKGROUND_QUEUE_NAME = @"BACKGROUND";
NSDate *date;
NSString *gender = @"NA";
NSString *bday = @"NA";

 
+ (WalinnsTracker *)instance {
    return [WalinnsTracker instanceWithName:nil];
}
+ (WalinnsTracker *)instanceWithName:(NSString*)instanceName {
    static NSMutableDictionary *_instances = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instances = [[NSMutableDictionary alloc] init];
    });
    
    // compiler wants explicit key nil check even though AMPUtils isEmptyString already has one
    if (instanceName == nil || [WalinnsUtils isEmptyString:instanceName]) {
        instanceName = walDefaultInstance;
    }
    instanceName = [instanceName lowercaseString];
    
    WalinnsTracker *client = nil;
    @synchronized(_instances) {
        client = [_instances objectForKey:instanceName];
        if (client == nil) {
            client = [[self alloc] initWithInstanceName:instanceName];
            [_instances setObject:client forKey:instanceName];
            SAFE_ARC_RELEASE(client);
        }
    }
    
    return client;
}

- (id)init
{
    return [self initWithInstanceName:nil];
}

- (id)initWithInstanceName:(NSString*) instanceName
{
    if ([WalinnsUtils isEmptyString:instanceName]) {
        instanceName = walDefaultInstance;
    }
    instanceName = [instanceName lowercaseString];
    
    if ((self = [super init])) {
        _instanceName = SAFE_ARC_RETAIN(instanceName);
        _initializerQueue = [[NSOperationQueue alloc] init];
        _backgroundQueue = [[NSOperationQueue alloc] init];
        // Force method calls to happen in FIFO order by only allowing 1 concurrent operation
        [_backgroundQueue setMaxConcurrentOperationCount:1];
        // Ensure initialize finishes running asynchronously before other calls are run
        [_backgroundQueue setSuspended:YES];
        // Name the queue so runOnBackgroundQueue can tell which queue an operation is running
        _backgroundQueue.name = BACKGROUND_QUEUE_NAME;
        
        [_initializerQueue addOperationWithBlock:^{
            _deviceInfo = [[WalDeviceInfo alloc] init];
            NSLog(@"Device_info Datas %@" , _deviceInfo.appVersion);
            [self logEvent];
            [_backgroundQueue setSuspended:NO];

        }];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
 
    }
    return self;
}
- (void)initializeApiKey:(NSString *)apiKey{
    NSLog(@"Api key = %@" , apiKey);
 //   id object = [[WalinnsTracker alloc] init];

    [UserDefaultsHelper setStringForKey :apiKey : @"project_token" ];
   
}

-(void)appWillResignActive:(NSNotification*)note
{
    NSLog(@"WalinnsTracker app is bg/fg =%@", date);
    NSDate *datee =[NSDate date];
    NSString *duration = [WalinnsUtils sessionDuration: date];
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:_deviceInfo.vendorID forKey:@"device_id"];
    [event setValue:[WalinnsUtils getUTCFormateDate:date] forKey:@"start_time"];
    [event setValue:[WalinnsUtils getUTCFormateDate:datee] forKey:@"end_time"];
    [event setValue:duration forKey:@"session_length"];
    NSLog(@"WalinnsTracker app is bg/fg =%@", event);
    [self activeState:@"no"];
    [self track_uninstall];
    [ApiClient pushedData:event :@"session"];

}
-(void)track_uninstall{
    date = [NSDate date];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue: _deviceInfo.vendorID forKey:@"device_id"];
    [event setValue:[UserDefaultsHelper getStringForKey:@"push_token"] forKey:@"push_token"];
    [event setValue:bundleIdentifier forKey:@"package_name"];
    [event setValue:[WalinnsUtils getUTCFormateDate:date] forKey:@"date_time"];
    NSLog(@"WalinnsTacker uninstall event: =%@", event);
    if([[UserDefaultsHelper getStringForKey:@"device"]  isEqual: @"authenticated"]){
        [ApiClient pushedData:event :@"uninstallcount"];
    }
}
- (void) dealloc {
    //[self removeObservers];
    
    // Release properties
    SAFE_ARC_RELEASE(_apiKey);
    SAFE_ARC_RELEASE(_backgroundQueue);
    SAFE_ARC_RELEASE(_deviceId);
    
    
    // Release instance variables
    SAFE_ARC_RELEASE(_deviceInfo);
    SAFE_ARC_RELEASE(_initializerQueue);
    SAFE_ARC_RELEASE(_instanceName);
    
    
    SAFE_ARC_SUPER_DEALLOC();
}
- (void) logEvent{
    NSLog(@"log event method");
    date = [NSDate date];
    NSString *uuid = [[NSUUID UUID] UUIDString];

    NSLog(@"Device id =%@",uuid);
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:_deviceInfo.vendorID forKey:@"device_id"];
    [event setValue:_deviceInfo.appVersion forKey:@"app_version"];
    [event setValue:_deviceInfo.osName forKey:@"os_name"];
    [event setValue:_deviceInfo.osVersion forKey:@"os_version"];
    [event setValue:_deviceInfo.model forKey:@"device_model"];
   // [event setValue:_deviceInfo.manufacturer forKey:@"device_manufacturer"];
    [event setValue:_deviceInfo.carrier forKey:@"carrier"];
    [event setValue:_deviceInfo.country forKey:@"country"];
    [event setValue:_deviceInfo.language forKey:@"language"];
    [event setValue:_deviceInfo.connectivity forKey:@"connectivity"];
    [event setValue:@"false" forKey:@"play_service"];
    [event setValue:@"false" forKey:@"bluetooth"];
    [event setValue:_deviceInfo.screenDpi forKey:@"screen_dpi"];
    [event setValue:_deviceInfo.screenHeight forKey:@"screen_height"];
    [event setValue:_deviceInfo.screenWidth forKey:@"screen_width"];
    [event setValue:@"example_ios@gmail.com" forKey:@"email"];
    [event setValue:@"male" forKey:@"gender"];
    [event setValue:@"25" forKey:@"age"];
    [event setValue:[WalinnsUtils getUTCFormateDate:date] forKey:@"date_time"];
    NSLog(@"JsonObject Deviceinfo =%@",event);
    [ApiClient pushedData:event :@"devices"];
    [self activeState:@"yes"];
    
}

+ (NSString*)getDeviceId {
    return [[WalinnsTracker instance] getDeviceId];
}

- (NSString*) initializeDeviceId
{
    if (_deviceId == nil) {
//        _deviceId = SAFE_ARC_RETAIN([self.dbHelper getValue:DEVICE_ID]);
//        if (![self isValidDeviceId:_deviceId]) {
//            NSString *newDeviceId = SAFE_ARC_RETAIN([self _getDeviceId]);
//            SAFE_ARC_RELEASE(_deviceId);
//            _deviceId = newDeviceId;
//            (void) [self.dbHelper insertOrReplaceKeyValue:DEVICE_ID value:newDeviceId];
        }
    
    return _deviceId;
}
- (NSString*) getDeviceId
{
    return _deviceId;
}
- (NSString*)_getDeviceId
{
    NSString *deviceId = nil;
    if (_useAdvertisingIdForDeviceId) {
        deviceId = _deviceInfo.advertiserID;
    }
    
    // return identifierForVendor
    if (!deviceId) {
        deviceId = _deviceInfo.vendorID;
    }
    
    if (!deviceId) {
        // Otherwise generate random ID
        deviceId = [WalDeviceInfo generateUUID];
    }
    return SAFE_ARC_AUTORELEASE([[NSString alloc] initWithString:deviceId]);
}

- (void)setDeviceId:(NSString*)deviceId
{
    if (![self isValidDeviceId:deviceId]) {
        return;
    }
    
    [self runOnBackgroundQueue:^{
        (void) SAFE_ARC_RETAIN(deviceId);
        SAFE_ARC_RELEASE(_deviceId);
        _deviceId = deviceId;
        NSLog(@"Device id =%@", _deviceId);
        
    }];
}

- (void)regenerateDeviceId
{
    [self runOnBackgroundQueue:^{
        [self setDeviceId:[WalDeviceInfo generateUUID]];
    }];
}
- (BOOL)isValidDeviceId:(NSString*)deviceId
{
    if (deviceId == nil ||
        ![self isArgument:deviceId validType:[NSString class] methodName:@"isValidDeviceId"] ||
        [deviceId isEqualToString:@"e3f5536a141811db40efd6400f1d0a4e"] ||
        [deviceId isEqualToString:@"04bab7ee75b9a58d39b8dc54e8851084"]) {
        return NO;
    }
    NSLog(@"JsonObject Deviceinfo =%@",deviceId);
    return YES;
}
- (BOOL)isArgument:(id) argument validType:(Class) class methodName:(NSString*) methodName
{
    if ([argument isKindOfClass:class]) {
        return YES;
    } else {
        WALINNS_ERROR(@"ERROR: Invalid type argument to method %@, expected %@, received %@, ", methodName, class, [argument class]);
        return NO;
    }
}
/**
 * Run a block in the background. If already in the background, run immediately.
 */
- (BOOL)runOnBackgroundQueue:(void (^)(void))block
{
    if ([[NSOperationQueue currentQueue].name isEqualToString:BACKGROUND_QUEUE_NAME]) {
        NSLog(@"Already running in the background.");
        block();
        return NO;
    } else {
        [_backgroundQueue addOperationWithBlock:block];
        return YES;
    }
}
-(void)trackEvent:(NSString *)event_name :(NSString *)event_type{
    NSLog(@"track event method");
    date = [NSDate date];
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue: _deviceInfo.vendorID forKey:@"device_id"];
    [event setValue:event_name forKey:@"event_name"];
    [event setValue:event_type forKey:@"event_type"];
    [event setValue:[WalinnsUtils getUTCFormateDate:date] forKey:@"date_time"];
    NSLog(@"WalinnsTracker Events Request : =%@", event);
    if([[UserDefaultsHelper getStringForKey:@"device"]  isEqual: @"authenticated"]){
        [ApiClient pushedData:event :@"events"];
    }
}
-(void)activeState:(NSString*)state{
    date = [NSDate date];
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue: _deviceInfo.vendorID forKey:@"device_id"];
    [event setValue:state forKey:@"active_status"];
    [event setValue:[WalinnsUtils getUTCFormateDate:date] forKey:@"date_time"];
    NSLog(@"WalinnsTacker Active state : =%@", event);
    if([[UserDefaultsHelper getStringForKey:@"device"]  isEqual: @"authenticated"]){
        [ApiClient pushedData:event :@"fetchAppUserDetail"];
    }
}
-(void)trackScreen:(NSString *)screen_name{
    date = [NSDate date];
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue: _deviceInfo.vendorID forKey:@"device_id"];
    [event setValue:screen_name forKey:@"screen_name"];
    [event setValue:[WalinnsUtils getUTCFormateDate:date] forKey:@"date_time"];
    NSLog(@"WalinnsTacker Active state : =%@", event);
     if([[UserDefaultsHelper getStringForKey:@"device"]  isEqual: @"authenticated"]){
         [ApiClient pushedData:event :@"screenView"];
     } 
}
-(void)sendPush_Token:(NSString *)push_token{
    [UserDefaultsHelper setStringForKey:push_token :@"push_token"];
   }

- (void)graphUser:(NSDictionary *)fbGraphUser{
    NSLog(@"Fb user data: %@",fbGraphUser[@"birthday"]);
//    if ([fbGraphUser objectForKey:@"birthday"] != nil) {
//        bday = fbGraphUser[@"birthday"];
//    }
//    if([fbGraphUser objectForKey:@"gender"] != nil){
//        gender =fbGraphUser[@"gender"];
//    }
//    if(bday != nil){
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"dd/MM/YYYY"];
//    NSDate *date = [dateFormat dateFromString:fbGraphUser[@"birthday"]];
//    NSDate* now = [NSDate date];
//    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
//                                       components:NSCalendarUnitYear
//                                       fromDate:date
//                                       toDate:now
//                                       options:0];
//    NSInteger age = [ageComponents year];
//        NSLog(@"Fb user data age: %@ and agecurrent %ld",gender , (long)age);

    
}
 
@end

 

