//
//  FZForgotPasswordViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/3/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZForgotPasswordViewController.h"

@interface FZForgotPasswordViewController ()

@end

@implementation FZForgotPasswordViewController

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
    view.backgroundColor = kOrange;
//    CGRect frame = view.frame;
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
