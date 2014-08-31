//
//  UIView+FZViewAdditions.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "UIView+FZViewAdditions.h"

@implementation UIView (FZViewAdditions)



- (UIImage *)screenshot
{
    CGRect bounds = self.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"SCREENSHOT: %.2f", image.size.height);
    return image;
}



@end
