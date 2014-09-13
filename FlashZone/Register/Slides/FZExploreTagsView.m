//
//  FZExploreTagsView.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZExploreTagsView.h"

@interface FZExploreTagsView ()
@property (strong, nonatomic) UIScrollView *tagsScrollview;
@end

@implementation FZExploreTagsView
@synthesize searchField;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"HEIGHT: %.2f", frame.size.height);
        BOOL iPhone5 = (frame.size.height > 500);
        NSString *background = (iPhone5) ? @"bg_explore_tags.png" : @"bg_explore_tags_480.png";
        NSLog(@"BACKGROUND: %@", background);
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:background]];

        UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnNext setTitle:@"I'm Ready" forState:UIControlStateNormal];
        btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
        btnNext.frame = CGRectMake(frame.size.width-100.0f, 24.0f, 90.0f, 24.0f);
        [self addSubview:btnNext];
        
        UIImage *imgSearchBar = [UIImage imageNamed:@"bgSearchBar.png"];
        UIView *bgSearchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgSearchBar.size.width, imgSearchBar.size.height)];
        bgSearchBar.backgroundColor = [UIColor colorWithPatternImage:imgSearchBar];
        
        CGFloat y = (iPhone5) ? 80.0f : 70.0f;
        bgSearchBar.center = CGPointMake(0.5f*frame.size.width, y);
        
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(40.0f, 6.0f, bgSearchBar.frame.size.width-50.0f, bgSearchBar.frame.size.height-12.0f)];
        self.searchField.textColor = [UIColor whiteColor];
        self.searchField.placeholder = @"Search for flashtag interests";
        [bgSearchBar addSubview:self.searchField];
        
        [self addSubview:bgSearchBar];
        
        y = (iPhone5) ? 190.0f : 155.0f;
        int categoryCount = 12;
        self.tagsScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f, y, frame.size.width-20.0f, 105.0f)];
        self.tagsScrollview.backgroundColor = [UIColor clearColor];
        self.tagsScrollview.contentSize = CGSizeMake(categoryCount*100, 0);
        
        for (int i=0; i<categoryCount; i++) {
            UIButton *btnCategory = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCategory.backgroundColor = [UIColor redColor];
            btnCategory.frame = CGRectMake(0, 12.5f, 80.0f, 80.0f);
            btnCategory.layer.cornerRadius = 0.5f*btnCategory.frame.size.width;
            btnCategory.center = CGPointMake(50+i*100, btnCategory.center.y);
            [btnCategory setTitle:@"Category" forState:UIControlStateNormal];
            btnCategory.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            [self.tagsScrollview addSubview:btnCategory];
        }
        
        self.tagsScrollview.contentOffset = CGPointMake(50.0f, 0);
        [self addSubview:self.tagsScrollview];
        
        
        NSArray *icons = @[@"fb-rndsquare.png", @"twt-rndsquare.png", @"g-rndsquare.png", @"linkd-rndsquare.png", @"redd-rndsquare.png"];
        UIImage *icon = [UIImage imageNamed:icons[0]];
        
        CGFloat padding = 12.0f;
        CGFloat span = (icons.count-1)*padding+icons.count*icon.size.width;
        CGFloat x = 0.5f*(frame.size.width-span);
        y = (iPhone5) ? 400.0f : 350.0f;

        for (int i=0; i<icons.count; i++) {
            UIImage *img = [UIImage imageNamed:icons[i]];
            UIButton *btnNetwork = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnNetwork setBackgroundImage:img forState:UIControlStateNormal];
            btnNetwork.frame = CGRectMake(x, y, img.size.width, img.size.height);
            [self addSubview:btnNetwork];
            x += img.size.width+padding;
        }
        
        y += (iPhone5) ? 74.0f : 54.0f;
        CGFloat width = 0.6f*frame.size.width;
        UIButton *btnGetStarted = [UIButton buttonWithType:UIButtonTypeCustom];
        btnGetStarted.frame = CGRectMake(0.5*(frame.size.width-width), y, width, 44.0f);
        btnGetStarted.backgroundColor = [UIColor grayColor];
        btnGetStarted.layer.cornerRadius = 4.0f;
        btnGetStarted.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [btnGetStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnGetStarted setTitle:@"Okay I'm ready" forState:UIControlStateNormal];
        [self addSubview:btnGetStarted];
        
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
