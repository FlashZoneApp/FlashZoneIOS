//
//  FZSocialAccountsMgr.h
//  FlashZone
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInAuthorizationViewController.h"
#import "Config.h"



typedef void (^FZSocialAccountsMgrCompletionBlock)(id result, NSError *error);


@interface FZSocialAccountsMgr : NSObject

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) NSArray *twitterAccounts;
+ (FZSocialAccountsMgr *)sharedAccountManager;

// Facebook
- (void)requestFacebookAccess:(NSArray *)permissions completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock;
- (void)requestFacebookAccountInfo:(FZSocialAccountsMgrCompletionBlock)completionBlock;

// Twitter
- (void)requestTwitterAccess:(FZSocialAccountsMgrCompletionBlock)completionBlock;
- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock;
- (void)fetchRecentTweets:(ACAccount *)twitterAccount completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock;

// LinkedIn
- (void)requestLinkedInAccess:(NSArray *)permissions fromViewController:(UIViewController *)vc completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock;


@end
