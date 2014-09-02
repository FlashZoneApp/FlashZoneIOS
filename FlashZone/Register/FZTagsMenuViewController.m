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
        
        [self.tagsList addObject:@"#cartoonists"];
        [self.tagsList addObject:@"#YOLO"];
        [self.tagsList addObject:@"#TheNewYorkYankees"];
        [self.tagsList addObject:@"#ILoveNY"];
        [self.tagsList addObject:@"#VintageThriftShop"];
        [self.tagsList addObject:@"#BeltParkwayTraffic"];
        [self.tagsList addObject:@"#Coffee"];
        [self.tagsList addObject:@"#WebDesigner"];
        [self.tagsList addObject:@"#NewYorkCityNightlife"];
        [self.tagsList addObject:@"#Baseball"];
        [self.tagsList addObject:@"#ThisWeekend"];
        [self.tagsList addObject:@"#Photographer"];

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

    static CGFloat h = 36.0f;
    CGFloat y = 60.0f;
    CGFloat x = 0.0f;
    BOOL nextLine = NO;
    
    for (int i=0; i<self.tagsList.count; i++) {
        NSString *tag = self.tagsList[i];
        FZButtonTag *btnTag = [FZButtonTag buttonWithType:UIButtonTypeCustom];
        [btnTag setTitle:[NSString stringWithFormat:@" %@", tag] forState:UIControlStateNormal];

        CGRect boudingRect = [tag boundingRectWithSize:CGSizeMake(160.0f, 250.0f)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:btnTag.titleLabel.font}
                                                        context:NULL];

        if (x==0.0)
            x = 10+arc4random()%130;
        
        btnTag.frame = CGRectMake(x, y, boudingRect.size.width+36.0f, h);
        btnTag.layer.cornerRadius = 0.5f*h;
        [view addSubview:btnTag];
        NSLog(@"%@ == %.2f", tag, btnTag.center.x);
        
        if (btnTag.center.x > 140.0f){
            nextLine = YES;
            x = 0.0f;
        }
        else{
            x = btnTag.frame.origin.x+btnTag.frame.size.width+10.0f;
        }
        
        if (nextLine){
            y += h+10.0f;
            nextLine = NO;
        }
    }

    
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
