//
//  FZLoadingIndicator.h
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZLoadingIndicator : UIView

@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblMessage;
- (void)stopLoading;
- (void)startLoading;
@end
