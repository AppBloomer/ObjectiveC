//
//  WalinnsUtils.h
//  Amplitude-iOS
//
//  Created by Walinns Innovation on 11/12/17.
//

#import <Foundation/Foundation.h>

@interface WalinnsUtils : NSObject

+ (NSString*) generateUUID;

+ (id) makeJSONSerializable:(id) obj;

+ (BOOL) isEmptyString:(NSString*) str;

+ (NSDictionary*) validateGroups:(NSDictionary*) obj;

+ (NSString*) platformDataDirectory;
+ (NSString *)getUTCFormateDate:(NSDate *)localDate;
+(NSString*)sessionDuration:(NSDate *)startDate;




@end
