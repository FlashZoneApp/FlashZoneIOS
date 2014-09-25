//
//  FZSelectedTagView.m
//  FlashZone
//
//  Created by Dan Kwon on 9/25/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSelectedTagView.h"
#import "Config.h"

@implementation FZSelectedTagView
@synthesize lblTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kOrange;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, frame.size.width-20.0f, 22.0f)];
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.font = [UIFont boldSystemFontOfSize:18.0f];
        [self addSubview:self.lblTitle];
        
        UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCheckMark.png"]];
        checkMark.center = CGPointMake(frame.size.width-30.0f, self.lblTitle.center.y);
        [self addSubview:checkMark];
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
