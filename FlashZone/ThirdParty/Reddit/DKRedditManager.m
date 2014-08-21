//
//  DKRedditManager.m
//  FlashZone
//
//  Created by Dan Kwon on 8/21/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "DKRedditManager.h"
#import "AFNetworking.h"

#define kRedditUrl @"http://www.reddit.com/"

DKRedditManager *sharedRedditMgr = nil;

@implementation DKRedditManager
@synthesize modhash;
@synthesize lastLoginTime;


+ (id)sharedRedditManager
{
	if (!sharedRedditMgr){
		sharedRedditMgr = [[self alloc] init];
		sharedRedditMgr.modhash = @"";
	}
	
	return sharedRedditMgr;
}

- (void)dealloc
{
	self.modhash = nil;
	self.lastLoginTime = nil;
}


- (BOOL)isLoggedIn
{
    return lastLoginTime != nil;
}

- (BOOL)isLoggingIn
{
    return isLoggingIn;
}

- (void)loginWithUsername:(NSString *)aUsername password:(NSString *)aPassword completion:(void (^)(id result, NSError *error))completionHandler
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    
    
    self.lastLoginTime = nil;
    
    if (!aUsername || !aPassword || ![aUsername length] || ![aPassword length]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RedditDidFinishLoggingInNotification" object:nil];
        return;
    }
	
	isLoggingIn = YES;
	
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kRedditUrl]];
    
    [manager POST:@"/api/login"
       parameters:@{@"rem":@"on", @"passwd":aPassword, @"user":aUsername, @"api_type":@"json"}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              completionHandler(responseObject, nil);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              completionHandler(nil, error);
              
          }];
    
	
}

- (void)fetchSubreddits:(void (^)(id result, NSError *error))completionHandler;
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kRedditUrl]];
    
    [manager GET:@"/reddits/mine.json"
      parameters:@{@"limit":@"500"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *response = (NSDictionary *)responseObject;
             completionHandler(response, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             completionHandler(nil, error);
         }];
    
}






@end
