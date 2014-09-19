//
//  FZButtonTag.m
//  FlashZone
//
//  Created by Dan Kwon on 8/30/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZButtonTag.h"

@interface FZButtonTag ()
@property (strong, nonatomic) UIImageView *selectedIcon;
@end

@implementation FZButtonTag

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        self.selectedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 12.0f, 12.0f)];
        self.selectedIcon.image = [UIImage imageNamed:@"iconPlus.png"];
        [self addSubview:self.selectedIcon];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect iconFrame = self.selectedIcon.frame;
    self.selectedIcon.frame = CGRectMake(frame.size.width-iconFrame.size.width-8.0f, iconFrame.origin.y, iconFrame.size.width, iconFrame.size.height);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectedIcon.image = (selected) ? [UIImage imageNamed:@"iconCheckMark.png"] : [UIImage imageNamed:@"iconPlus.png"];
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
