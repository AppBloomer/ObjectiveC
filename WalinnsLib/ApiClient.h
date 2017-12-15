//
//  ApiClient.h
//  Amplitude-iOS
//
//  Created by Walinns Innovation on 13/12/17.
//

#import <Foundation/Foundation.h>

@interface ApiClient : NSObject

@property NSString *url;

+ (void) pushedData:(NSDictionary *) requestData:(NSString *) flag;


@end
