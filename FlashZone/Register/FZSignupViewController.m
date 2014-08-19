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


@interface FZSignupViewController ()
@property (strong, nonatomic) UITableView *twitterAccountsTable;
@end

#define kSmallHeight 460.0f

@implementation FZSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"";
        
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
    double pct = 50.0f/460.f;
    CGFloat h = (frame.size.height > kSmallHeight) ? pct*frame.size.height+20.0f : pct*frame.size.height;
    logo.center = CGPointMake(0.5f*frame.size.width, h);
    [view addSubview:logo];
    
    pct = 100.0f/460.0f;
    CGFloat y = (frame.size.height > kSmallHeight) ? pct*frame.size.height+20.0f : pct*frame.size.height;
    static CGFloat padding = 12.0f;
    CGFloat w = frame.size.width-2*padding;
    
    NSArray *socialogins = @[@"loginFacebook.png", @"loginTwitter.png", @"loginGoogle.png", @"loginLinkedin.png"];
    for (int i=0; i<socialogins.count; i++){
        UIImage *loginImage = [UIImage imageNamed:socialogins[i]];
        UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.tag = 1000+i;
        btnLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        btnLogin.frame = CGRectMake(0.0f, y, loginImage.size.width, loginImage.size.height);
        btnLogin.center = CGPointMake(0.5f*frame.size.width+1, btnLogin.center.y);
        [btnLogin setBackgroundImage:loginImage forState:UIControlStateNormal];
        [btnLogin addTarget:self action:@selector(signupSocialNetwork:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnLogin];
        y += loginImage.size.height+padding;
    }
    

    h = 34.0f;

    UIButton *btnSignupWithEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignupWithEmail.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnSignupWithEmail.frame = CGRectMake(padding, y, w, h);
    btnSignupWithEmail.backgroundColor = [UIColor clearColor];
    [btnSignupWithEmail setTitle:@"Sign up with Email" forState:UIControlStateNormal];
    [btnSignupWithEmail addTarget:self action:@selector(signupWithEmail:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSignupWithEmail];
    
    
    // The following views are pinned to the bottom:
    
    y = frame.size.height-48.0f;
    
    UILabel *lblAgreement = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 48.0f)];
    lblAgreement.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblAgreement.textColor = [UIColor whiteColor];
    lblAgreement.font = [UIFont systemFontOfSize:14.0f];
    lblAgreement.textAlignment = NSTextAlignmentCenter;
    lblAgreement.numberOfLines = 2;
    lblAgreement.lineBreakMode = NSLineBreakByWordWrapping;
    lblAgreement.text = @"By signing up, you agree to FlashZone's\nTerms of Service and Privacy Policy.";
    [view addSubview:lblAgreement];

    y -= (h+padding);

    UILabel *lblAreadyRegistered = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, 0.7f*w, h)];
    lblAreadyRegistered.textColor = [UIColor whiteColor];
    lblAreadyRegistered.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblAreadyRegistered.backgroundColor = [UIColor clearColor];
    lblAreadyRegistered.font = [UIFont boldSystemFontOfSize:16.0f];
    lblAreadyRegistered.text = @"Already have an account?";
    [view addSubview:lblAreadyRegistered];
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnLogin.frame = CGRectMake(padding+0.7f*w, y, 86.0f, h);
    btnLogin.backgroundColor = [UIColor lightGrayColor];
    btnLogin.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnLogin];
    
    
    self.twitterAccountsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.twitterAccountsTable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.twitterAccountsTable.dataSource = self;
    self.twitterAccountsTable.delegate = self;
    self.twitterAccountsTable.alpha = 0;
    [view addSubview:self.twitterAccountsTable];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.profile restoreDefaults];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

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
                        [self showAlertWithtTitle:@"Select Account" message:@"We found multiple Twitter accounts associated with this device. Please select one"];
                        [self.twitterAccountsTable reloadData];
                        self.twitterAccountsTable.alpha = 1.0f;
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
                                self.twitterAccountsTable.alpha = 0;
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
                        
                        if (person.displayName)
                            self.profile.fullname = person.displayName;
                        
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
                
                self.profile.registrationType = FZRegistrationTypeLinkedIn;
                [self showProfileDetailsScreen];

                
            }
            
        }];
        
        
    }
}



- (void)login:(UIButton *)btn
{
    NSLog(@"login:");
    FZLoginViewController *loginVc = [[FZLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVc animated:YES];
}






#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.socialAccountsMgr.twitterAccounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[indexPath.row];
    cell.textLabel.text = twitterAccount.username;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[indexPath.row];
    self.socialAccountsMgr.selectedTwitterAccount = twitterAccount;
    
    [self.loadingIndicator startLoading];
    [self.profile requestTwitterProfileInfo:twitterAccount completion:^(BOOL success, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            if (success){
                self.profile.registrationType = FZRegistrationTypeTwitter;
                self.twitterAccountsTable.alpha = 0;
                [self showProfileDetailsScreen];
            }
            else{
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
        });
        
    }];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
