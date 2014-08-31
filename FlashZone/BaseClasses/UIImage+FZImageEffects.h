//
//  UIImage+FZImageEffects.h
//  FlashZone
//
//  Created by Dan Kwon on 8/16/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FZImageEffects)

- (UIImage *)croppedImage;
- (UIImage *)applyBlurOnImage:(CGFloat)blurRadius;
@end
