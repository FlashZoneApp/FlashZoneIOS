//
//  FZExploreTagsView.h
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZExploreTagsView : UIView

@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIScrollView *tagsScrollview;

+ (FZExploreTagsView *)viewWithCategories:(NSArray *)categories withFrame:(CGRect)frame;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end
