//
//  FZWebViewController.h
//  FlashZone
//
//  Created by Dan Kwon on 8/3/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZViewController.h"

@interface FZWebViewController : FZViewController <UIWebViewDelegate>


@property (strong, nonatomic) UIWebView *theWebview;
@property (copy, nonatomic) NSString *target;
@end
