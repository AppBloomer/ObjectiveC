//
//  UserDefaultsHelper.h
//  Amplitude-iOS
//
//  Created by Walinns Innovation on 14/12/17.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsHelper : NSObject
+(NSString*)getStringForKey:(NSString*)key;
+(void)setStringForKey:(NSString*)value:(NSString*)key;
+(NSDate*)getDateForKey:(NSString*)key;
+(void)setDateForKey:(NSDate*)date:(NSString*)key;

@end
