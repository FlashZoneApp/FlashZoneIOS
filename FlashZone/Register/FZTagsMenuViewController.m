//
//  FZTagsMenuViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZTagsMenuViewController.h"
#import "FZButtonTag.h"
#import "UIColor+FZColorAdditions.h"


@interface FZTagsMenuViewController ()
@property (strong, nonatomic) UIView *screen;
@property (strong, nonatomic) UIButton *btnShowMore;
@property (strong, nonatomic) UIView *cover;
@property (strong, nonatomic) UILabel *lblConfirmation;
@property (copy, nonatomic) NSString *category;
@end

@implementation FZTagsMenuViewController
@synthesize blurryBackground;
@synthesize backgroundImage;
@synthesize useSocialNetwork;
@synthesize screenColor;
@synthesize lblCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.useSocialNetwork = YES;
        
    }
    return self;
}

- (id)initWithCategory:(NSString *)category
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.useSocialNetwork = NO;
        self.category = category;
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor colorWithPatternImage:self.backgroundImage];
    
    
    
    self.blurryBackground = [[UIImageView alloc] initWithImage:[backgroundImage applyBlurOnImage:0.45f]];
    self.blurryBackground.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.blurryBackground.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if (self.useSocialNetwork)
        self.blurryBackground.alpha = 0.0f;
    
    [view addSubview:self.blurryBackground];
    
    NSString *icon = @"";
    if (self.useSocialNetwork){
        if (self.profile.registrationType==FZRegistrationTypeFacebook){
            icon = @"iconFacebook.png";
            self.screenColor = [UIColor colorFromHexString:kFacebookBlue];
        }
        if (self.profile.registrationType==FZRegistrationTypeTwitter){
            icon = @"iconTwitter.png";
            self.screenColor = [UIColor colorFromHexString:kTwitterBlue];
        }
        if (self.profile.registrationType==FZRegistrationTypeGoogle){
            icon = @"iconGoogle.png";
            self.screenColor = [UIColor colorFromHexString:kGoogleRed];
        }
        if (self.profile.registrationType==FZRegistrationTypeReddit){
            icon = @"iconReddit.png";
            self.screenColor = [UIColor colorFromHexString:kRedditRed];
        }
        if (self.profile.registrationType==FZRegistrationTypeLinkedIn){
            icon = @"iconLinkedin.png";
            self.screenColor = [UIColor colorFromHexString:kLinkedinBlue];
        }
    }
    

    self.screen = [[UIView alloc] initWithFrame:frame];
    self.screen.backgroundColor = self.screenColor;
    self.screen.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (self.useSocialNetwork)
        self.screen.alpha = 0.0f;
    
    [view addSubview:self.screen];
    
    UIImageView *networkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    networkIcon.center = CGPointMake(0.5f*frame.size.width, 36.0f);
    [view addSubview:networkIcon];
    
    
    self.lblCategory = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 22.0f)];
    self.lblCategory.center = networkIcon.center;
    self.lblCategory.textColor = [UIColor whiteColor];
    self.lblCategory.textAlignment = NSTextAlignmentCenter;
    self.lblCategory.font = [UIFont boldSystemFontOfSize:14.0f];
    self.lblCategory.text = self.category;
    [view addSubview:self.lblCategory];

    
    UILabel *lblDirections = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 54.0f, frame.size.width, 24.0f)];
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
    
    self.cover = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.cover.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.cover.backgroundColor = kOrange;
    self.cover.alpha = 0.0f;
    
    self.lblConfirmation = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, -22.0f, frame.size.width, 22.0f)];
    self.lblConfirmation.textAlignment = NSTextAlignmentCenter;
    self.lblConfirmation.textColor = [UIColor whiteColor];
    self.lblConfirmation.font = [UIFont boldSystemFontOfSize:20.0f];
    self.lblConfirmation.text = @"Flashtags Added";
    [self.cover addSubview:self.lblConfirmation];
    
    [view addSubview:self.cover];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.profile.suggestedTags.count > 0){
        [self layoutTags];
        return;
    }

    // fetch suggested tags:
    [self.loadingIndicator startLoading];
    [[FZWebServices sharedInstance] fetchInterests:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            NSString *confirmation = results[@"confirmation"];
            if ([confirmation isEqualToString:@"success"]){
                
                NSArray *tags = results[@"interests"];
                for (int i=0; i<tags.count; i++){
                    NSString *tag = tags[i];
                    [self.profile.suggestedTags addObject:tag];
                }
                
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
                         self.screen.alpha = (self.useSocialNetwork) ? 1.0f : 0.60f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)layoutTags
{
    CGRect frame = self.view.frame;
    
    CGFloat h = 36.0f;
    CGFloat y = 94.0f;
    CGFloat x = 0.0f;
    BOOL nextLine = NO;
    
    for (int i=0; i<self.profile.suggestedTags.count; i++) {
        NSDictionary *tag = self.profile.suggestedTags[i];
        NSString *tagName = tag[@"name"];
        FZButtonTag *btnTag = [FZButtonTag buttonWithType:UIButtonTypeCustom];
        btnTag.tag = 1000+i;
        [btnTag setTitle:[NSString stringWithFormat:@"  #%@", tagName] forState:UIControlStateNormal];
        [btnTag addTarget:self action:@selector(pickTag:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect boudingRect = [tagName boundingRectWithSize:CGSizeMake(160.0f, 250.0f)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:btnTag.titleLabel.font}
                                                   context:NULL];
        
        if (x==0.0)
            x = 10+arc4random()%130;
        
        btnTag.frame = CGRectMake(x, y, boudingRect.size.width+44.0f, h);
        btnTag.layer.cornerRadius = 0.5f*h;
        [self.view addSubview:btnTag];
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
//    self.tagsScrollview.contentSize = CGSizeMake(0, h);
    
    if (h+44.0f < frame.size.height)
        h = frame.size.height;
    
    if (self.btnShowMore==nil) {
        self.btnShowMore = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnShowMore.backgroundColor = [UIColor clearColor];
        self.btnShowMore.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.btnShowMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnShowMore setTitle:@"Show more" forState:UIControlStateNormal];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1.0f)];
        line.backgroundColor = [UIColor whiteColor];
        [self.btnShowMore addSubview:line];
        
        
        UIImageView *reload = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconReload.png"]];
        reload.center = CGPointMake(0.7f*frame.size.width, 22.0f);
        [self.btnShowMore addSubview:reload];
        
        [self.view addSubview:self.btnShowMore];
    }
    
    
    self.btnShowMore.frame = CGRectMake(0.0f, h-44.0f, frame.size.width, 44.0f);
    
    [self.view bringSubviewToFront:self.cover];
}

- (void)pickTag:(UIButton *)btn
{
    int index = (int)btn.tag-1000;
    NSDictionary *flashTag = self.profile.suggestedTags[index];
    btn.selected = !btn.selected;
    btn.backgroundColor = (btn.selected) ? kOrange : [UIColor whiteColor];
    
    if (btn.selected)
        [self.profile.tags addObject:flashTag];
    else
        [self.profile.tags removeObject:flashTag];
    
    NSLog(@"CURRENT TAGS: %@", [self.profile.tags description]);
    
}

- (void)exit
{
    [UIView animateWithDuration:0.75f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cover.alpha = 1.0f;
                         CGPoint center = self.lblConfirmation.center;
                         center.y = 0.5f*self.view.frame.size.height;
                         self.lblConfirmation.center = center;
                     }
                     completion:^(BOOL finished){
                         [self.navigationController popViewControllerAnimated:NO];
                     }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
