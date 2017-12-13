//
//  WalDeviceInfo.h
//  Amplitude-iOS
//
//  Created by Walinns Innovation on 13/12/17.
//

#import <Foundation/Foundation.h>

@interface WalDeviceInfo : NSObject

-(id) init;
@property (readonly) NSString *appVersion;
@property (readonly) NSString *osName;
@property (readonly) NSString *osVersion;
@property (readonly) NSString *manufacturer;
@property (readonly) NSString *model;
@property (readonly) NSString *carrier;
@property (readonly) NSString *screenDpi;
@property (readonly) NSString *connectivity;
@property (readonly) NSString *screenHeight;
@property (readonly) NSString *screenWidth;
@property (readonly) NSString *language;
@property (readonly) NSString *country;
@property (readonly) NSString *advertiserID;
@property (readonly) NSString *vendorID;


+(NSString*) generateUUID;

@end
