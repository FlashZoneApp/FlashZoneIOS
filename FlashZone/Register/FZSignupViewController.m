//
//  FZSignupViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 7/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSignupViewController.h"
#import "FZRegisterDetailsViewController.h"
#import "FZLoginViewController.h"
#import "FZRedditLoginViewController.h"
#import "FZSelectTwitterViewController.h"


@interface FZSignupViewController ()
@property (nonatomic) BOOL requestTwitterAccess;
@end

#define kSmallHeight 460.0f

@implementation FZSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.requestTwitterAccess = NO;
        self.title = @"";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showProfileDetailsScreen)
                                                     name:kShowProfileDetailsNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgMap.png"]];
    CGRect frame = view.frame;
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flashzonelogo.png"]];
    logo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    double pct = 45.0f/460.f;
    CGFloat h = (frame.size.height > kSmallHeight) ? pct*frame.size.height+20.0f : pct*frame.size.height;
    logo.center = CGPointMake(0.5f*frame.size.width, h);
    [view addSubview:logo];
    
    pct = 86.0f/460.0f;
    CGFloat y = (frame.size.height > kSmallHeight) ? pct*frame.size.height+20.0f : pct*frame.size.height;
    static CGFloat padding = 8.0f;
    CGFloat w = frame.size.width-2*padding;
    
    NSArray *socialogins = @[@"Facebook", @"Twitter", @"Google", @"Linkedin", @"Reddit"];
    for (int i=0; i<socialogins.count; i++){
        NSString *network = socialogins[i];
        UIImage *loginImage = [UIImage imageNamed:[NSString stringWithFormat:@"btn%@.png", network]];
        UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.tag = 1000+i;
        btnLogin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btnLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        btnLogin.frame = CGRectMake(0.0f, y, loginImage.size.width, loginImage.size.height);
        btnLogin.center = CGPointMake(0.5f*frame.size.width+1, btnLogin.center.y);
        [btnLogin setBackgroundImage:loginImage forState:UIControlStateNormal];
        [btnLogin addTarget:self action:@selector(signupSocialNetwork:) forControlEvents:UIControlEventTouchUpInside];
        [btnLogin setTitle:[NSString stringWithFormat:@"            Connect with %@", network] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [view addSubview:btnLogin];
        y += loginImage.size.height+padding;
    }
    
    h = 34.0f;

    UIButton *btnSignupWithEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignupWithEmail.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnSignupWithEmail.frame = CGRectMake(padding, y-5.0f, w, h);
    btnSignupWithEmail.backgroundColor = [UIColor clearColor];
    [btnSignupWithEmail setTitle:@"Sign up with Email" forState:UIControlStateNormal];
    btnSignupWithEmail.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btnSignupWithEmail addTarget:self action:@selector(signupWithEmail:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSignupWithEmail];
    
    
    // The following views are pinned to the bottom:
    
    y = frame.size.height-46.0f;
    
    UILabel *lblAgreement = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 44.0f)];
    lblAgreement.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblAgreement.textColor = [UIColor whiteColor];
    lblAgreement.font = [UIFont systemFontOfSize:11.0f];
    lblAgreement.textAlignment = NSTextAlignmentCenter;
    lblAgreement.numberOfLines = 2;
    lblAgreement.lineBreakMode = NSLineBreakByWordWrapping;
    lblAgreement.text = @"By signing up, you agree to FlashZone's\nTerms of Service & Privacy Policy.";
    [view addSubview:lblAgreement];

    y -= (frame.size.height > 500) ? (h+24.0f) : (h+1.0f); // iphone 4 vs iphone 5

    UILabel *lblAreadyRegistered = [[UILabel alloc] initWithFrame:CGRectMake(padding+30.0f, y, 0.7f*w, h)];
    lblAreadyRegistered.textColor = [UIColor whiteColor];
    lblAreadyRegistered.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblAreadyRegistered.backgroundColor = [UIColor clearColor];
    lblAreadyRegistered.font = [UIFont boldSystemFontOfSize:13.0f];
    lblAreadyRegistered.text = @"Already have an account?";
    [view addSubview:lblAreadyRegistered];
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnLogin.frame = CGRectMake(frame.size.width-70.0f-padding-30.0f, y, 70.0f, h);
    btnLogin.backgroundColor = [UIColor lightGrayColor];
    btnLogin.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    btnLogin.layer.cornerRadius = 4.0f;
    [btnLogin setTitle:@"Log in" forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnLogin];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.requestTwitterAccess)
        [self.loadingIndicator startLoading];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (!self.requestTwitterAccess)
        return;
    
    self.requestTwitterAccess = NO;
    [self.profile requestTwitterProfileInfo:self.socialAccountsMgr.selectedTwitterAccount completion:^(BOOL success, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            if (success){
                self.profile.registrationType = FZRegistrationTypeTwitter;
                [self showProfileDetailsScreen];
            }
            else{
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
        });
        
    }];


}





- (void)showProfileDetailsScreen
{
    FZRegisterDetailsViewController *accountDetailsVc = [[FZRegisterDetailsViewController alloc] init];
    
    UINavigationController *registerNavCtr = [[UINavigationController alloc] initWithRootViewController:accountDetailsVc];
    registerNavCtr.navigationBar.tintColor = [UIColor whiteColor];
    registerNavCtr.navigationBar.barTintColor = kOrange;
    registerNavCtr.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:registerNavCtr.navigationBar.tintColor};
    
    [self presentViewController:registerNavCtr animated:YES completion:^{
        [self.loadingIndicator stopLoading];
    }];
}

- (void)signupWithEmail:(UIButton *)btn
{
    self.profile.registrationType = FZRegistrationTypeEmail;
    [self showProfileDetailsScreen];
}

- (void)signupSocialNetwork:(UIButton *)btn
{
    NSLog(@"signupSocialNetwork: %ld", (long)btn.tag);
    
    if (btn.tag==1000){ // FACEBOOK
        [self.loadingIndicator startLoading];
        
        [self.socialAccountsMgr requestFacebookAccess:kFacebookPermissions completionBlock:^(id result, NSError *error){
            
            if (error){
                [self.loadingIndicator stopLoading];
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
            else{
                NSLog(@"FACEBOOK ACCESS GRANTED!!");
                [self.profile getFacebookInfo:^(BOOL success, NSError *error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingIndicator stopLoading];
                        if (success){
                            self.profile.registrationType = FZRegistrationTypeFacebook;
                            [self showProfileDetailsScreen];
                        }
                        else{
                            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                            
                        }
                    });

                }];

            }

            
        }];
    }
    
    
    if (btn.tag==1001){ // TWITTER - Request access to the Twitter accounts
        [self.socialAccountsMgr requestTwitterAccess:^(id result, NSError *error){
            
            if (error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                });
            }
            else{
                NSArray *twitterAccounts = (NSArray *)result;
                if (twitterAccounts.count == 0) {
                    NSLog(@"No Twitter Acccounts found.");
                    return;
                }
                else if (twitterAccounts.count > 1){ // multiple accounts - select one
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.requestTwitterAccess = YES;
                        FZSelectTwitterViewController *selectTwitterVc = [[FZSelectTwitterViewController alloc] init];
                        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:selectTwitterVc];
                        navCtr.navigationBar.barTintColor = kOrange;
                        [self presentViewController:navCtr animated:YES completion:NULL];
                    });
                }
                else{
                    
                    ACAccount *twitterAccount = [self.socialAccountsMgr.twitterAccounts objectAtIndex:0];
                    self.socialAccountsMgr.selectedTwitterAccount = twitterAccount;
                    [self.profile requestTwitterProfileInfo:twitterAccount completion:^(BOOL success, NSError *error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.loadingIndicator stopLoading];
                            if (success){
                                self.profile.registrationType = FZRegistrationTypeTwitter;
                                [self showProfileDetailsScreen];
                            }
                            else{
                                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                            }
                        });
                    }];

                }
                
            }
            
        }];
    }
    
    if (btn.tag==1002){ // GOOGLE PLUS
        [self.loadingIndicator startLoading];
        [self.socialAccountsMgr requestGooglePlusAccess:@[@"profile"] completion:^(id result, NSError *error){
            if (error){
                [self.loadingIndicator stopLoading];
                NSLog(@"GOOGLE PLUS LOGIN FAILED");
            
            }
            else {
                GTMOAuth2Authentication *auth = (GTMOAuth2Authentication *)result;
//                NSLog(@"GOOGLE PLUS LOGIN SUCCESS: %@", auth);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.profile requestGooglePlusInfo:auth completion:^(id result, NSError *error){
                        GTLPlusPerson *person = (GTLPlusPerson *)result;
                        for (GTLPlusPersonEmailsItem *email in person.emails){
                            NSLog(@"EMAIL: %@", [email description]);
                            if (email.value)
                                self.profile.email = email.value;
                        }
                        
                        if (person.identifier)
                            self.profile.googleId = person.identifier;
                        
                        if (person.displayName)
                            self.profile.fullname = person.displayName;

                        if (person.occupation){
                            [self.profile.suggestedTags addObject:@{@"name":person.occupation, @"id":@"-1"}];
                        }

                        if (person.skills){
                            NSArray *skills = [person.skills componentsSeparatedByString:@","];
                            for (int i=0; i<skills.count; i++) {
                                NSString *skill = skills[i];
                                skill = [skill stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                [self.profile.suggestedTags addObject:@{@"name":skill, @"id":@"-1"}];
                            }
                        }
                        
                        if (person.image){
                            self.profile.googleImage = person.image.url;
                            NSLog(@"GOOGLE PLUS IMAGE: %@", self.profile.googleImage);

                            
                        }

                        self.profile.registrationType = FZRegistrationTypeGoogle;
                        [self showProfileDetailsScreen];

                    }];
                });
                
            }
        }];
    }
    
    if (btn.tag==1003){ // LINKEDIN
        [self.loadingIndicator startLoading];
        [self.socialAccountsMgr requestLinkedInAccess:@[@"r_fullprofile", @"r_network"] fromViewController:self completionBlock:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];

            if (error){
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
            else{
                NSDictionary *linkedInInfo = (NSDictionary *)result;
                NSLog(@"LINKED IN PROFILE: %@", [linkedInInfo description]);
                
                NSString *name = @"";
                if (linkedInInfo[@"firstName"])
                    name = [name stringByAppendingString:linkedInInfo[@"firstName"]];
                
                
                if (linkedInInfo[@"lastName"]){
                    name = [name stringByAppendingString:@" "];
                    name = [name stringByAppendingString:linkedInInfo[@"lastName"]];
                }

                self.profile.fullname = name;
                
                if (linkedInInfo[@"email"])
                    self.profile.email = linkedInInfo[@"email"];

                if (linkedInInfo[@"id"])
                    self.profile.linkedinId = linkedInInfo[@"id"];

                if (linkedInInfo[@"pictureUrl"])
                    self.profile.linkedinImage = linkedInInfo[@"pictureUrl"];
                
                if (linkedInInfo[@"industry"]){
                    NSString *industry = linkedInInfo[@"industry"];
                    [self.profile.suggestedTags addObject:@{@"name":industry, @"id":@"-1"}];
                }
                
                if (linkedInInfo[@"interests"]){
                    NSString *interests = linkedInInfo[@"interests"]; // comma separated string
                    NSArray *a = [interests componentsSeparatedByString:@","];
                    
                    for (int i=0; i<a.count; i++){
                        NSString *interest = a[i];
                        interest = [interest stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [self.profile.suggestedTags addObject:@{@"name":interest, @"id":@"-1"}];
                    }
                    
                    
                }

                
                self.profile.registrationType = FZRegistrationTypeLinkedIn;
                [self showProfileDetailsScreen];
            }
            
        }];
    }
    
    
    if (btn.tag==1004){ // REDDIT
        FZRedditLoginViewController *redditSignInVc = [[FZRedditLoginViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:redditSignInVc];
        navCtr.navigationBar.barTintColor = kOrange;
        navCtr.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:navCtr animated:YES completion:^{
            
        }];
        
    }
}



- (void)login:(UIButton *)btn
{
    NSLog(@"login:");
    FZLoginViewController *loginVc = [[FZLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVc animated:YES];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
