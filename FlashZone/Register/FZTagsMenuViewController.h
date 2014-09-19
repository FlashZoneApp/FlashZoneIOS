//
//  FZTagsMenuViewController.h
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZViewController.h"

@interface FZTagsMenuViewController : FZViewController

@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIImageView *blurryBackground;
@property (strong, nonatomic) UIColor *screenColor;
@property (strong, nonatomic) UILabel *lblCategory;
@property (nonatomic) BOOL useSocialNetwork;
- (id)initWithCategory:(NSString *)category;
@end
