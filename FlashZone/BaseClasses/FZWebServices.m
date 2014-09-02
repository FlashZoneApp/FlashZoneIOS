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
//    NSString *imageName = image[@"name"];

    
//    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"foo": @"bar"};
    [manager POST:uploadUrl
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:imageData name:@"file"];
    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


/*
- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(FZWebServiceRequestCompletionBlock)completionBlock
{
    NSData *imageData = image[@"data"];
    NSString *imageName = image[@"name"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:uploadUrl parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        NSError *error = nil;
        NSDictionary *responseDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error){
            completionBlock(responseObject, error);
        }
        else{
            //            completionBlock(response, nil);
            
            NSDictionary *results = [responseDictionary objectForKey:@"results"];
            NSString *confirmation = [results objectForKey:@"confirmation"];
            
            if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                if (completionBlock)
                    completionBlock(results, error);
            }
            else{
                if (completionBlock)
                    completionBlock(results, nil);
            }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        //        NSLog(@"UPLOAD FAILED: %@", [error localizedDescription]);
        completionBlock(nil, error);
    }];
    
    
    [operation start];
    
}
 
 */

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
