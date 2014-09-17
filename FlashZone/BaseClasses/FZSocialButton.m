//
//  FZSocialButton.m
//  FlashZone
//
//  Created by Dan Kwon on 9/17/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSocialButton.h"
#import "Config.h"

@interface FZSocialButton ()
@property (strong, nonatomic) UIImageView *icon;
@end

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
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        self.icon.backgroundColor = [UIColor clearColor];
        [self addSubview:self.icon];
        
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

+ (NSArray *)socialNetworks
{
    return @[@"Facebook", @"Twitter", @"Google", @"Linkedin", @"Reddit"];
}


- (void)setSocialNetwork:(FZSocialNetwork)socialNetwork
{
    _socialNetwork = socialNetwork;
    CGRect frame = self.icon.frame;
    if (socialNetwork==FZSocialNetworkFacebook){
        self.backgroundColor = kFacebookBlue;
        self.icon.image = [UIImage imageNamed:@"iconFacebook.png"];
    }
    if (socialNetwork==FZSocialNetworkTwitter){
        self.backgroundColor = kTwitterBlue;
        self.icon.image = [UIImage imageNamed:@"iconTwitter.png"];
    }
    if (socialNetwork==FZSocialNetworkGoogle){
        self.backgroundColor = kGoogleRed;
        self.icon.image = [UIImage imageNamed:@"iconGoogle.png"];
    }
    if (socialNetwork==FZSocialNetworkLinkedin){
        self.backgroundColor = kLinkedinBlue;
        self.icon.image = [UIImage imageNamed:@"iconLinkedin.png"];
    }
    if (socialNetwork==FZSocialNetworkReddit){
        self.backgroundColor = kRedditRed;
        self.icon.image = [UIImage imageNamed:@"iconReddit.png"];
    }
    
    self.icon.frame = CGRectMake(frame.origin.x, frame.origin.y, self.icon.image.size.width, self.icon.image.size.height);
    self.icon.center = CGPointMake(0.5f*self.frame.size.height, 0.5f*self.frame.size.height);

}

@end
