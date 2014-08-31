//
//  FZTagsMenuViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZTagsMenuViewController.h"


@interface FZTagsMenuViewController ()
@property (strong, nonatomic) NSMutableArray *tagsList;
@end

@implementation FZTagsMenuViewController

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
    view.backgroundColor = [UIColor greenColor];
    
    UILabel *lblDirections = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, frame.size.width, 24.0f)];
    lblDirections.textColor = [UIColor whiteColor];
    lblDirections.textAlignment = NSTextAlignmentCenter;
    lblDirections.text = @"Tap a few things you like";
    [view addSubview:lblDirections];

    
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
