//
//  UIImage+FZImageEffects.m
//  FlashZone
//
//  Created by Dan Kwon on 8/16/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "UIImage+FZImageEffects.h"

@implementation UIImage (FZImageEffects)


- (UIImage *)croppedImage
{
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    UIImage *cropped = self;
    if (w != h){
        CGFloat dimen = (w < h) ? w : h;
        CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(0.50f*(self.size.width-dimen), 0.50f*(self.size.height-dimen), dimen, dimen));
        cropped = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.5f)];
        CGImageRelease(imageRef);
    }
    
    return cropped;
}


@end
