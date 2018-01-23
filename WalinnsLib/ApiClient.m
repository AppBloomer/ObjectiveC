//
//  ApiClient.m
//  Amplitude-iOS
//
//  Created by Walinns Innovation on 13/12/17.
//

#import "ApiClient.h"
#import "UserDefaultsHelper.h"

@interface ApiClient()
@end

@implementation ApiClient


+(void) pushedData:(NSDictionary*) requesData :(NSString *) flag{
    NSError *error;
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSString *project_token = [UserDefaultsHelper getStringForKey:@"project_token"];
    NSString *str =  @"http://ec2-18-218-53-112.us-east-2.compute.amazonaws.com:8080/";
    str = [str stringByAppendingString:flag];
    NSURL *urll = [NSURL URLWithString:str];
    NSLog(@"Final URL =%@", urll);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urll
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:project_token forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requesData options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"The response is - %@",responseDictionary);
            if(flag == @"devices"){
            [UserDefaultsHelper setStringForKey:@"authenticated" :@"device"];
            }
        }
        else
        {
            NSLog(@"Errorrrrrr = %@" , error);
        }
    }];
    
    [postDataTask resume];
}

@end

