//
//  FZTagsMenuViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZTagsMenuViewController.h"
#import "FZButtonTag.h"


@interface FZTagsMenuViewController ()
@property (strong, nonatomic) NSMutableArray *tagsList;
@property (strong, nonatomic) UIView *screen;
@end

@implementation FZTagsMenuViewController
@synthesize blurryBackground;
@synthesize backgroundImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tagsList = [NSMutableArray array];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    CGRect frame = view.frame;
    
    view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    self.blurryBackground = [[UIImageView alloc] initWithImage:[backgroundImage applyBlurOnImage:0.45f]];
    self.blurryBackground.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.blurryBackground.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.blurryBackground.alpha = 0.0f;
    [view addSubview:self.blurryBackground];

    self.screen = [[UIView alloc] initWithFrame:frame];
    self.screen.backgroundColor = [UIColor blackColor];
    self.screen.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.screen.alpha = 0.0f;
    [view addSubview:self.screen];
    
    UILabel *lblDirections = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, frame.size.width, 24.0f)];
    lblDirections.textColor = [UIColor whiteColor];
    lblDirections.textAlignment = NSTextAlignmentCenter;
    lblDirections.text = @"Tap a few things you like";
    [view addSubview:lblDirections];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setTitleColor:kOrange forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
    btnNext.frame = CGRectMake(frame.size.width-80.0f, 24.0f, 80.0f, 24.0f);
    [view addSubview:btnNext];

    
    FZButtonTag *btnTag = [FZButtonTag buttonWithType:UIButtonTypeCustom];
    btnTag.backgroundColor = [UIColor whiteColor];
    btnTag.frame = CGRectMake(20.0f, 50.0f, 120.0f, 36.0f);
    btnTag.layer.cornerRadius = 0.5f*btnTag.frame.size.height;
    [view addSubview:btnTag];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.blurryBackground.alpha = 1.0f;
                         self.screen.alpha = 0.60f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)exit
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
