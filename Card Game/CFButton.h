//
//  CFButton.h
//
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-14.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFButton : UIButton

/** UIButton's title label is way too annoying */
@property (strong)UILabel*label;

-(void)setTextSize:(int)size;
-(void)setEnabled:(BOOL)enabled;
-(void)setSelected:(BOOL)selected;
-(void)setupAsTab;

@property enum CFButtonStyle buttonStyle;
@property (strong) CAShapeLayer * dottedBorder;

@end

enum CFButtonStyle
{
    CFButtonStyleRegular,
    /** Only changes looks */
    CFButtonStyleWarning,
    CFButtonStyleToggle,
    CFButtonStyleRadio,
};