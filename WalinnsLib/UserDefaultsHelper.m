//
//  UserDefaultsHelper.m
//  Amplitude-iOS
//
//  Created by Walinns Innovation on 14/12/17.
//

#import "UserDefaultsHelper.h"

@implementation UserDefaultsHelper
+(NSString*)getStringForKey:(NSString*)key
{
    NSString* val = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults stringForKey:key];
    if (val == NULL) val = @"";
    return val;
}
+(void)setStringForKey:(NSString*)value:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults)
    {
        [standardUserDefaults setObject:value forKey:key];
        [standardUserDefaults synchronize];
    }
}
@end
