//
//  FZProfile.m
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZProfile.h"
#import "FZWebServices.h"


@implementation FZProfile
@synthesize username;
@synthesize email;
@synthesize uniqueId;
@synthesize populated;
@synthesize password;
@synthesize bio;
@synthesize gender;
@synthesize location;
@synthesize facebookId;
@synthesize facebookName;
@synthesize twitterId;
@synthesize twitterHandle;
@synthesize twitterImage;
@synthesize image;
@synthesize imageData;
@synthesize latitude;
@synthesize longitude;
@synthesize fullname;
@synthesize linkedinId;
@synthesize linkedinImage;
@synthesize tags;
@synthesize registrationType;
@synthesize googleId;


- (id)init
{
    self = [super init];
    if (self){
        self.registrationType = FZRegistrationTypeEmail;
        self.populated = NO;
        self.latitude = 0.0f;
        self.longitude = 0.0f;
        
        [self restoreDefaults];
        [self populateFromCache];

    }
    return self;
}

+ (FZProfile *)sharedProfile
{
    //    NSLog(@"shared profile");
    static FZProfile *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[FZProfile alloc] init];
        
    });
    
    return shared;
}

- (void)restoreDefaults
{
    self.tags = [NSMutableArray array];
    self.uniqueId = @"none";
    self.fullname = @"none";
    self.email = @"none";
    self.username = @"none";
    self.password = @"none";
    self.bio = @"none";
    self.location = @"none";
    self.facebookId = @"none";
    self.facebookName = @"none";
    self.twitterId = @"none";
    self.twitterHandle = @"none";
    self.twitterImage = @"none";
    self.image = @"none";
    self.gender = @"male";
    self.linkedinId = @"none";
    self.linkedinImage = @"none";
    self.googleId = @"none";
    
}



- (void)populate:(NSDictionary *)info
{
    for (NSString *key in info.allKeys) {
        if ([key isEqualToString:@"id"])
            self.uniqueId = [info objectForKey:key];
        
        if ([key isEqualToString:@"email"])
            self.email = [info objectForKey:key];
        
        if ([key isEqualToString:@"fullname"])
            self.fullname = [info objectForKey:key];
        
        if ([key isEqualToString:@"username"])
            self.username = [info objectForKey:key];

        if ([key isEqualToString:@"bio"])
            self.bio = [info objectForKey:key];

        if ([key isEqualToString:@"gender"])
            self.gender = [info objectForKey:key];

        if ([key isEqualToString:@"location"])
            self.location = [info objectForKey:key];
        
        if ([key isEqualToString:@"facebookId"])
            self.facebookId = [info objectForKey:key];

        if ([key isEqualToString:@"facebookName"])
            self.facebookName = [info objectForKey:key];

        if ([key isEqualToString:@"twitterId"])
            self.twitterId = [info objectForKey:key];

        if ([key isEqualToString:@"twitterHandle"])
            self.twitterHandle = [info objectForKey:key];

        if ([key isEqualToString:@"image"])
            self.image = [info objectForKey:key];

        if ([key isEqualToString:@"linkedinId"])
            self.linkedinId = [info objectForKey:key];

        if ([key isEqualToString:@"googleId"])
            self.googleId = [info objectForKey:key];

        if ([key isEqualToString:@"latitude"])
            self.latitude = [[info objectForKey:key] doubleValue];

        if ([key isEqualToString:@"longitude"])
            self.longitude = [[info objectForKey:key] doubleValue];

    }
    
    self.populated = YES;
//    [self cacheProfile];
}

- (void)cacheProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [self jsonRepresentation];
    [defaults setObject:jsonString forKey:@"user"];
    [defaults synchronize];
}

- (void)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"user"];
    if (!json) // no cached profile
        return;
    
    NSError *error = nil;
    NSDictionary *profileInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    if (error)
        return;
    
    NSLog(@"STORED PROFILE: %@", [profileInfo description]);
    [self populate:profileInfo];
}

- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completion:(void (^)(BOOL success, NSError *error))completion
{
    [[FZSocialAccountsMgr sharedAccountManager] requestTwitterProfileInfo:twitterAccount completionBlock:^(id result, NSError *error){
        if (error){
            completion(NO, error);
        }
        else{
            NSDictionary *twitterAccountInfo = (NSDictionary *)result;
            NSLog(@"TWITTER ACCOUNT INFO: %@", [twitterAccountInfo description]);
            
            if (twitterAccountInfo[@"id"])
                self.twitterId = [NSString stringWithFormat:@"%@", twitterAccountInfo[@"id"]];
            
            if (twitterAccountInfo[@"screen_name"]) {
                NSString *sn = twitterAccountInfo[@"screen_name"];
                self.twitterHandle = sn;
                self.username = sn;
            }
            
            
//            if (twitterAccountInfo[@"location"])
//                self.location = twitterAccountInfo[@"location"];
            
            if (twitterAccountInfo[@"description"])
                self.bio = twitterAccountInfo[@"description"];
            
            
            if (twitterAccountInfo[@"profile_image_url"]) {
                NSString *profileImageUrl = twitterAccountInfo[@"profile_image_url"];
                profileImageUrl = [profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                profileImageUrl = [profileImageUrl stringByReplacingOccurrencesOfString:@"_bigger" withString:@""];
                self.twitterImage = profileImageUrl;
            }
            
            
            completion(YES, nil);
            
        }
        
    }];
    

    
}


- (void)getFacebookInfo:(void (^)(BOOL success, NSError *error))completion
{
    [[FZSocialAccountsMgr sharedAccountManager] requestFacebookAccountInfo:^(id result, NSError *error){
        if (error) {
            completion(false, error);
        }
        else {
            NSDictionary *facebookAccountInfo = (NSDictionary *)result;
            if (facebookAccountInfo[@"name"]){
                NSString *name = facebookAccountInfo[@"name"];
                self.facebookName = name;
                self.fullname = name;
            }
            
            if (facebookAccountInfo[@"id"])
                self.facebookId = facebookAccountInfo[@"id"];
            
            if (facebookAccountInfo[@"email"])
                self.email = facebookAccountInfo[@"email"];
            
            if (facebookAccountInfo[@"gender"])
                self.gender = facebookAccountInfo[@"gender"];
            
            
            if (facebookAccountInfo[@"error"]) {
                completion(true, nil);
            }
            else {
                completion(true, nil);
            }
        }
    }];
}


- (void)requestFacebookProfilePic:(void (^)(BOOL success, NSError *error))completion
{
    [[FZWebServices sharedInstance] fetchWebImage:kFacebookAPI
                                         withPath:[NSString stringWithFormat:@"/%@/picture", self.facebookId]
                                       withParams:@{@"type":@"large"}
                                  completionBlock:^(id result, NSError *error){
                                      
                                      if (error){
                                          NSLog(@"ERROR: %@", [error localizedDescription]);
                                          completion(NO, error);
                                          
                                      }
                                      else{
//                                          NSData *imgData = (NSData *)result;
//                                          self.imageData = [UIImage imageWithData:imgData];
                                          
                                          self.imageData = (UIImage *)result;
                                          completion(YES, nil);
                                          
                                      }
                                  }];
}



- (void)getTwitterInfo
{

    
}

- (void)requestTwitterProfilePic:(void (^)(BOOL success, NSError *error))completion
{
    NSLog(@"REQUEST TWITTER PROFILE PIC: %@", self.twitterImage);
    [[FZWebServices sharedInstance] fetchWebImage:self.twitterImage
                                         withPath:@""
                                       withParams:nil
                                  completionBlock:^(id result, NSError *error){
                                      if (error){
                                          NSLog(@"ERROR: %@", [error localizedDescription]);
                                          completion(NO, error);
                                      }
                                      else{
                                          self.imageData = (UIImage *)result;
                                          completion(YES, nil);
                                      }
                                  }];
}


- (void)requestLinkedinProfilePic:(void (^)(BOOL success, NSError *error))completion
{
    NSLog(@"REQUEST LINKEDIN PROFILE PIC: %@", self.linkedinImage);
    NSArray *parts = [self.linkedinImage componentsSeparatedByString:@".com/"];
    NSString *baseUrl = parts[0];
    baseUrl = [baseUrl stringByAppendingString:@".com"];
    
    NSString *path = (parts.count>1) ? parts[1] : @"";
    
    [[FZWebServices sharedInstance] fetchWebImage:baseUrl
                                         withPath:path
                                       withParams:nil
                                  completionBlock:^(id result, NSError *error){
                                      if (error){
                                          NSLog(@"ERROR: %@", [error localizedDescription]);
                                          completion(NO, error);
                                      }
                                      else{
                                          self.imageData = (UIImage *)result;
                                          completion(YES, nil);
                                      }
                                  }];
}

- (void)requestGooglePlusInfo:(GTMOAuth2Authentication *)auth completion:(void (^)(id result, NSError *error))completion
{
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    plusService.authorizer = auth;
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket, GTLPlusPerson *person, NSError *error) {
                if (error) {
                    GTMLoggerError(@"Error: %@", error);
                    completion(nil, error);
                }
                else {
                    completion(person, nil);
                }
            }];

}

- (void)requestGooglePlusProfilePic:(GTLPlusPerson *)person completion:(void (^)(BOOL success, NSError *error))completion
{
    NSArray *parts = [person.image.url componentsSeparatedByString:@".com/"];
    NSString *baseUrl = parts[0];
    baseUrl = [baseUrl stringByAppendingString:@".com"];
    
    NSString *path = (parts.count>1) ? parts[1] : @"";
//    if (parts.count > 1){
//        
//    }

    [[FZWebServices sharedInstance] fetchWebImage:baseUrl
                                         withPath:path
                                       withParams:nil
                                  completionBlock:^(id result, NSError *error){
                                      if (error){
                                          NSLog(@"ERROR: %@", [error localizedDescription]);
                                          completion(NO, error);
                                      }
                                      else{
                                          self.imageData = (UIImage *)result;
                                          completion(YES, nil);
                                      }
                                  }];

    
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"fullname":self.fullname, @"username":self.username, @"email":self.email, @"bio":self.bio, @"gender":self.gender, @"location":self.location, @"facebookId":self.facebookId, @"facebookName":self.facebookName, @"twitterId":self.twitterId, @"twitterHandle":self.twitterHandle, @"latitude":[NSString stringWithFormat:@"%.4f", self.latitude], @"longitude":[NSString stringWithFormat:@"%.4f", self.longitude], @"linkedinId":self.linkedinId}];
    
    if (self.password)
        params[@"password"] = self.password;
    
    return params;
}


- (NSString *)jsonRepresentation
{
    NSDictionary *info = [self parametersDictionary];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        return nil;
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
