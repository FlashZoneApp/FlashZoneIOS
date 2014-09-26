//
//  FZSearchCell.m
//  FlashZone
//
//  Created by Dan Kwon on 9/26/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSearchCell.h"

@implementation FZSearchCell
@synthesize btnPlus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        UIImage *imgPlusIcon = [UIImage imageNamed:@"iconPlus18.png"];
        self.btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnPlus.frame = CGRectMake(0, 0, imgPlusIcon.size.width, imgPlusIcon.size.height);
        self.btnPlus.center = CGPointMake(frame.size.width-30.0f, 22.0f);
        [self.btnPlus setBackgroundImage:imgPlusIcon forState:UIControlStateNormal];
        [self.contentView addSubview:self.btnPlus];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
