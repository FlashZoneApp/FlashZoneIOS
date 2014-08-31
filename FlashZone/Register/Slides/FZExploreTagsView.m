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
@synthesize theScrollview;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        
        self.theScrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.theScrollview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_explore_tags.png"]];
        
        UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnNext setTitle:@"I'm Ready" forState:UIControlStateNormal];
        btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
        btnNext.frame = CGRectMake(frame.size.width-100.0f, 24.0f, 90.0f, 24.0f);
        [theScrollview addSubview:btnNext];
        
        UIImage *imgSearchBar = [UIImage imageNamed:@"bgSearchBar.png"];
        UIView *bgSearchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgSearchBar.size.width, imgSearchBar.size.height)];
        bgSearchBar.backgroundColor = [UIColor colorWithPatternImage:imgSearchBar];
        bgSearchBar.center = CGPointMake(0.5f*frame.size.width, 80.0f);
        
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(40.0f, 6.0f, bgSearchBar.frame.size.width-50.0f, bgSearchBar.frame.size.height-12.0f)];
        self.searchField.textColor = [UIColor whiteColor];
        self.searchField.placeholder = @"Search for flashtag interests";
        [bgSearchBar addSubview:self.searchField];
        
        [self.theScrollview addSubview:bgSearchBar];
        
        self.tagsScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f, 190.0f, frame.size.width-20.0f, 105.0f)];
        self.tagsScrollview.backgroundColor = [UIColor redColor];
        self.tagsScrollview.contentSize = CGSizeMake(500, 0);
        [self.theScrollview addSubview:self.tagsScrollview];
        
        
        NSArray *icons = @[@"fb-rndsquare.png", @"twt-rndsquare.png", @"g-rndsquare.png", @"linkd-rndsquare.png", @"redd-rndsquare.png"];
        UIImage *icon = [UIImage imageNamed:icons[0]];
        
        CGFloat padding = 6.0f;
        CGFloat span = (icons.count-1)*padding+icons.count*icon.size.width;
        CGFloat x = 0.5f*(frame.size.width-span);
        for (int i=0; i<icons.count; i++) {
            UIImage *img = [UIImage imageNamed:icons[i]];
            UIButton *btnNetwork = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnNetwork setBackgroundImage:img forState:UIControlStateNormal];
            btnNetwork.frame = CGRectMake(x, 400.0f, img.size.width, img.size.height);
            [theScrollview addSubview:btnNetwork];
            x += img.size.width+padding;
        }
        
        CGFloat width = 0.6f*frame.size.width;
        UIButton *btnGetStarted = [UIButton buttonWithType:UIButtonTypeCustom];
        btnGetStarted.frame = CGRectMake(0.5*(frame.size.width-width), 460.0f, width, 44.0f);
        btnGetStarted.backgroundColor = [UIColor grayColor];
        btnGetStarted.layer.cornerRadius = 4.0f;
        btnGetStarted.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [btnGetStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnGetStarted setTitle:@"Okay I'm ready" forState:UIControlStateNormal];
        [self.theScrollview addSubview:btnGetStarted];
        

        
        
        self.theScrollview.contentSize = CGSizeMake(0, 568.0f);
        
        [self addSubview:self.theScrollview];
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
