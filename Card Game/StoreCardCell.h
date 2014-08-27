//
//  StoreCardCell.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"
#import "StrokedLabel.h"
#import "CFLabel.h"

@interface StoreCardCell : UICollectionViewCell

@property (strong) CardView*cardView;

@property (strong) StrokedLabel*costLabel, *likesLabel;

@property (strong) CFLabel*background;

@property (strong) UIImageView*costIcon, *likesIcon;

@property (strong) UIView *statsView;

@property UIActivityIndicatorView *activityView;

@end
