//
//  FZRegisterDetailsViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 7/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZRegisterDetailsViewController.h"
#import "FZWebViewController.h"
#import "FZPickPhotoViewController.h"
#import "UIImage+FZImageEffects.h"


@interface FZRegisterDetailsViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *textViews;
@property (strong, nonatomic) NSArray *attributes;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIButton *btnRegister;
@property (strong, nonatomic) NSCharacterSet *invalidCharacters;
@property (strong, nonatomic) UIView *iconBase;
@property (strong, nonatomic) UIImageView *profileIcon;
@property (nonatomic) NSTimeInterval now;
@end

static NSString *bioPlaceholder = @"Share a little bit about yourself.";

@implementation FZRegisterDetailsViewController
@synthesize canRegister = _canRegister;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Create Account";
        self.textViews = [NSMutableArray array];
        self.canRegister = NO;
        
        NSCharacterSet *allowableCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-"];
        self.invalidCharacters = [allowableCharacters invertedSet];

    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor blackColor];
    CGRect frame = view.frame;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    static CGFloat padding = 12.0f;
    static CGFloat height = 20.0f;
    CGFloat y = padding;
    
    UIImage *imageIcon = [UIImage imageNamed:@"photoPlaceholder.png"];
    self.iconBase = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageIcon.size.width, imageIcon.size.height)];
    self.iconBase.center = CGPointMake(0.5f*frame.size.width, 120.0f);
    self.iconBase.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.iconBase.layer.cornerRadius = 0.5f*self.iconBase.frame.size.width;
    self.iconBase.layer.masksToBounds = YES;
    self.iconBase.backgroundColor = [UIColor lightGrayColor];
    
    self.profileIcon = [[UIImageView alloc] initWithImage:imageIcon];
    self.profileIcon.center = CGPointMake(0.5f*self.iconBase.frame.size.width, 0.5f*self.iconBase.frame.size.height);
    [self.profileIcon addObserver:self forKeyPath:@"image" options:0 context:nil];
    [self.iconBase addSubview:self.profileIcon];
    
    [self.scrollView addSubview:self.iconBase];
    y += self.iconBase.frame.size.height+padding;

    
    self.attributes = @[@"Full name", @"Username:", @"Password:", @"Confirm:", @"Email:", @"Location: (your exact location won't be shown)"];
    CGFloat width = frame.size.width-2*padding;
    UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
    for (int i=0; i<self.attributes.count; i++){
        NSString *text = self.attributes[i];
        NSArray *parts = [text componentsSeparatedByString:@"("];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = font;
        lbl.text = parts[0];
        [self.scrollView addSubview:lbl];
        
        if (parts.count > 1){
            UILabel *subLbl = [[UILabel alloc] initWithFrame:CGRectMake(82.0f, y, width, height)];
            subLbl.backgroundColor = [UIColor clearColor];
            subLbl.font = [UIFont systemFontOfSize:13.0f];
            subLbl.text = [@" (" stringByAppendingString:parts[1]];
            [self.scrollView addSubview:subLbl];
        }
        
        y += height;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(padding, y, width, 36.0f)];
        textField.tag = 1000+i;
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if (i==0){
            if ([self.profile.fullname isEqualToString:@"none"]==NO)
                textField.text = self.profile.fullname;
        }
        if (i==1){
            UIView *atSign = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36.0f, 36.0f)];
            atSign.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"atSign.png"]];
            
            [textField setLeftViewMode:UITextFieldViewModeAlways];
            [textField setLeftView:atSign];
            
            textField.placeholder = @"only letters, numbers, & underscores";
            if ([self.profile.username isEqualToString:@"none"]==NO)
                textField.text = self.profile.username;
        }
        if (i==2 || i==3){
            textField.secureTextEntry = YES;
            textField.clearsOnBeginEditing = NO;
        }
        
        if (i==4) { // email field, don't auto capitalize
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            if ([self.profile.email isEqualToString:@"none"]==NO)
                textField.text = self.profile.email;
        }
        if (i==5) { // location field
            if ([self.profile.location isEqualToString:@"none"]==NO)
                textField.text = self.profile.location;
        }
        
        textField.font = [UIFont systemFontOfSize:12.0f];
        [self.scrollView addSubview:textField];
        [self.textViews addObject:textField];
        
        y += textField.frame.size.height+padding;
    }
    
    UILabel *lblGender = [[UILabel alloc] initWithFrame:CGRectMake(padding, y+2.0f, 0.25f*width, height)];
    lblGender.backgroundColor = [UIColor clearColor];
    lblGender.font = font;
    lblGender.text = @"Gender:";
    [self.scrollView addSubview:lblGender];
    
    CGFloat x = padding+lblGender.frame.size.width;
    CGFloat btnWidth = 0.35f*width;
    CGFloat btnHeight = 1.25f*height;
    UIButton *btnMale = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMale.tag = 2000;
    btnMale.backgroundColor = [UIColor clearColor];
    [btnMale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnMale.frame = CGRectMake(x, y, btnWidth, btnHeight);
    [btnMale setTitle:@"Male:" forState:UIControlStateNormal];
    btnMale.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btnMale setBackgroundImage:[UIImage imageNamed:@"btnUnselected.png"] forState:UIControlStateNormal];
    [btnMale setBackgroundImage:[UIImage imageNamed:@"btnSelected.png"] forState:UIControlStateSelected];
    [btnMale setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f)];
    btnMale.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnMale.selected = ([self.profile.gender isEqualToString:@"male"]);
    [btnMale addTarget:self action:@selector(selectGender:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnMale];
    
    x += btnMale.frame.size.width;
    UIButton *btnFemale = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFemale.tag = 2001;
    btnFemale.backgroundColor = [UIColor clearColor];
    btnFemale.frame = CGRectMake(x, y, btnWidth, btnHeight);
    btnFemale.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btnFemale setTitle:@"Female:" forState:UIControlStateNormal];
    btnFemale.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnFemale.selected = ([self.profile.gender isEqualToString:@"female"]);
    [btnFemale setBackgroundImage:[UIImage imageNamed:@"btnUnselected.png"] forState:UIControlStateNormal];
    [btnFemale setBackgroundImage:[UIImage imageNamed:@"btnSelected.png"] forState:UIControlStateSelected];
    [btnFemale addTarget:self action:@selector(selectGender:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnFemale];
    
    y += btnFemale.frame.size.height+padding;
    UILabel *lblBio = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
    lblBio.text = @"Bio/Personal Statement:";
    lblBio.font = font;
    [self.scrollView addSubview:lblBio];
    y += lblBio.frame.size.height;
    
    UITextView *bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, y, width, 3*height)];
    bioTextView.tag = 1000+self.attributes.count;
    bioTextView.textColor = [UIColor lightGrayColor];
    bioTextView.layer.borderColor = [[UIColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:1.0f] CGColor];
    bioTextView.layer.borderWidth = 0.5f;
    bioTextView.layer.cornerRadius = 5.0f;
    bioTextView.text = ([self.profile.bio isEqualToString:@"none"]) ? bioPlaceholder : self.profile.bio;
    bioTextView.delegate = self;
    [self.scrollView addSubview:bioTextView];
    [self.textViews addObject:bioTextView];
    y += bioTextView.frame.size.height+padding;
    
    self.btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnRegister.frame = CGRectMake(padding, y, width, 44.0f);
    [self.btnRegister setTitle:@"Get in the FlashZone" forState:UIControlStateNormal];
    [btnFemale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnRegister setBackgroundColor:[UIColor lightGrayColor]];
    [self.btnRegister addTarget:self action:@selector(registerProfile:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.btnRegister];
    y += self.btnRegister.frame.size.height+padding;
    
    UIButton *btnTerms = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTerms.frame = CGRectMake(padding, y, 36.0f, 26.0f);
    btnTerms.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnTerms setTitle:@"Terms" forState:UIControlStateNormal];
    [btnTerms setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnTerms.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [btnTerms addTarget:self action:@selector(viewLegal:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnTerms];

    UIButton *btnPrivacy = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPrivacy.frame = CGRectMake(2*padding+btnTerms.frame.size.width, y, 45.0f, 26.0f);
    btnPrivacy.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnPrivacy setTitle:@"Privacy" forState:UIControlStateNormal];
    [btnPrivacy setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnPrivacy.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [btnPrivacy addTarget:self action:@selector(viewLegal:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnPrivacy];

    x = btnPrivacy.frame.origin.x+btnPrivacy.frame.size.width+padding;
    UILabel *lblAlreadyHaveAnAccount = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 150.0f, 26.0f)];
    lblAlreadyHaveAnAccount.text = @"Already have an account?";
    lblAlreadyHaveAnAccount.font = [UIFont boldSystemFontOfSize:12.0f];
    [self.scrollView addSubview:lblAlreadyHaveAnAccount];
    
    x = lblAlreadyHaveAnAccount.frame.origin.x+lblAlreadyHaveAnAccount.frame.size.width;
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(x, y, 45.0f, 26.0f);
    btnLogin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnLogin setTitle:@"Sign In" forState:UIControlStateNormal];
    [btnLogin setTitleColor:kOrange forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.scrollView addSubview:btnLogin];

    
    y += btnTerms.frame.size.height;

    self.scrollView.contentSize = CGSizeMake(0, y);
    [view addSubview:self.scrollView];
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
}

- (void)adjustProfileIcon
{
    CGFloat w = self.profile.imageData.size.width;
    CGFloat h = self.profile.imageData.size.height;
    
    double scale = 0.0f;
    CGRect iconFrame = self.profileIcon.frame;
    if (w != iconFrame.size.width){
        scale = iconFrame.size.width/w;
        w = iconFrame.size.width;
        h *= scale;
    }
    if (h<iconFrame.size.height){
        scale = iconFrame.size.height/h;
        h = iconFrame.size.height;
        w *= scale;
    }
    
    iconFrame.size.width = w;
    iconFrame.size.height = h;
    self.profileIcon.frame = iconFrame;
    self.profileIcon.center = CGPointMake(0.5f*self.iconBase.frame.size.width, 0.5f*self.iconBase.frame.size.height);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.profile.registrationType==FZRegistrationTypeFacebook){
        if ([self.profile.facebookId isEqualToString:@"none"]==NO){
            [self.loadingIndicator startLoading];
            [self.profile requestFacebookProfilePic:^(BOOL success, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    self.profileIcon.image = self.profile.imageData;
                });
            }];
            return;
        }
    }
    
    if (self.profile.registrationType==FZRegistrationTypeTwitter){
        if ([self.profile.twitterImage isEqualToString:@"none"]==NO){
            NSLog(@"FOUND TWITTER PROFILE PIC: %@", self.profile.twitterImage);
            [self.loadingIndicator startLoading];
            [self.profile requestTwitterProfilePic:^(BOOL success, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    self.profileIcon.image = self.profile.imageData;
                });
                
            }];
            return;
        }
    }
    
    
    if (self.profile.registrationType==FZRegistrationTypeLinkedIn){
        if ([self.profile.linkedinImage isEqualToString:@"none"]==NO){
            [self.loadingIndicator startLoading];
            [self.profile requestLinkedinProfilePic:^(BOOL success, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    self.profileIcon.image = self.profile.imageData;
                });
                
            }];
            return;
        }
    }
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



- (void)setCanRegister:(BOOL)canRegister
{
    _canRegister = canRegister;
    if (canRegister){
        [self.btnRegister setBackgroundImage:[UIImage imageNamed:@"bgButton.png"] forState:UIControlStateNormal];
        return;
    }
    
    // disabled
    self.btnRegister.backgroundColor = [UIColor lightGrayColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]==NO)
        return;
    
    
    [self adjustProfileIcon];
    [UIView transitionWithView:self.profileIcon
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.profileIcon.alpha = 1.0f;
                    }
                    completion:NULL];
}

- (void)dealloc
{
    [self.profileIcon removeObserver:self forKeyPath:@"image"];
}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewLegal:(UIButton *)btn
{
    NSString *title = btn.titleLabel.text.lowercaseString;
    NSString *baseUrl = kBaseUrl;
    FZWebViewController *webVc = [[FZWebViewController alloc] init];
    if ([title isEqualToString:@"terms"]){
        webVc.target = [baseUrl stringByAppendingString:@"site/mobile/terms.html"];
    }

    if ([title isEqualToString:@"privacy"]){
        webVc.target = [baseUrl stringByAppendingString:@"site/mobile/privacy.html"];
    }
    
    [self.navigationController pushViewController:webVc animated:YES];

}


- (void)selectGender:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.tag==2000){ // male button
        self.profile.gender = @"male";
        UIButton *btnFemale = (UIButton *)[self.scrollView viewWithTag:2001];
        btnFemale.selected = !btn.selected;
    }
    
    if (btn.tag==2001){ // female button
        self.profile.gender = @"female";
        UIButton *btnMale = (UIButton *)[self.scrollView viewWithTag:2000];
        btnMale.selected = !btn.selected;
    }
}

- (BOOL)isValidEmail:(NSString *)emailString strict:(BOOL)strictFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}


- (void)registerProfile:(UIButton *)btn
{
    NSLog(@"registerProfile: %@", [self.profile jsonRepresentation]);
    
    
    if (self.profile.username.length==0 || [self.profile.username isEqualToString:@"none"]==YES){
        [self showAlertWithtTitle:@"Missing Username" message:@"Please enter a valid username."];
        return;
    }
    
    if ([self.profile.username.lowercaseString rangeOfCharacterFromSet:self.invalidCharacters].location != NSNotFound){
        NSLog(@"the string contains illegal characters");
        [self showAlertWithtTitle:@"Invalid Username" message:@"Please enter a username with only letters, numbers, underscores, and hyphens."];
        return;
    }

    
    if (self.profile.password.length==0 || [self.profile.password isEqualToString:@"none"]==YES){
        [self showAlertWithtTitle:@"Missing Password" message:@"Please enter a valid password (at least 6 characters)."];
        return;
    }
    
    if (self.profile.password.length < 6){
        [self showAlertWithtTitle:@"Password Too Short" message:@"Please enter a password with at least 6 characters."];
        return;
    }
    
    
    UITextField *passwordConfirmField = (UITextField *)[self.scrollView viewWithTag:1003];
    if ([self.profile.password isEqualToString:passwordConfirmField.text]==NO){
        [self showAlertWithtTitle:@"Error" message:@"The passwords do not match."];
        return;
    }

    if (self.profile.email.length==0 || [self.profile.email isEqualToString:@"none"]==YES){
        [self showAlertWithtTitle:@"Missing Email" message:@"Please enter a valid email."];
        return;
    }
    
    if ([self isValidEmail:self.profile.email strict:YES]==NO){
        [self showAlertWithtTitle:@"Email Invalid" message:@"Please enter a valid email."];
        return;
    }

    if (self.profile.location.length==0 || [self.profile.location isEqualToString:@"none"]==YES){
        [self showAlertWithtTitle:@"Missing Location" message:@"Please add a location."];
        return;
    }
    


    [self.loadingIndicator startLoading];
    [[FZWebServices sharedInstance] registerProfile:self.profile completionBlock:^(id result, NSError *error){
        
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            // TODO: show error message
        }
        else {
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            [self.profile populate:results[@"profile"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                FZPickPhotoViewController *pickPhotoVc = [[FZPickPhotoViewController alloc] init];
                [self.navigationController pushViewController:pickPhotoVc animated:YES];
            });
        }
        
    }];
}

- (void)updateProfile
{
    for (int i=0; i<self.attributes.count; i++) {
        int tag = 1000+i;
        UITextField *tf = (UITextField *)[self.scrollView viewWithTag:tag];
        if (tf){
            if (tag==1000){
                self.profile.fullname = tf.text;
            }
            if (tag==1001){
                self.profile.username = tf.text;
            }
            if (tag==1002){
                self.profile.password = tf.text;
            }
            if (tag==1003){
//                attribute = @"password confirm";
            }
            if (tag==1004){
                self.profile.email = tf.text;
            }
        }
    }
    
    [self checkIfCanRegister];

    
    // BIO:
    UITextView *tv = (UITextView *)[self.scrollView viewWithTag:(1000+self.attributes.count)];
    if (!tv)
        return;
    
    if (tv.text.length==0 || [tv.text isEqualToString:bioPlaceholder]==YES) {
        self.profile.bio = @"";
        return;
    }
    
    self.profile.bio = tv.text;
    
    
}

- (BOOL)checkIfCanRegister
{
    if (self.profile.username.length==0 || [self.profile.username isEqualToString:@"none"]==YES){
        self.canRegister = NO;
        return NO;
    }
    
    if ([self.profile.username.lowercaseString rangeOfCharacterFromSet:self.invalidCharacters].location != NSNotFound){
        NSLog(@"the string contains illegal characters");
        self.canRegister = NO;
        return NO;
    }
    
    
    if (self.profile.email.length==0 || [self.profile.email isEqualToString:@"none"]==YES){
        self.canRegister = NO;
        return NO;
    }
    
    if ([self isValidEmail:self.profile.email strict:YES]==NO){
        self.canRegister = NO;
        return NO;
    }

    
    if (self.profile.location.length==0 || [self.profile.location isEqualToString:@"none"]==YES){
        self.canRegister = NO;
        return NO;
    }
    
    if (self.profile.password.length==0 || [self.profile.password isEqualToString:@"none"]==YES){
        self.canRegister = NO;
        return NO;
    }
    
    if (self.profile.password.length < 6){
        self.canRegister = NO;
        return NO;
    }


    
    UITextField *passwordConfirmField = (UITextField *)[self.scrollView viewWithTag:1003];
    if ([self.profile.password isEqualToString:passwordConfirmField.text]==NO){
        self.canRegister = NO;
        return NO;
    }

    self.canRegister = YES;
    return YES;
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"manager didUpdateLocations:");
    
    static double minAccuracy = 75.0f;
    CLLocation *bestLocation = nil;
    for (CLLocation *location in locations) {
        if (([location.timestamp timeIntervalSince1970]-self.now) >= 0){
//            NSLog(@"LOCATION: %@, %.4f, %4f, ACCURACY: %.2f,%.2f", [location.timestamp description], location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, location.verticalAccuracy);
            
            if (location.horizontalAccuracy <= minAccuracy && location.horizontalAccuracy <= minAccuracy){
                [self.locationManager stopUpdatingLocation];
                self.locationManager.delegate = nil;
                bestLocation = location;
//                NSLog(@"FOUND BEST LOCATION!!");
                break;
            }
        }
    }
    
    if (bestLocation==nil) // couldn't find location to desired accuracy
        return;
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    self.profile.latitude = self.locationManager.location.coordinate.latitude;
    self.profile.longitude = self.locationManager.location.coordinate.longitude;
    
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) { //Getting Human readable Address from Lat long...
        
        [self.loadingIndicator stopLoading];
        if (placemarks.count > 0){
            UITextField *locationTextField = (UITextField *)[self.scrollView viewWithTag:1005];
            CLPlacemark *placeMark = placemarks[0];
            NSDictionary *locationInfo = placeMark.addressDictionary;
            NSLog(@"LOCATION: %@", [locationInfo description]);
            self.profile.location = (YES) ? locationInfo[@"SubLocality"] : locationInfo[@"City"];
            locationTextField.text = self.profile.location;
            [self checkIfCanRegister];
        }
        else{
            [self showAlertWithtTitle:@"Error" message:@"Could not find your location."];
        }
     }];
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    [self showAlertWithtTitle:@"Error" message:@"Failed to Get Your Location"];
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing: %d", textField.tag);
    if(textField.tag==1005){ // location field
        self.now = [[NSDate date] timeIntervalSince1970];
        [self shiftBack:64.0f];
        for (id textView in self.textViews)
            [textView resignFirstResponder];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        [self.loadingIndicator startLoading];
        
        return NO;
    }
    

    if (textField.tag >= 1000 && textField.tag <= 1001){
        [self shiftUp:80.0f];
    }
    

    
    if (textField.tag > 1001 && textField.tag < 1004){
        self.scrollView.delegate = nil;
        [self.scrollView setContentOffset:CGPointMake(0, 100.0f) animated:YES];
        [self performSelector:@selector(connectScrollViewDelegate) withObject:nil afterDelay:0.60f];
        [self shiftUp:116.0f];
    }
    
    if (textField.tag==1004){
        self.scrollView.delegate = nil;
        [self.scrollView setContentOffset:CGPointMake(0, 156.0f) animated:YES];
        [self performSelector:@selector(connectScrollViewDelegate) withObject:nil afterDelay:0.60f];
        [self shiftUp:132.0f];
    }
    
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textField shouldChangeCharactersInRange: %@", string);
    if (textField.tag==1001){ // check username character limit
        if (textField.text.length==30 && string.length>0){
            [self showAlertWithtTitle:@"Character Limit Reached" message:@"Please limit the username to 30 characters or less."];            return NO;
        }
    }

    [self performSelector:@selector(updateProfile) withObject:self afterDelay:0.1f];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:bioPlaceholder]){
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    self.scrollView.delegate = nil;
    [self.scrollView setContentOffset:CGPointMake(0, 540.0f) animated:YES];
    [self performSelector:@selector(connectScrollViewDelegate) withObject:nil afterDelay:0.60f];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    NSLog(@"textView shouldChangeTextInRange: %d", textView.tag);
    [self performSelector:@selector(updateProfile) withObject:self afterDelay:0.1f];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length==0) {
        textView.text = bioPlaceholder;
        textView.textColor = [UIColor lightGrayColor];
        self.profile.bio = @"";
    }
    
    return YES;
}


- (void)connectScrollViewDelegate
{
    self.scrollView.delegate = self;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll: ");
    [self shiftBack:64.0f];
    for (id textView in self.textViews)
        [textView resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
