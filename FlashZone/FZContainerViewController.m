//
//  FZContainerViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 7/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZContainerViewController.h"
#import "FZSignupViewController.h"

@interface FZContainerViewController ()
@property (strong, nonatomic) UINavigationController *profileNavCtr;
@end

@implementation FZContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor yellowColor];
    
    
    // Home:
    FZViewController *profileVc = [[FZViewController alloc] init];
    profileVc.view.backgroundColor = [UIColor blueColor];
    self.profileNavCtr = [[UINavigationController alloc] initWithRootViewController:profileVc];
    
    /*
    // Notifications:
    UCNotificationsViewController *notificationsVc = [[UCNotificationsViewController alloc] init];
    UCNavigationController *notificationsNavCtr = [UCNavigationController navigationControllerWithBarColor:kBlue rootVC:notificationsVc];
    
    // Places:
    UCPlacesViewController *placesVC = [[UCPlacesViewController alloc] init];
    UCNavigationController *placesNavCtr = [[UCNavigationController alloc] initWithRootViewController:placesVC];
    
    // Messages:
    UCMessagesViewController *messagesVc = [[UCMessagesViewController alloc] init];
    UCNavigationController *messagesNavCtr = [[UCNavigationController alloc] initWithRootViewController:messagesVc];
    
    // Profile:
    UCProfileSectionsViewController *profileSectionsVc = [[UCProfileSectionsViewController alloc] init];
    UCNavigationController *profileNavCtr = [UCNavigationController navigationControllerWithBarColor:kBlue rootVC:profileSectionsVc];
    
    UITabBarController *tabCtr = [[UITabBarController alloc] init];
    tabCtr.viewControllers = @[homeNavCtr, placesNavCtr, messagesNavCtr, profileNavCtr];
    CGRect tabFrame = tabCtr.view.frame;
    tabFrame.size.height -= 20.0f; // accounts for status bar
    tabCtr.view.frame = tabFrame;
    [[UITabBar appearance] setTintColor:kBlue];
     
     */

    
    [self addChildViewController:self.profileNavCtr];
    [self.profileNavCtr willMoveToParentViewController:self];
    [view addSubview:self.profileNavCtr.view];
    
    self.view = view;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    if (self.profile.populated) // profile cached
        return;
    
    FZSignupViewController *signupVc = [[FZSignupViewController alloc] init];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:signupVc];
    navCtr.navigationBar.tintColor = [UIColor whiteColor];
    navCtr.navigationBar.barTintColor = kOrange;
    navCtr.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:navCtr.navigationBar.tintColor};

    [navCtr setNavigationBarHidden:YES];
    
    [self.profileNavCtr presentViewController:navCtr animated:NO completion:NULL];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
