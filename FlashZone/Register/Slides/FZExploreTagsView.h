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
@property (strong, nonatomic) NSMutableArray *buttonsArray;
@property (strong, nonatomic) NSMutableArray *socialIconsArray;
@property (strong, nonatomic) UIButton *btnGetStarted;

+ (FZExploreTagsView *)viewWithCategories:(NSArray *)categories withFrame:(CGRect)frame;
@end
