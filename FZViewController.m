//
//  FZViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZViewController.h"

@interface FZViewController ()

@end

@implementation FZViewController
@synthesize profile;
@synthesize loadingIndicator;
@synthesize socialAccountsMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.profile = [FZProfile sharedProfile];
        self.socialAccountsMgr = [FZSocialAccountsMgr sharedAccountManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingIndicator = [[FZLoadingIndicator alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    self.loadingIndicator.alpha = 0.0f;
    [self.view addSubview:self.loadingIndicator];

}

- (UIView *)baseView:(BOOL)navCtr
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.x = 0.0f;
    frame.origin.y = 0.0f;
    if (navCtr){
        
        // account for nav bar height, only necessary in iOS 7!
        frame.size.height -= 44.0f;
        
        [self.navigationController.navigationBar setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
          NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
        
    }
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    return view;
}

- (void)shiftUp:(CGFloat)distance
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = -distance;
                         self.view.frame = frame;
                     }
                     completion:NULL];
}

- (void)shiftBack:(CGFloat)origin
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = origin; // accounts for nav bar
                         self.view.frame = frame;
                     }
                     completion:NULL];
    
}



#pragma mark - Alert
- (void)showAlertWithtTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)showAlertWithOptions:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
