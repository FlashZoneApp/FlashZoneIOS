//
//  FZRedditLoginViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/21/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZRedditLoginViewController.h"
#import "DKRedditManager.h"

@interface FZRedditLoginViewController ()
@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) FZLoadingIndicator *loadingIndicator;
@end

@implementation FZRedditLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Log In";
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor whiteColor];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    CGRect frame = view.frame;
    
    
    UIImageView *redditLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reddit-logo.png"]];
    redditLogo.frame = CGRectMake(0.0f, 0.0f, 0.5f*redditLogo.frame.size.width, 0.5f*redditLogo.frame.size.height);
    redditLogo.center = CGPointMake(0.5f*frame.size.width, 60.0f);
    [view addSubview:redditLogo];
    
    
    CGFloat y = 120.0f;
    CGFloat h = 36.0f;
    
    UILabel *lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, frame.size.width-20.0f, 22.0f)];
    lblUsername.text = @"Username";
    lblUsername.font = [UIFont boldSystemFontOfSize:16.0f];
    [view addSubview:lblUsername];
    y += lblUsername.frame.size.height+4.0f;
    
    UIView *bgUsername = [[UIView alloc] initWithFrame:CGRectMake(10.0f, y, frame.size.width-20.0f, h)];
    bgUsername.backgroundColor = [UIColor whiteColor];
    bgUsername.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    bgUsername.layer.borderWidth = 2.0f;
    bgUsername.layer.cornerRadius = 5.0f;
    bgUsername.layer.masksToBounds = YES;
    self.usernameField = [[UITextField alloc] initWithFrame:CGRectMake(12.0f, 0.0f, frame.size.width-24.0f, h)];
    self.usernameField.delegate = self;
    [bgUsername addSubview:self.usernameField];
    [view addSubview:bgUsername];
    y += bgUsername.frame.size.height+4.0f;
    
    UILabel *lblPassword = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, frame.size.width-20.0f, 22.0f)];
    lblPassword.text = @"Password";
    lblPassword.font = [UIFont boldSystemFontOfSize:16.0f];
    [view addSubview:lblPassword];
    y += lblPassword.frame.size.height+4.0f;
    
    
    UIView *bgPassword = [[UIView alloc] initWithFrame:CGRectMake(10.0f, y, frame.size.width-20.0f, h)];
    bgPassword.backgroundColor = [UIColor whiteColor];
    bgPassword.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    bgPassword.layer.borderWidth = 2.0f;
    bgPassword.layer.cornerRadius = 5.0f;
    bgPassword.layer.masksToBounds = YES;
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0f, 0.0f, frame.size.width-24.0f, h)];
    self.passwordField.delegate = self;
    self.passwordField.secureTextEntry = YES;
    self.passwordField.layer.masksToBounds = YES;
    [bgPassword addSubview:self.passwordField];
    [view addSubview:bgPassword];
    y += self.passwordField.frame.size.height+20.0f;
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.backgroundColor = [UIColor redColor];
    btnLogin.frame = CGRectMake(10.0f, y, frame.size.width-20.0f, 60.0f);
    btnLogin.layer.cornerRadius = 4.0f;
    [btnLogin setTitle:@"Sign In" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnLogin];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingIndicator = [[FZLoadingIndicator alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    self.loadingIndicator.alpha = 0.0f;
    [self.view addSubview:self.loadingIndicator];
    
    UIImage *imgBack = [UIImage imageNamed:@"backArrow.png"];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:imgBack forState:UIControlStateNormal];
    btnBack.frame = CGRectMake(0.0f, 0.0f, imgBack.size.width, imgBack.size.height);
    [btnBack addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];

    
    
    
    //SOURCE: https://github.com/reddit/reddit/wiki/OAuth2
    // https://ssl.reddit.com/api/v1/authorize?client_id=kVYNhoyxy-iYCA&response_type=code&state=1afawlek&redirect_uri=http://flash-zone.appspot.com&duration=permanent&scope=identity,history,mysubreddits,read
    
    //    NSString *url = [NSString stringWithFormat:@"https://ssl.reddit.com/api/v1/authorize?client_id=kVYNhoyxy-iYCA&response_type=code&state=sksksks&redirect_uri=http://flash-zone.appspot.com&duration=permanent&scope=identity,history,mysubreddits,read"];
    
}


- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)login
{
    NSLog(@"LOGIN: %@, %@", self.usernameField.text, self.passwordField.text);
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [self shiftBack:64.0f];
    
    if (self.usernameField.text.length==0){
        [self showAlertWithtTitle:@"Missing Username" message:@"Please enter a valid Reddit username."];
        return;
    }

    if (self.passwordField.text.length==0){
        [self showAlertWithtTitle:@"Missing Password" message:@"Please enter your Reddit password."];
        return;
    }

    
    [self.loadingIndicator startLoading];
    
    DKRedditManager *redditMgr = [DKRedditManager sharedRedditManager];
    [redditMgr loginWithUsername:self.usernameField.text password:self.passwordField.text completion:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            NSLog(@"REDDIT LOGIN ERROR: %@", [error localizedDescription]);
        }
        else{
            NSLog(@"REDDIT LOGIN SUCCESS: %@", [result description]);
            
            
            // Fetch subreddits
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profile.username = self.usernameField.text;
                [self fetchSubreddits:redditMgr];
            });
            
            
        }
    }];
}

- (void)fetchSubreddits:(DKRedditManager *)redditMgr
{
    [redditMgr fetchSubreddits:^(id result, NSError *error){
        NSDictionary *response = (NSDictionary *)result;
        NSDictionary *data = response[@"data"];
        
        if (data[@"children"]){
            NSArray *list = data[@"children"];
            for (NSDictionary *subreddit in list) {
                if (subreddit[@"data"]==nil)
                    continue;
                
                NSDictionary *subredditInfo = subreddit[@"data"];
                NSString *title = subredditInfo[@"title"];
                if (title==nil)
                    continue;
                
                NSLog(@"SUBREDDIT = %@", title);
                if([self.profile.suggestedTags containsObject:title]==NO)
                    [self.profile.suggestedTags addObject:@{@"name":title, @"id":@"-1"}];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            self.profile.registrationType = FZRegistrationTypeReddit;
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowProfileDetailsNotification object:nil]];
            }];
            

        });
        
        
    }];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self shiftUp:60.0f];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self shiftBack:64.0f];
    [textField resignFirstResponder];
    return YES;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
