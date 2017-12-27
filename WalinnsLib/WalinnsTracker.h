//
//  WalinnsTracker.h
//  WalinnsLib
//
//  Created by Walinns Innovation on 08/12/17.
//  Copyright © 2017 Walinns Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
 

@interface WalinnsTracker : NSObject

@property NSString *url;

@property (nonatomic, strong, readonly) NSString *apiKey;
@property (nonatomic, strong, readonly) NSString *deviceId;
@property (nonatomic, strong, readonly) NSString *instanceName;


+ (WalinnsTracker *)instance;

+ (WalinnsTracker *)instanceWithName:(NSString*) instanceName;

- (void)initializeApiKey:(NSString*) apiKey;

- (void)setDeviceId:(NSString*) deviceId;

- (NSString*)getDeviceId;

- (void)regenerateDeviceId;

- (void)trackEvent:(NSString *)event_name:(NSString *)event_type;
-(void)sendPush_Token:(NSString *)push_token;

@end
