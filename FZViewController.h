//
//  FZViewController.h
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "FZWebServices.h"
#import "FZProfile.h"
#import "FZLoadingIndicator.h"
#import "FZSocialAccountsMgr.h"
#import "UIView+FZViewAdditions.h"
#import "UIImage+FZImageEffects.h"


@interface FZViewController : UIViewController

@property (strong, nonatomic) FZProfile *profile;
@property (strong, nonatomic) FZLoadingIndicator *loadingIndicator;
@property (strong, nonatomic) FZSocialAccountsMgr *socialAccountsMgr;
- (UIView *)baseView:(BOOL)navCtr;
- (void)showAlertWithtTitle:(NSString *)title message:(NSString *)msg;
- (void)showAlertWithOptions:(NSString *)title message:(NSString *)msg;
- (void)shiftUp:(CGFloat)distance;
- (void)shiftBack:(CGFloat)origin;
@end
