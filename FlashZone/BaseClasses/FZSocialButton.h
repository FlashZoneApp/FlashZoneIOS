//
//  FZSocialButton.h
//  FlashZone
//
//  Created by Dan Kwon on 9/17/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FZSocialNetworkFacebook = 0,
    FZSocialNetworkTwitter,
    FZSocialNetworkLinkedin,
    FZSocialNetworkGoogle,
    FZSocialNetworkReddit
} FZSocialNetwork;


@interface FZSocialButton : UIButton

@property (nonatomic) FZSocialNetwork socialNetwork;
@property (strong, nonatomic) UILabel *lblNetwork;
+ (FZSocialButton *)buttonWithFrame:(CGRect)frame socialNetwork:(FZSocialNetwork)network;
@end
