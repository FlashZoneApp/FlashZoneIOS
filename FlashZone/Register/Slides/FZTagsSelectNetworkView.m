//
//  FZTagsSelectNetworkView.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZTagsSelectNetworkView.h"

@implementation FZTagsSelectNetworkView
@synthesize theScrollview;
@synthesize btnNext;
@synthesize btnGetStarted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        
        self.theScrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_select_network.png"]];
        [self.theScrollview addSubview:background];
        
        self.btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
        self.btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
        self.btnNext.frame = CGRectMake(frame.size.width-80.0f, 24.0f, 80.0f, 24.0f);
        [self.theScrollview addSubview:self.btnNext];
        
        
        CGFloat width = 0.6f*frame.size.width;
        self.btnGetStarted = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnGetStarted.frame = CGRectMake(0.5*(frame.size.width-width), 337.0f, width, 44.0f);
        self.btnGetStarted.backgroundColor = [UIColor grayColor];
        self.btnGetStarted.layer.cornerRadius = 4.0f;
        self.btnGetStarted.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [self.btnGetStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnGetStarted setTitle:@"Get Started" forState:UIControlStateNormal];
        [self.theScrollview addSubview:self.btnGetStarted];
        
        NSArray *icons = @[@"fb-rndsquare.png", @"twt-rndsquare.png", @"g-rndsquare.png", @"linkd-rndsquare.png", @"redd-rndsquare.png"];
        UIImage *icon = [UIImage imageNamed:icons[0]];

        CGFloat padding = 12.0f;
        CGFloat span = (icons.count-1)*padding+icons.count*icon.size.width;
        CGFloat x = 0.5f*(frame.size.width-span);
        for (int i=0; i<icons.count; i++) {
            UIImage *img = [UIImage imageNamed:icons[i]];
            UIButton *btnNetwork = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnNetwork setBackgroundImage:img forState:UIControlStateNormal];
            btnNetwork.frame = CGRectMake(x, 468.0f, img.size.width, img.size.height);
            [self.theScrollview addSubview:btnNetwork];
            x += img.size.width+padding;
        }

        
        self.theScrollview.contentSize = CGSizeMake(0, 568.0f);
        
        [self addSubview:self.theScrollview];
    }
    return self;
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
