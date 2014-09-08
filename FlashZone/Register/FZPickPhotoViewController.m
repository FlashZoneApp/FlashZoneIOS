//
//  FZPickPhotoViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/8/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZPickPhotoViewController.h"
#import "FZPickTagsViewController.h"



@interface FZPickPhotoViewController ()
@property (strong, nonatomic) UIImageView *photoIcon;
@property (strong, nonatomic) UITableView *twitterAccountsTable;
@end


#define kMaxDimen 84.0f

@implementation FZPickPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    UIScrollView *theScrollview = [[UIScrollView alloc] init];
    theScrollview.frame = frame;
    theScrollview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    
    UIImage *imageIcon = [UIImage imageNamed:@"photoPlaceholder.png"];
    
    if (self.profile.imageData){
        self.photoIcon = [[UIImageView alloc] initWithImage:self.profile.imageData];
        CGRect iconFrame = self.photoIcon.frame;
        CGFloat maxWidth = imageIcon.size.width;
        if (iconFrame.size.width > maxWidth) {
            double scale = maxWidth/iconFrame.size.width;
            iconFrame.size.width = maxWidth;
            iconFrame.size.height *= scale;
            self.photoIcon.frame = iconFrame;
        }
    }
    else{
        self.photoIcon = [[UIImageView alloc] initWithImage:imageIcon];
        self.photoIcon.layer.cornerRadius = 0.5*imageIcon.size.height;
        self.photoIcon.layer.masksToBounds = YES;
        self.photoIcon.userInteractionEnabled = YES;
    }

    self.photoIcon.center = CGPointMake(0.5f*frame.size.width, 0.24f*frame.size.height);
    self.photoIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.photoIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhoto:)]];
    [self.photoIcon addObserver:self forKeyPath:@"image" options:0 context:nil];
    [theScrollview addSubview:self.photoIcon];
    
//    NSArray *buttons = @[@"btnPhotoFb.png", @"btnPhotoTwitter.png", @"btnPhotoLinkedin.png", @"btnPhotoGoogle.png", @"btnPhotoMeetup.png"];
    CGFloat y = self.photoIcon.frame.origin.y+self.photoIcon.frame.size.height+30.0f;
    NSArray *buttons = @[@"Facebook", @"Twitter", @"Google", @"Linkedin", @"Reddit"];
    for (int i=0; i<buttons.count; i++) {
        NSString *network = buttons[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1000+i;
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        UIImage *btnImage = [UIImage imageNamed:[NSString stringWithFormat:@"btn%@.png", network]];
        [button setBackgroundImage:btnImage forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"            Use my %@ Photo", network] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, btnImage.size.width, btnImage.size.height);
        button.center = CGPointMake(self.photoIcon.center.x, y);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [button addTarget:self action:@selector(selectSocialIcon:) forControlEvents:UIControlEventTouchUpInside];
        [theScrollview addSubview:button];
        y += button.frame.size.height+12.0f;
    }

    
    CGFloat width = 80.0f;
    UIButton *btnGo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGo.backgroundColor = kOrange;
    btnGo.layer.cornerRadius = 4.0f;
    btnGo.layer.masksToBounds = YES;
    btnGo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnGo.frame = CGRectMake(frame.size.width-width-20.0f, y, width, 44);
    [btnGo setTitle:@"Go" forState:UIControlStateNormal];
    [btnGo addTarget:self action:@selector(segueToPickTags) forControlEvents:UIControlEventTouchUpInside];
    [btnGo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [theScrollview addSubview:btnGo];

    
    theScrollview.contentSize = CGSizeMake(0, 568.0f); // iPhone 5 height
    theScrollview.scrollEnabled = !(frame.size.height > 500);
    
    [view addSubview:theScrollview];
    
    
    self.twitterAccountsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.twitterAccountsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.twitterAccountsTable.dataSource = self;
    self.twitterAccountsTable.delegate = self;
    self.twitterAccountsTable.alpha = 0;
    [view addSubview:self.twitterAccountsTable];

    
    self.view = view;
}

- (void)dealloc
{
    [self.photoIcon removeObserver:self forKeyPath:@"image"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(segueToPickTags)];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]==NO)
         return;
    
    [UIView transitionWithView:self.photoIcon
                      duration:0.6f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.photoIcon.alpha = 1.0f;
                    }
                    completion:NULL];
}

- (void)resizeProfileIcon
{
    CGRect iconFrame = self.photoIcon.frame;
    if (self.profile.imageData.size.width > kMaxDimen) {
        double scale = kMaxDimen/self.profile.imageData.size.width;
        iconFrame.size.width = kMaxDimen;
        iconFrame.size.height = scale*self.profile.imageData.size.height;
    }
    
    if (self.profile.imageData.size.height > kMaxDimen) {
        double scale = kMaxDimen/self.profile.imageData.size.height;
        iconFrame.size.height = kMaxDimen;
        iconFrame.size.width = scale*self.profile.imageData.size.width;
    }
    
    iconFrame.origin.y = 54.0f;
    self.photoIcon.frame = iconFrame;
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
            self.photoIcon.image = self.profile.imageData;
            [self resizeProfileIcon];
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
            self.photoIcon.image = self.profile.imageData;
            [self resizeProfileIcon];
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
                    self.photoIcon.image = self.profile.imageData;
                    [self resizeProfileIcon];
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
                                    self.photoIcon.image = self.profile.imageData;
                                    [self resizeProfileIcon];
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
                        [self showAlertWithtTitle:@"Select Account" message:@"We found multiple Twitter accounts associated with this device. Please select one"];
                        [self.twitterAccountsTable reloadData];
                        self.twitterAccountsTable.alpha = 1.0f;
                    });
                }
                else{
                    ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[0];
                    [self.profile requestTwitterProfileInfo:twitterAccount completion:^(BOOL success, NSError *error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.loadingIndicator stopLoading];
                            if (success){
                                self.twitterAccountsTable.alpha = 0;
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
    
    
    if (tag==1002){ // linked in
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
                    if ([self.profile.tags containsObject:industry]==NO)
                        [self.profile.tags addObject:industry];
                }
                
                if (linkedInInfo[@"interests"]){
                    NSString *interests = linkedInInfo[@"interests"]; // comma separated string
                    NSArray *a = [interests componentsSeparatedByString:@","];
                    
                    for (int i=0; i<a.count; i++){
                        NSString *interest = a[i];
                        interest = [interest stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([self.profile.tags containsObject:interest]==NO)
                            [self.profile.tags addObject:interest];
                    }
                }

                [self requestLinkedinProfilePic];

                
//                self.profile.registrationType = FZRegistrationTypeLinkedIn;
//                [self showProfileDetailsScreen];
            }
            
            
        }];
    }
    
    
    if (tag==1003){ // google plus
        
        
        
    }
    
    if (tag==1004){ // meetup
        
        
        
    }


}


- (void)segueToPickTags
{
    FZPickTagsViewController *pickTagsVc = [[FZPickTagsViewController alloc] init];
    UINavigationController *tagsNavCtr = [[UINavigationController alloc] initWithRootViewController:pickTagsVc];
    tagsNavCtr.navigationBarHidden = YES;
    [self presentViewController:tagsNavCtr animated:YES completion:NULL];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", buttonIndex);
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
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (w != h)
        image = [self cropImage:image];
    
    self.photoIcon.image = image;
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



#pragma mark = UITableViewDataSource
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
    [self.loadingIndicator startLoading];
    
    [self.profile requestTwitterProfileInfo:twitterAccount completion:^(BOOL success, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            if (success){
                self.twitterAccountsTable.alpha = 0;
                [self requestTwitterProfilePic];


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
