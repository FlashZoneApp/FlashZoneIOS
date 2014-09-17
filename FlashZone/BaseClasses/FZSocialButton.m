//
//  FZSocialButton.m
//  FlashZone
//
//  Created by Dan Kwon on 9/17/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSocialButton.h"
#import "Config.h"

@implementation FZSocialButton
@synthesize lblNetwork;
@synthesize socialNetwork = _socialNetwork;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.layer.cornerRadius = 5.0f;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(frame.size.height, 0.0f, 0.5f, frame.size.height-0.5f)];
        line.backgroundColor = [UIColor grayColor];
        [self addSubview:line];
        
        CGFloat x = frame.size.height+10.0f;
        self.lblNetwork = [[UILabel alloc] initWithFrame:CGRectMake(x, 12.0f, frame.size.width-x, 22.0f)];
        self.lblNetwork.textAlignment = NSTextAlignmentLeft;
        self.lblNetwork.font = [UIFont systemFontOfSize:16.0f];
        self.lblNetwork.textColor = [UIColor whiteColor];

        [self addSubview:self.lblNetwork];


    }
    return self;
}


+ (FZSocialButton *)buttonWithFrame:(CGRect)frame socialNetwork:(FZSocialNetwork)network
{
    FZSocialButton *socialBtn = [[FZSocialButton alloc] initWithFrame:frame];
    socialBtn.socialNetwork = network;
    return socialBtn;
}


- (void)setSocialNetwork:(FZSocialNetwork)socialNetwork
{
    _socialNetwork = socialNetwork;
    if (socialNetwork==FZSocialNetworkFacebook){
        self.backgroundColor = kFacebookBlue;
    }
    if (socialNetwork==FZSocialNetworkTwitter){
        self.backgroundColor = kTwitterBlue;
    }
    if (socialNetwork==FZSocialNetworkGoogle){
        self.backgroundColor = kGoogleRed;
    }
    if (socialNetwork==FZSocialNetworkLinkedin){
        self.backgroundColor = kLinkedinBlue;
    }
    if (socialNetwork==FZSocialNetworkReddit){
        self.backgroundColor = kRedditRed;
    }
}

@end
