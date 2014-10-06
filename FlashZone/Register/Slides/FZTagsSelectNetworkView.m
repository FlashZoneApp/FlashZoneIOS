//
//  FZTagsSelectNetworkView.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZTagsSelectNetworkView.h"

@implementation FZTagsSelectNetworkView
@synthesize btnNext;
@synthesize btnGetStarted;
@synthesize socialIconsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.socialIconsArray = [NSMutableArray array];
        
//        NSLog(@"HEIGHT: %.2f", frame.size.height);
        BOOL iPhone5 = (frame.size.height > 500);
        NSString *background = (iPhone5) ? @"bg_select_network.png" : @"bg_select_network_480.png";
//        NSLog(@"BACKGROUND: %@", background);
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:background]];
        
        
        self.btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
        self.btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
        self.btnNext.frame = CGRectMake(frame.size.width-80.0f, 24.0f, 80.0f, 24.0f);
        [self addSubview:self.btnNext];
        
        CGFloat y = (iPhone5) ? 337.0f : 260.0f;
        CGFloat width = 0.6f*frame.size.width;
        self.btnGetStarted = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnGetStarted.frame = CGRectMake(0.5*(frame.size.width-width), y, width, 44.0f);
        self.btnGetStarted.backgroundColor = [UIColor grayColor];
        self.btnGetStarted.layer.cornerRadius = 4.0f;
        self.btnGetStarted.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [self.btnGetStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnGetStarted setTitle:@"Get Started" forState:UIControlStateNormal];
        [self addSubview:self.btnGetStarted];
        
        NSArray *icons = @[@"fb-rndsquare.png", @"twt-rndsquare.png", @"g-rndsquare.png", @"linkd-rndsquare.png", @"redd-rndsquare.png"];
        UIImage *icon = [UIImage imageNamed:icons[0]];

        CGFloat padding = 12.0f;
        CGFloat span = (icons.count-1)*padding+icons.count*icon.size.width;
        CGFloat x = 0.5f*(frame.size.width-span);
        y = (iPhone5) ? 468.0f : 391.0f;

        for (int i=0; i<icons.count; i++) {
            UIImage *img = [UIImage imageNamed:icons[i]];
            UIButton *btnNetwork = [UIButton buttonWithType:UIButtonTypeCustom];
            btnNetwork.tag = 1000+i;
            [btnNetwork setBackgroundImage:img forState:UIControlStateNormal];
            btnNetwork.frame = CGRectMake(x, y, img.size.width, img.size.height);
            [self addSubview:btnNetwork];
            [self.socialIconsArray addObject:btnNetwork];
            x += img.size.width+padding;
        }

        
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
