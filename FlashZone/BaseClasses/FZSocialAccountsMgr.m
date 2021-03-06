//
//  FZSocialAccountsMgr.m
//  FlashZone
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSocialAccountsMgr.h"
#import <GoogleOpenSource/GoogleOpenSource.h>


@interface FZSocialAccountsMgr ()
@property (strong, nonatomic) LIALinkedInHttpClient *linkedInClient;
@property (strong, nonatomic) FZSocialAccountsMgrCompletionBlock googlePlusCompletionHandler;
@end

@implementation FZSocialAccountsMgr
@synthesize accountStore;
@synthesize facebookAccount;
@synthesize twitterAccounts;
@synthesize selectedTwitterAccount;


#define kErrorDomain @"com.flashzone.app"

+ (FZSocialAccountsMgr *)sharedAccountManager
{
    static FZSocialAccountsMgr *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[FZSocialAccountsMgr alloc] init];
        
    });
    
    return shared;
}


#pragma mark - Twitter
- (void)requestTwitterAccess:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];

    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted==NO) {
            error = [NSError errorWithDomain:@"com.flashzone.app" code:14 userInfo:@{NSLocalizedDescriptionKey:@"Authorization not granted."}];
            completionBlock(nil, error);
            return ;
        }
        
        NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
        
        // Check if the users has setup at least one Twitter account
        if (accounts.count == 0) {
            NSLog(@"No Twitter Acccounts found.");
            return;
        }
        
        self.twitterAccounts = accounts;
        completionBlock(self.twitterAccounts, nil);

        
        
    }];
}


- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    NSString *url = [kTwitterAPI stringByAppendingString:@"users/show.json"];
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:url] parameters:@{@"screen_name":twitterAccount.username}];
    twitterInfoRequest.account = twitterAccount;
    
    
    // Making the request
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 429) { // Check if we reached the reate limit
//            NSLog(@"Rate limit reached");
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Rate limit reached"}]);
            return;
        }

        
        if (error){
            completionBlock(nil, error);
            return;
        }
        
        if (!responseData) {
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Response Data"}]);
        }
        
        error = nil;
        NSDictionary *twitterAccountInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error){ // JSON parsing error
            completionBlock(nil, error);
            return;
        }
        
//        NSLog(@"%@", [twitterAccountInfo description]);
        completionBlock(twitterAccountInfo, nil);
        
    }];
    
}

- (void)fetchRecentTweets:(ACAccount *)twitterAccount completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    NSString *url = [kTwitterAPI stringByAppendingString:@"statuses/user_timeline.json"];
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:url] parameters:@{@"screen_name":twitterAccount.username, @"count":@"200"}];
    twitterInfoRequest.account = twitterAccount;
    
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 429) { // Check if we reached the reate limit
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Rate limit reached"}]);
            return;
        }
        
        
        if (error){
            completionBlock(nil, error);
            return;
        }
        
        if (!responseData) {
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Response Data"}]);
        }
        
        error = nil;
        NSArray *recentTweets = (NSArray *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error){ // JSON parsing error
            completionBlock(nil, error);
            return;
        }
        
        completionBlock(recentTweets, nil);
    }];

}



#pragma mark - Facebook
- (void)requestFacebookAccess:(NSArray *)permissions completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    
    if (!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *FBaccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *dictFB = @{ACFacebookAppIdKey:kFacebookAppID, ACFacebookPermissionsKey:permissions};
    [accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:^(BOOL granted, NSError *e) {
        if (granted){
            if (e){
                completionBlock(nil, e);
            }
            else{
                NSArray *accounts = [accountStore accountsWithAccountType:FBaccountType];
                ACAccount *fbAccount = [accounts lastObject]; //it will always be the last object with single sign on
                ACAccountCredential *facebookCredential = [fbAccount credential];
                NSString *accessToken = [facebookCredential oauthToken];
                NSLog(@"Facebook Access Token: %@", accessToken);
                
                self.facebookAccount = fbAccount;
                NSLog(@"facebook account = %@", fbAccount.username);
                completionBlock(self.facebookAccount, nil);
            }
        }
        else{
            e = [NSError errorWithDomain:@"com.flashzone.app" code:14 userInfo:@{NSLocalizedDescriptionKey:@"Authorization not granted."}];
            completionBlock(nil, e);
            
        }
    }];
}


- (void)requestFacebookAccountInfo:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.facebookAccount) { // no facebook acccount linked
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Facebook account linked. Please allow Facebook access."}];
        completionBlock(nil, error);
        return;
    }
    
    NSString *url = [kFacebookAPI stringByAppendingString:@"me"]; // https://graph.facebook.com/me
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *facebookAccountInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"FACEBOOK INFO: %@", [facebookAccountInfo description]);
            
            if (error){ // JSON parsing error
                completionBlock(nil, error);
            }
            else {
                completionBlock(facebookAccountInfo, nil);
            }
        }
        else { // handle error:
            NSLog(@"error from get - - %@", [error localizedDescription]); //attempt to revalidate credentials
            completionBlock(nil, error);
        }
        
    }];
    
}


- (void)requestFacebookLikes:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.facebookAccount) { // no facebook acccount linked
        NSError *error = [NSError errorWithDomain:@"com.flashzone.app" code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Facebook account linked. Please allow Facebook access."}];
        completionBlock(nil, error);
        return;
    }
    
    NSString *url = [kFacebookAPI stringByAppendingString:@"me/likes"]; // https://graph.facebook.com/me/likes
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *facebookLikes = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"facebookLikes INFO: %@", [facebookLikes description]);
            
            if (error) // JSON parsing error
                completionBlock(nil, error);
            else
                completionBlock(facebookLikes, nil);
        }
        else { // handle error:
            NSLog(@"error from get - - %@", [error localizedDescription]); //attempt to revalidate credentials
            completionBlock(nil, error);
        }
        
    }];
    
}



#pragma mark - LinkedIn
- (void)requestLinkedInAccess:(NSArray *)permissions fromViewController:(UIViewController *)vc completionBlock:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:kBaseUrl
                                                                                    clientId:kLinkedInClientID
                                                                                clientSecret:kLinkedInClientSecret
                                                                                       state:kLinkedInState
                                                                               grantedAccess:permissions];
    
    self.linkedInClient = [LIALinkedInHttpClient clientForApplication:application presentingViewController:vc];
    
    [self.linkedInClient getAuthorizationCode:^(NSString *code) {
        if (code==nil){
            completionBlock(nil, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Authorization Code is Nil."}]);
            return;
        }
        
        [self.linkedInClient getAccessToken:code
                                    success:^(NSDictionary *accessTokenData) {
                                        NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.linkedInClient GET:[kLinkedInAPI stringByAppendingString:@"people/~:(id,first-name,last-name,industry,picture-url,email-address,interests)"]
                                                          parameters:@{@"oauth2_access_token":accessToken, @"format":@"json"}
                                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
                                                                 completionBlock(result, nil);
                                                             }
                                             
                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 //                                                             NSLog(@"failed to fetch current user %@", error);
                                                                 completionBlock(nil, error);
                                                             }];
                                        });
                                        
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Quering accessToken failed %@", error);
                                        completionBlock(nil, error);
                                    }];
    }
     
                                       cancel:^{
                                           NSLog(@"Authorization was cancelled by user");
                                           completionBlock(nil, [NSError errorWithDomain:@"com.flashzone.ios" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Authorization was cancelled by user"}]);

                                       }
     
     
                                      failure:^(NSError *error) {
                                          NSLog(@"Authorization failed %@", error);
                                          completionBlock(nil, error);
                                      }];
}



#pragma mark - GooglePlus
- (void)requestGooglePlusAccess:(NSArray *)permissions completion:(FZSocialAccountsMgrCompletionBlock)completionBlock
{
    if (completionBlock != NULL)
        self.googlePlusCompletionHandler = completionBlock;
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kGooglePlusClientID;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    //    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    signIn.scopes = permissions;
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    
    [signIn authenticate];
    
}


- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    NSLog(@"Received error %@ and auth object %@", [error localizedDescription], auth);
    if (error){ // handle error
        if (self.googlePlusCompletionHandler != NULL)
            self.googlePlusCompletionHandler(nil, error);
        return;
    }
    
    
    if (self.googlePlusCompletionHandler == NULL){
        NSLog(@"MISSING COMPLETION HANDLER! ! ! ");
        return;
    }
    
    
    self.googlePlusCompletionHandler(auth, nil);
}

- (void)presentSignInViewController:(UIViewController *)viewController
{
    // This is an example of how you can implement it if your app is navigation-based.
//    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)refreshInterfaceBasedOnSignIn
{
    if ([[GPPSignIn sharedInstance] authentication]) {
        NSLog(@"GOOGLE USER SIGNED IN");
        
        // The user is signed in.
        //        self.signInButton.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
    }
    else {
        NSLog(@"GOOGLE USER NOT SIGNED IN");
        
        //        self.signInButton.hidden = NO;
        // Perform other actions here
    }
}






@end
