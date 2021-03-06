//
//  FZPickPhotoViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/8/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZPickPhotoViewController.h"
#import "FZPickTagsViewController.h"
#import "FZSelectTwitterViewController.h"


@interface FZPickPhotoViewController ()
@property (strong, nonatomic) UIView *iconBase;
@property (strong, nonatomic) UIImageView *profileIcon;
//@property (strong, nonatomic) UITableView *twitterAccountsTable;
@property (nonatomic) BOOL requestTwitterAccess;
@end


#define kMaxDimen 84.0f

@implementation FZPickPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.requestTwitterAccess = NO;
        self.title = @"Choose Your Photo";
        [self.navigationItem setHidesBackButton:YES animated:NO];
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    UIImage *imageIcon = [UIImage imageNamed:@"photoPlaceholder.png"];
    self.iconBase = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageIcon.size.width, imageIcon.size.height)];
    self.iconBase.center = CGPointMake(0.5f*frame.size.width, 0.24f*frame.size.height);
    self.iconBase.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.iconBase.layer.cornerRadius = 0.5f*self.iconBase.frame.size.width;
    self.iconBase.layer.masksToBounds = YES;
    self.iconBase.backgroundColor = [UIColor lightGrayColor];

    if (self.profile.imageData){
        self.profileIcon = [[UIImageView alloc] initWithImage:self.profile.imageData];
        [self adjustProfileIcon];
    }
    else{
        self.profileIcon = [[UIImageView alloc] initWithImage:imageIcon];
        self.profileIcon.layer.cornerRadius = 0.5*imageIcon.size.height;
        self.profileIcon.layer.masksToBounds = YES;
        self.profileIcon.userInteractionEnabled = YES;
    }

    self.profileIcon.center = CGPointMake(0.5f*self.iconBase.frame.size.width, 0.5f*self.iconBase.frame.size.height);
    [self.profileIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhoto:)]];
    [self.profileIcon addObserver:self forKeyPath:@"image" options:0 context:nil];
    [self.iconBase addSubview:self.profileIcon];
    

    [view addSubview:self.iconBase];

    
    CGFloat y = 200.0f;
    NSArray *socialogins = [FZSocialButton socialNetworks];
    for (int i=0; i<socialogins.count-1; i++){ // ignore reddit button
        NSString *network = socialogins[i];
        FZSocialButton *btnLogin = [FZSocialButton buttonWithFrame:CGRectMake(0.0f, y, 242.f, 46.0f) socialNetwork:i];
        btnLogin.tag = 1000+i;
        btnLogin.center = CGPointMake(self.iconBase.center.x, y);
        [btnLogin addTarget:self action:@selector(selectSocialIcon:) forControlEvents:UIControlEventTouchUpInside];
        btnLogin.lblNetwork.text = [NSString stringWithFormat:@"Use my %@ Photo", network];
        [view addSubview:btnLogin];
        y += btnLogin.frame.size.height+10.0f;
    }

    
    CGFloat width = 80.0f;
    UIButton *btnGo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGo.backgroundColor = kOrange;
    btnGo.layer.cornerRadius = 4.0f;
    btnGo.layer.masksToBounds = YES;
    btnGo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnGo.frame = CGRectMake(frame.size.width-width-37.0f, y-20.0f, width, 44);
    [btnGo setTitle:@"Next" forState:UIControlStateNormal];
    [btnGo addTarget:self action:@selector(segueToPickTags) forControlEvents:UIControlEventTouchUpInside];
    [btnGo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:btnGo];
    
    self.view = view;
}

- (void)dealloc
{
    [self.profileIcon removeObserver:self forKeyPath:@"image"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(segueToPickTags)];

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
    
    if (!self.requestTwitterAccess)
        return;
    
    self.requestTwitterAccess = NO;
    [self.profile requestTwitterProfileInfo:self.socialAccountsMgr.selectedTwitterAccount completion:^(BOOL success, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            if (success){
                [self requestTwitterProfilePic];
            }
            else{
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
        });
        
    }];
    
    
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]==NO)
         return;
    
    [self adjustProfileIcon];
    [UIView transitionWithView:self.profileIcon
                      duration:0.6f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.profileIcon.alpha = 1.0f;
                    }
                    completion:NULL];
}


- (void)adjustProfileIcon
{
    if (!self.profile.imageData)
        return;
    
    UIImage *imageIcon = [UIImage imageNamed:@"photoPlaceholder.png"];
    CGFloat w = self.profile.imageData.size.width;
    CGFloat h = self.profile.imageData.size.height;
    
    double scale = 0.0f;
    if (w != imageIcon.size.width){
        scale = imageIcon.size.width/w;
        w = imageIcon.size.width;
        h *= scale;
    }
    if (h < imageIcon.size.height){
        scale = imageIcon.size.height/h;
        h = imageIcon.size.height;
        w *= scale;
    }
    
    CGRect iconFrame = self.profileIcon.frame;
    iconFrame.size.width = w;
    iconFrame.size.height = h;
    self.profileIcon.frame = iconFrame;
    self.profileIcon.center = CGPointMake(0.5f*self.iconBase.frame.size.width, 0.5f*self.iconBase.frame.size.height);
    
}



- (void)selectPhoto:(UIGestureRecognizer *)tap
{
    NSLog(@"selectPhoto:");
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"photo library", @"take photo", nil];
    actionsheet.frame = CGRectMake(0, 150, self.view.frame.size.width, 100);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];

}

- (void)launchImageSelector:(UIImagePickerControllerSourceType)sourceType
{
    [self.loadingIndicator startLoading];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.loadingIndicator stopLoading];
    }];
}


- (void)requestTwitterProfilePic
{
    
    [self.profile requestTwitterProfilePic:^(BOOL success, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
        }
        else{
            self.profileIcon.image = self.profile.imageData;
        }
    }];

}

- (void)requestLinkedinProfilePic
{
    
    [self.profile requestLinkedinProfilePic:^(BOOL success, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
        }
        else{
            self.profileIcon.image = self.profile.imageData;
        }
    }];
}

- (void)requestGoogleProfilePic
{
    [self.loadingIndicator startLoading];
    [self.profile requestGooglePlusProfilePic:^(BOOL success, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
        }
        else{
            self.profileIcon.image = self.profile.imageData;
        }
    }];

}


- (void)selectSocialIcon:(UIButton *)btn
{
    int tag = (int)btn.tag;
    NSLog(@"selectSocialIcon: %d", tag);
    
    if (tag==1000){ // Facebook
        
        // check if profile has facebook ID first
        if ([self.profile.facebookId isEqualToString:@"none"]==NO){
            [self.profile requestFacebookProfilePic:^(BOOL success, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.profileIcon.image = self.profile.imageData;
                });
                
            }];

            return;
        }
        
        // Request Access - this would happen if the user registered via email/twitter/etc then decided to use FB profile pic:
        [self.loadingIndicator startLoading];
        [self.socialAccountsMgr requestFacebookAccess:kFacebookPermissions completionBlock:^(id result, NSError *error){
            
            if (error){
                [self.loadingIndicator stopLoading];
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
            else{
                NSLog(@"FACEBOOK ACCESS GRANTED!!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.profile getFacebookInfo:^(BOOL success, NSError *error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.loadingIndicator stopLoading];
                            if (success){
                                
                                [self.profile requestFacebookProfilePic:^(BOOL success, NSError *error){
                                    self.profileIcon.image = self.profile.imageData;
                                }];
                            }
                            else{
                                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                                
                            }
                        });
                        
                    }];
                });
            }
        }];

    }
    
    if (tag==1001){
        if ([self.profile.twitterId isEqualToString:@"none"]==NO && [self.profile.twitterImage isEqualToString:@"none"]==NO){
            [self requestTwitterProfilePic];
            return;
        }
        
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
                    ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[0];
                    [self.profile requestTwitterProfileInfo:twitterAccount completion:^(BOOL success, NSError *error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.loadingIndicator stopLoading];
                            if (success){
                                [self requestTwitterProfilePic];
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
    
    
    if (tag==1002){ // google plus
        if ([self.profile.googleId isEqualToString:@"none"]==NO && [self.profile.googleImage isEqualToString:@"none"]==NO){
            [self requestGoogleProfilePic];
            return;
        }
        
        [self.socialAccountsMgr requestGooglePlusAccess:@[@"profile"] completion:^(id result, NSError *error){
            if (error){
                [self.loadingIndicator stopLoading];
                NSLog(@"GOOGLE PLUS LOGIN FAILED");
                
            }
            else {
                GTMOAuth2Authentication *auth = (GTMOAuth2Authentication *)result;
                
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
                        [self requestGoogleProfilePic];
                        
                    }];
                });
                
            }
        }];
        
        
        
    }
    
    
    
    
    
    if (tag==1003){ // linked in
        if ([self.profile.linkedinId isEqualToString:@"none"]==NO && [self.profile.linkedinImage isEqualToString:@"none"]==NO){
            [self requestLinkedinProfilePic];
            return;
        }
        
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
                
                [self requestLinkedinProfilePic];
                
                
            }
            
            
        }];
    }
    
    if (tag==1004){ // meetup
        
        
        
    }


}

- (void)uploadProfileImage:(NSString *)uploadUrl
{
    NSData *imgData = UIImageJPEGRepresentation(self.profile.imageData, 0.5f);
    
    [[FZWebServices sharedInstance] uploadImage:@{@"data":imgData, @"name":@"image.jpg"} toUrl:uploadUrl completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
        }
        else {
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            NSString *confirmation = results[@"confirmation"];
            
            if ([confirmation isEqualToString:@"success"]==YES){
                NSDictionary *imageInfo = results[@"image"];
                self.profile.image = imageInfo[@"id"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    FZPickTagsViewController *pickTagsVc = [[FZPickTagsViewController alloc] init];
                    UINavigationController *tagsNavCtr = [[UINavigationController alloc] initWithRootViewController:pickTagsVc];
                    tagsNavCtr.navigationBarHidden = YES;
                    [self presentViewController:tagsNavCtr animated:YES completion:NULL];
                });
                
            }
            else{
                [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            }
        }
    }];
    
}


- (void)segueToPickTags
{
    // check for photo first:
    
    if (self.profile.imageData){
        NSLog(@"UPLOAD PHOTO");
        
        [self.loadingIndicator startLoading];
        [[FZWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            
            if (error){
                [self.loadingIndicator stopLoading];
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
            }
            else{
                NSDictionary *results = (NSDictionary *)result;
                NSLog(@"%@", [results description]);
                NSString *confirmation = results[@"confirmation"];
                if ([confirmation isEqualToString:@"success"]){
                    NSString *upload = results[@"upload"];
                    [self uploadProfileImage:upload];
                }
                else{
                    [self showAlertWithtTitle:@"Error" message:results[@"message"]];
                }
            }
        }];
        
        return;
    }
    
    FZPickTagsViewController *pickTagsVc = [[FZPickTagsViewController alloc] init];
    UINavigationController *tagsNavCtr = [[UINavigationController alloc] initWithRootViewController:pickTagsVc];
    tagsNavCtr.navigationBarHidden = YES;
    [self presentViewController:tagsNavCtr animated:YES completion:NULL];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex==0){
        [self launchImageSelector:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if (buttonIndex==1){
        [self launchImageSelector:UIImagePickerControllerSourceTypeCamera];
    }
    
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: didFinishPickingMediaWithInfo: %@", [info description]);
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
//    CGFloat w = image.size.width;
//    CGFloat h = image.size.height;
//    if (w != h)
//        image = [self cropImage:image];
    
    self.profileIcon.image = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //    NSLog(@"imagePickerControllerDidCancel:");
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


- (UIImage *)cropImage:(UIImage *)image
{
    NSLog(@"cropImage:");
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (w != h){
        CGFloat dimen = (w < h) ? w : h;
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0.5*(image.size.width-dimen), 0.5*(image.size.height-dimen), dimen, dimen));
        image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.5f)];
        CGImageRelease(imageRef);
    }

    return image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
