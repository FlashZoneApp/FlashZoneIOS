//
//  FZTagsIntroView.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZTagsIntroView.h"

@interface FZTagsIntroView ()
@property (strong, nonatomic) UIImageView *pulse;
@property (strong, nonatomic) NSMutableArray *userPopups;
@property (strong, nonatomic) UILabel *lblCoffee;
@end


@implementation FZTagsIntroView
@synthesize btnNext;
@synthesize btnGotit;
@synthesize profileIcon;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userPopups = [NSMutableArray array];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_select_tags1.png"]];
        
        self.btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
        self.btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
        self.btnNext.frame = CGRectMake(frame.size.width-80, 24, 80, 24.0f);
        [self addSubview:self.btnNext];
        
        CGPoint ctr = CGPointMake(0.5f*frame.size.width, 150.0f);
        self.pulse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pulse.png"]];
        self.pulse.transform = CGAffineTransformMakeScale(0.25f, 0.25f);
        self.pulse.alpha = 0.0f;
        self.pulse.center = ctr;
        [self addSubview:self.pulse];
        
        for (int i=0; i<2; i++) {
            UIImageView *userPopup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"user-popup0%d.png", (i+1)]]];
            userPopup.center = ctr;
            userPopup.alpha = 0.0f;
            [self addSubview:userPopup];
            [self.userPopups addObject:userPopup];
        }
        
        self.lblCoffee = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 32.0f)];
        self.lblCoffee.alpha = 0.0f;
        self.lblCoffee.textColor = [UIColor whiteColor];
        self.lblCoffee.text = @"#Coffee";
        self.lblCoffee.font = [UIFont boldSystemFontOfSize:22.0f];
        self.lblCoffee.textAlignment = NSTextAlignmentCenter;
        self.lblCoffee.center = ctr;
        [self addSubview:self.lblCoffee];

        self.profileIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileIcon.png"]];
        self.profileIcon.layer.cornerRadius = 0.5f*self.profileIcon.frame.size.width;
        self.profileIcon.layer.masksToBounds = YES;
        self.profileIcon.center = CGPointMake(0.5f*frame.size.width, -self.profileIcon.frame.size.height);
        [self addSubview:self.profileIcon];


        CGFloat width = 0.6f*frame.size.width;
        self.btnGotit = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnGotit.frame = CGRectMake(0.5*(frame.size.width-width), 346.0f, width, 44.0f);
        self.btnGotit.backgroundColor = [UIColor grayColor];
        self.btnGotit.layer.cornerRadius = 4.0f;
        self.btnGotit.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [self.btnGotit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnGotit setTitle:@"Got It" forState:UIControlStateNormal];
        [self addSubview:self.btnGotit];


        
    }
    return self;
}


- (void)animate
{
    [UIView animateWithDuration:0.70f
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.frame;
                         self.profileIcon.center = CGPointMake(0.5f*frame.size.width, 150.0f);
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.25f
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.lblCoffee.alpha = 1.0f;
                                              CGPoint ctr = self.lblCoffee.center;
                                              self.lblCoffee.center = CGPointMake(ctr.x, 80.0f);
                                          }
                                          completion:^(BOOL finished){
                                              
                                              self.pulse.alpha = 1.0f;
                                              [UIView animateWithDuration:0.36f
                                                                    delay:0
                                                                  options:UIViewAnimationOptionCurveEaseIn
                                                               animations:^{
                                                                   UIImageView *popup = self.userPopups[0];
                                                                   popup.alpha = 1.0f;
                                                                   CGPoint ctr = popup.center;
                                                                   ctr.x = 230.0f;
                                                                   ctr.y = 145.0f;
                                                                   popup.center = ctr;
                                                                   
                                                                   popup = self.userPopups[1];
                                                                   popup.alpha = 1.0f;
                                                                   ctr.x = 90.0f;
                                                                   ctr.y = 135.0f;
                                                                   popup.center = ctr;
                                                                   
                                                                   self.pulse.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                                                                   self.pulse.alpha = 0;
                                                               }
                                                               completion:^(BOOL finished){
                                                                   
                                                               }];
                                          }];
                     }];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
