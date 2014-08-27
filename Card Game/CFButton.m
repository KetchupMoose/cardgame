//
//  CFButton.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-14.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CFButton.h"
#import "UIConstants.h"
#import "CardView.h"

@implementation CFButton

@synthesize buttonStyle = _buttonStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 5)];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:cardMainFont size:10];
        _label.numberOfLines = 0;
        //[_label setMinimumScaleFactor:10.f/30];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        //_label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_label];
        
        _dottedBorder = [CAShapeLayer layer];
        _dottedBorder.strokeColor = [UIColor blackColor].CGColor;
        _dottedBorder.fillColor = nil;
        _dottedBorder.lineWidth = 2;
        _dottedBorder.lineDashPattern = @[@5, @8];
        CGRect boundsRect = CGRectMake(self.bounds.origin.x + 5, self.bounds.origin.y + 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:boundsRect cornerRadius:5];
        _dottedBorder.path = path.CGPath;
        _dottedBorder.cornerRadius = 5;
        _dottedBorder.frame = self.bounds;
        [self.layer addSublayer:_dottedBorder];
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        _buttonStyle = CFButtonStyleRegular;
        [self updateView];
    }
    return self;
}

-(void)setupAsTab
{
    [self setButtonStyle:CFButtonStyleRadio];
    
    [_dottedBorder removeFromSuperlayer];
    _dottedBorder = [CAShapeLayer layer];
    _dottedBorder.strokeColor = [UIColor blackColor].CGColor;
    _dottedBorder.fillColor = nil;
    _dottedBorder.lineWidth = 2;
    _dottedBorder.lineDashPattern = @[@5, @8];
    CGRect boundsRect = CGRectMake(self.bounds.origin.x + 5, self.bounds.origin.y + 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
    _dottedBorder.path = [UIBezierPath bezierPathWithRect:boundsRect].CGPath;
    _dottedBorder.frame = self.bounds;
    [self.layer addSublayer:_dottedBorder];
    self.layer.cornerRadius = 0;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor blackColor].CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setTextSize:(int)size
{
    _label.font = [UIFont fontWithName:cardMainFont size:size];
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    _label.text = title;
    _label.frame = CGRectInset(self.bounds, 10, 5);
    //[_label sizeToFit];
    _label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    //no clue what 5 is but that's when it's pressed
    if (_buttonStyle == CFButtonStyleRadio && self.state == 5)
    {
        //no effect
    }
    else if (self.enabled)
        [self updateViewPressed];
}

/*
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}*/

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL originalSelected = self.selected;
    [super touchesEnded:touches withEvent:event];
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    //touches ended inside
    if (CGRectContainsPoint(self.bounds, touchPoint))
    {
        if (_buttonStyle == CFButtonStyleRadio)
            [self setSelected:YES];
        else
            [self setSelected:!originalSelected];
    }
    
    [self updateView];
}

-(void)updateView
{
    if (!self.enabled)
    {
        _label.textColor = [UIColor lightGrayColor];
        self.backgroundColor = COLOUR_INTERFACE_GRAY;
    }
    else if (self.selected)
    {
        if (_buttonStyle == CFButtonStyleWarning)
        {
            _label.textColor = [UIColor whiteColor];
            self.backgroundColor = COLOUR_INTERFACE_RED;
        }
        else
        {
            _label.textColor = [UIColor whiteColor];
            self.backgroundColor = COLOUR_INTERFACE_BLUE;
        }
    }
    else
    {
        if (_buttonStyle == CFButtonStyleToggle || _buttonStyle == CFButtonStyleRadio)
        {
            _label.textColor = [UIColor whiteColor];
            self.backgroundColor = COLOUR_INTERFACE_BLUE_TOGGLE;
        }
        else
        {
            if (_buttonStyle == CFButtonStyleWarning)
            {
                _label.textColor = [UIColor whiteColor];
                self.backgroundColor = COLOUR_INTERFACE_RED;
            }
            else
            {
                _label.textColor = [UIColor whiteColor];
                self.backgroundColor = COLOUR_INTERFACE_BLUE;
            }
        }
    }
}

-(void)updateViewPressed
{
    if (_buttonStyle == CFButtonStyleWarning)
    {
        _label.textColor = [UIColor lightGrayColor];
        self.backgroundColor = COLOUR_INTERFACE_RED_PRESSED;
    }
    else
    {
        self.backgroundColor = COLOUR_INTERFACE_BLUE_PRESSED;
        _label.textColor = [UIColor lightGrayColor];
    }
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (!enabled)
        self.selected = NO;
    
    [self updateView];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateView];
}

-(void)setButtonStyle:(enum CFButtonStyle)buttonStyle
{
    _buttonStyle = buttonStyle;
    [self updateView];
}

-(enum CFButtonStyle)buttonStyle
{
    return _buttonStyle;
}

@end
