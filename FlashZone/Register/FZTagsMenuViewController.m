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
@property (strong, nonatomic) UIScrollView *tagsScrollview;
@property (strong, nonatomic) UIButton *btnShowMore;
@end

@implementation FZTagsMenuViewController
@synthesize blurryBackground;
@synthesize backgroundImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.tagsList = [NSMutableArray arrayWithArray:self.profile.tags];
//        self.profile.tags = [NSMutableArray array];
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
    
    
    self.tagsScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.tagsScrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UILabel *lblDirections = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, frame.size.width, 24.0f)];
    lblDirections.textColor = [UIColor whiteColor];
    lblDirections.textAlignment = NSTextAlignmentCenter;
    lblDirections.text = @"Tap a few things you like";
    [self.tagsScrollview addSubview:lblDirections];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setTitleColor:kOrange forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
    btnNext.frame = CGRectMake(frame.size.width-80.0f, 24.0f, 80.0f, 24.0f);
    [self.tagsScrollview addSubview:btnNext];
    
    [self layoutTags];

    [view addSubview:self.tagsScrollview];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.profile.tags.count > 0){
        self.tagsList = [NSMutableArray arrayWithArray:self.profile.tags];
        self.profile.tags = [NSMutableArray array];
        [self layoutTags];
        return;
    }

    
    [[FZWebServices sharedInstance] fetchFlashTags:^(id result, NSError *error){
        if (error){
            
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            NSString *confirmation = results[@"confirmation"];
            if ([confirmation isEqualToString:@"success"]){
                
                self.tagsList = [NSMutableArray array];
                NSArray *tags = results[@"flashTags"];
                for (int i=0; i<tags.count; i++){
                    NSString *tag = tags[i];
                    [self.tagsList addObject:tag];
                }
                
                NSLog(@"TAGS LIST: %@", [self.tagsList description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self layoutTags];
                });
            }
            else{
                [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            }
            
            
        }
        
    }];
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

- (void)layoutTags
{
    CGRect frame = self.tagsScrollview.frame;
    
    CGFloat h = 36.0f;
    CGFloat y = 60.0f;
    CGFloat x = 0.0f;
    BOOL nextLine = NO;
    
    for (int i=0; i<self.tagsList.count; i++) {
        NSDictionary *tag = self.tagsList[i];
        NSString *tagName = tag[@"name"];
        FZButtonTag *btnTag = [FZButtonTag buttonWithType:UIButtonTypeCustom];
        btnTag.tag = 1000+i;
        [btnTag setTitle:[NSString stringWithFormat:@" #%@", tagName] forState:UIControlStateNormal];
        [btnTag addTarget:self action:@selector(pickTag:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect boudingRect = [tagName boundingRectWithSize:CGSizeMake(160.0f, 250.0f)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:btnTag.titleLabel.font}
                                                   context:NULL];
        
        if (x==0.0)
            x = 10+arc4random()%130;
        
        btnTag.frame = CGRectMake(x, y, boudingRect.size.width+36.0f, h);
        btnTag.layer.cornerRadius = 0.5f*h;
        [self.tagsScrollview addSubview:btnTag];
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
    
    h = y+100.0f;
    self.tagsScrollview.contentSize = CGSizeMake(0, h);
    
    if (h+44.0f < frame.size.height)
        h = frame.size.height;
    
    if (self.btnShowMore==nil) {
        self.btnShowMore = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnShowMore.backgroundColor = [UIColor clearColor];
        [self.btnShowMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnShowMore setTitle:@"Show more" forState:UIControlStateNormal];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1.0f)];
        line.backgroundColor = [UIColor whiteColor];
        [self.btnShowMore addSubview:line];
        [self.tagsScrollview addSubview:self.btnShowMore];
    }
    
    
    self.btnShowMore.frame = CGRectMake(0.0f, h-44.0f, frame.size.width, 44.0f);
}

- (void)pickTag:(UIButton *)btn
{
    int index = (int)btn.tag-1000;
    NSDictionary *flashTag = self.tagsList[index];
    NSLog(@"pickTag: %@", flashTag[@"name"]);
    btn.selected = !btn.selected;
    btn.backgroundColor = (btn.selected) ? kOrange : [UIColor whiteColor];
    
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
