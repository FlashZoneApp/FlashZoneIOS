//
//  FZLoginViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 7/31/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZLoginViewController.h"
#import "FZForgotPasswordViewController.h"

@interface FZLoginViewController ()
@property (strong, nonatomic) NSMutableArray *textFields;
@end

@implementation FZLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.textFields = [NSMutableArray array];
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
    logo.center = CGPointMake(0.5f*frame.size.width, 0.25f*frame.size.height);
    [view addSubview:logo];

    
    NSArray *attributes = @[@"Username:", @"Password:"];
    static CGFloat padding = 12.0f;
    static CGFloat height = 20.0f;
    CGFloat y = 0.5f*frame.size.height;
    
    
    UILabel *lblSignIn = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 22.0f)];
    lblSignIn.textColor = [UIColor whiteColor];
    lblSignIn.textAlignment = NSTextAlignmentCenter;
    lblSignIn.text = @"Sign In";
    [view addSubview:lblSignIn];
    
    CGFloat width = 0.33f*frame.size.width;
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(padding, y+11.0f, width, 1.0f)];
    leftLine.backgroundColor = [UIColor whiteColor];
    [view addSubview:leftLine];

    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-width-padding, y+11.0f, width, 1.0f)];
    rightLine.backgroundColor = [UIColor whiteColor];
    [view addSubview:rightLine];

    y += lblSignIn.frame.size.height+2*padding;
    
    
    
    width = frame.size.width-2*padding;
    UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
    for (int i=0; i<attributes.count; i++){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = font;
        lbl.text = attributes[i];
        [view addSubview:lbl];
        
        y += height;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(padding, y, width, 36.0f)];
        textField.tag = 1000+i;
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = (i==1); // password fields
        [view addSubview:textField];
        [self.textFields addObject:textField];
        
        y += textField.frame.size.height+padding;
    }
    
    UIButton *btnForgotPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnForgotPassword addTarget:self action:@selector(btnForgotPasswordAction:) forControlEvents:UIControlEventTouchUpInside];
    btnForgotPassword.frame = CGRectMake(padding, y, 0.6f*width, 44.0f);
    [btnForgotPassword setTitle:@"Forgot your password?" forState:UIControlStateNormal];
    btnForgotPassword.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    btnForgotPassword.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [view addSubview:btnForgotPassword];
    
    
    width *= 0.25f;

    UIButton *btnGo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnGo.backgroundColor = [UIColor lightGrayColor];
    btnGo.frame = CGRectMake(frame.size.width-width-padding, y, width, 44.0f);
    [btnGo setTitle:@"Go" forState:UIControlStateNormal];
    btnGo.titleLabel.font = font;
    [btnGo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnGo addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnGo];
    
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnBack.backgroundColor = [UIColor clearColor];
    btnBack.frame = CGRectMake(frame.size.width-2*width-padding, y, width, 44.0f);
    [btnBack setTitle:@"Back" forState:UIControlStateNormal];
    btnBack.titleLabel.font = font;
    [btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnBack];


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [view addGestureRecognizer:tap];
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)exit
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)login:(UIButton *)btn
{
    UITextField *usernameField = (UITextField *)[self.view viewWithTag:1000];
    if (usernameField.text.length==0){
        [self showAlertWithtTitle:@"Missing Username" message:@"Please enter a username."];
        return;
    }

    UITextField *passwordField = (UITextField *)[self.view viewWithTag:1001];
    if (passwordField.text.length==0){
        [self showAlertWithtTitle:@"Missing Password" message:@"Please enter a password."];
        return;
    }
    
    for (UITextField *tf in self.textFields)
        [tf resignFirstResponder];
    
    [self.loadingIndicator startLoading];
    [[FZWebServices sharedInstance] login:@{@"username":usernameField.text, @"password":passwordField.text} completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            
            NSLog(@"%@", [results description]);
            [self.profile populate:results[@"profile"]];
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
        
    }];
}

- (void)btnForgotPasswordAction:(UIButton *)btn
{
    NSLog(@"btnForgotPasswordAction:");
    FZForgotPasswordViewController *forgotPasswordVc = [[FZForgotPasswordViewController alloc] init];
    
}

- (void)dismissKeyboard
{
    for (UITextField *tf in self.textFields) {
        [tf resignFirstResponder];
    }
    
    [self shiftBack:0.0f];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self shiftUp:150.0f];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self shiftBack:0.0f];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
