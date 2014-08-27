//
//  StoreCardCell.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StoreCardCell.h"
#import "CardView.h"
#import "UIConstants.h"

@implementation StoreCardCell

@synthesize cardView = _cardView;
@synthesize costLabel = _costLabel;
@synthesize likesLabel = _likesLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cardView = nil;
        
        _background = [[CFLabel alloc] initWithFrame:self.bounds];
        [self setBackgroundView:_background];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(0,0,50,50);
        _activityView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        //_activityView.backgroundColor = [UIColor blackColor];
        
        _statsView = [[UIView alloc] initWithFrame:self.bounds];
        [_statsView setUserInteractionEnabled:NO];
        
        _likesIcon = [[UIImageView alloc] initWithImage:LIKE_ICON_IMAGE];
        _likesIcon.frame = CGRectMake(0, 0, 28, 28);
        _likesIcon.center = CGPointMake(frame.size.width/3, frame.size.height-35);
        [_statsView addSubview:_likesIcon];
        
        _likesLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _likesLabel.textColor = [UIColor whiteColor];
        _likesLabel.textAlignment = NSTextAlignmentCenter;
        _likesLabel.font = [UIFont fontWithName:cardMainFont size:20];
        _likesLabel.center = CGPointMake(frame.size.width/3, frame.size.height-23);
        _likesLabel.strokeOn = YES;
        _likesLabel.strokeThickness = 3;
        _likesLabel.strokeColour = [UIColor blackColor];
        [_statsView addSubview:_likesLabel];
        
        _costIcon = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
        _costIcon.frame = CGRectMake(0, 0, 28, 28);
        _costIcon.center = CGPointMake(frame.size.width*2/3, frame.size.height-35);
        [_statsView addSubview:_costIcon];
        
        _costLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _costLabel.textColor = [UIColor whiteColor];
        _costLabel.textAlignment = NSTextAlignmentCenter;
        _costLabel.font = [UIFont fontWithName:cardMainFont size:20];
        _costLabel.center = CGPointMake(frame.size.width*2/3, frame.size.height-23);
        _costLabel.strokeOn = YES;
        _costLabel.strokeThickness = 3;
        _costLabel.strokeColour = [UIColor blackColor];
        [_statsView addSubview:_costLabel];
        
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
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
