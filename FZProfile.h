//
//  FZProfile.h
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZSocialAccountsMgr.h"
#import <GoogleOpenSource/GoogleOpenSource.h>


@interface FZProfile : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *fullname;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *bio;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *facebookId;
@property (copy, nonatomic) NSString *facebookName;
@property (copy, nonatomic) NSString *twitterId;
@property (copy, nonatomic) NSString *twitterHandle;
@property (copy, nonatomic) NSString *twitterImage;
@property (copy, nonatomic) NSString *linkedinId;
@property (copy, nonatomic) NSString *linkedinImage;
@property (copy, nonatomic) NSString *image;
@property (strong, nonatomic) UIImage *imageData;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;


@property (nonatomic) BOOL populated;
+ (FZProfile *)sharedProfile;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;
- (void)restoreDefaults;

// Facebook requests:
- (void)getFacebookInfo:(void (^)(BOOL success, NSError *error))completion;
- (void)requestFacebookProfilePic:(void (^)(BOOL success, NSError *error))completion;

// Twitter requests:
- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completion:(void (^)(BOOL success, NSError *error))completion;
- (void)requestTwitterProfilePic:(void (^)(BOOL success, NSError *error))completion;

// LinkedIn
- (void)requestLinkedinProfilePic:(void (^)(BOOL success, NSError *error))completion;

// GooglePlus
- (void)requestGooglePlusInfo:(GTMOAuth2Authentication *)auth completion:(void (^)(id result, NSError *error))completion;


@end
