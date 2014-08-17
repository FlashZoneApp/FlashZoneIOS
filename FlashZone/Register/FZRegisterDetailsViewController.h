//
//  FZRegisterDetailsViewController.h
//  FlashZone
//
//  Created by Dan Kwon on 7/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface FZRegisterDetailsViewController : FZViewController <UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) BOOL canRegister;
@end
