//
//  FZWebServices.m
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZWebServices.h"
#import "AFNetworking.h"

#define kBaseUrl @"http://flash-zone.appspot.com/"
#define kSSLBaseUrl @"https://flash-zone.appspot.com/"
#define kPathProfiles @"/api/profiles/"
#define kPathLogin @"/api/login/"
#define kPathUpload @"/api/upload/"
#define kPathFlashTags @"/api/flashtags/"
#define kPathCategoryList @"/api/categorylists/"
#define kPathInterests @"/api/interests/"


@implementation FZWebServices

+ (FZWebServices *)sharedInstance
{
    static FZWebServices *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[FZWebServices alloc] init];
        
    });
    
    return shared;
}


// Profile
- (void)fetchProfileInfo:(FZProfile *)profile completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock
{
    
}

- (void)registerProfile:(FZProfile *)profile completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathProfiles
       parameters:[profile parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock){
                      NSLog(@"REGISTRATION FAILED");
                      completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}


- (void)login:(NSDictionary *)pkg completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];

    [manager POST:kPathLogin
       parameters:pkg
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // successfully logged in
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // login failed.
                  if (completionBlock)
                      completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}



- (void)fetchUploadString:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];

    [manager GET:kPathUpload
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(FZWebServiceRequestCompletionBlock)completionBlock
{
    
    NSData *imageData = image[@"data"];
    NSString *imageName = image[@"name"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:uploadUrl
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = [responseDictionary objectForKey:@"results"];
              NSString *confirmation = [results objectForKey:@"confirmation"];
              
              if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                  if (completionBlock)
                      completionBlock(results, nil);
              }
              else{ // registration failed.
                  if (completionBlock)
                      completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  
              }


//        NSLog(@"Success: %@", responseObject);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
              completionBlock(nil, error);

    }];
}


- (void)fetchWebImage:(NSString *)baseUrl withPath:(NSString *)path withParams:(NSDictionary *)params completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];

    AFImageResponseSerializer *serializer = [[AFImageResponseSerializer alloc] init];
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"image/jpeg", @"image/png"]];
    manager.responseSerializer = serializer;

    
    [manager GET:path
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             completionBlock(responseObject, nil);

         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)fetchCategoryList:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathCategoryList
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
    
    
}

- (void)fetchInterests:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathInterests
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];

}

- (void)fetchFlashTags:(FZWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathFlashTags
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             NSString *confirmation = [results objectForKey:@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
             }
             else{ // registration failed.
                 if (completionBlock)
                     completionBlock(results, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];

}



- (AFHTTPRequestOperationManager *)requestManagerForJSONSerializiation
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;

}




@end
