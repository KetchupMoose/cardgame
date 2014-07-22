//
//  CardView.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardView.h"

@implementation CardView

@synthesize cardModel = _cardModel;
@synthesize center = _center;
@synthesize cardViewState = _cardViewState;
@synthesize originalPosition = _originalPosition;
@synthesize nameLabel, costLabel, attackLabel, lifeLabel, cooldownLabel, baseAbilityLabel, addedAbilityLabel, elementLabel;
@synthesize previousViewIndex;
@synthesize cardImage = _cardImage;
@synthesize cardHighlightType = _cardHighlightType;
@synthesize lifeViewNeedsUpdate = _lifeViewNeedsUpdate;
@synthesize damageViewNeedsUpdate = _damageViewNeedsUpdate;
@synthesize cooldownViewNeedsUpdate = _cooldownViewNeedsUpdate;
@synthesize cardViewMode = _cardViewMode;
@synthesize mask = _mask;

const int CARD_WIDTH_RATIO = 5;
const int CARD_HEIGHT_RATIO = 8;
const float CARD_IMAGE_RATIO = 450.f/530;

const double CARD_VIEWER_SCALE = 0.8;
const double CARD_VIEWER_MAXED_SCALE = 1.25;

const float CARD_DEFAULT_SCALE = 0.4f;
const float CARD_DRAGGING_SCALE = 1.0f;

/** Dummy initial values, will be changed in setup */
int CARD_WIDTH = 50, CARD_HEIGHT = 80;
int CARD_FULL_WIDTH = 50, CARD_FULL_HEIGHT = 80;
int PLAYER_HERO_WIDTH = 50, PLAYER_HERO_HEIGHT = 50;

UIImage *backgroundMonsterOverlayImage, *selectHighlightImage, *targetHighlightImage, *heroSelectHighlightImage, *heroTargetHighlightImage;

/** 2D array of images. First array contains elements, second array contains rarity */
NSArray*backgroundImages, *backgroundOverlayImages, *abilityIconImages;

NSMutableParagraphStyle *abilityTextParagrahStyle;
NSDictionary *abilityTextAttributtes;

NSString *cardMainFont = @"EncodeSansCompressed-Bold";
NSString *cardMainFontBlack = @"EncodeSansCompressed-Black";



+(void) loadResources
{
    CARD_WIDTH = 57; //TODO ipad
    CARD_HEIGHT = (CARD_WIDTH *  CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO);
    
    CARD_FULL_WIDTH = CARD_WIDTH/CARD_DEFAULT_SCALE;
    CARD_FULL_HEIGHT = CARD_HEIGHT/CARD_DEFAULT_SCALE;

    PLAYER_HERO_WIDTH = PLAYER_HERO_HEIGHT = CARD_HEIGHT;
    
    backgroundImages = @[
                         @[[UIImage imageNamed:@"card_background_front_neutral_common"],
                           //TODO replace with additional rarity here
                           [UIImage imageNamed:@"card_background_front_neutral_common"],
                           [UIImage imageNamed:@"card_background_front_neutral_common"],
                           [UIImage imageNamed:@"card_background_front_neutral_common"],
                           [UIImage imageNamed:@"card_background_front_neutral_common"],
                           ],
                         @[[UIImage imageNamed:@"card_background_front_fire_common"],
                           [UIImage imageNamed:@"card_background_front_fire_common"],
                           [UIImage imageNamed:@"card_background_front_fire_common"],
                           [UIImage imageNamed:@"card_background_front_fire_common"],
                           [UIImage imageNamed:@"card_background_front_fire_common"],
                           ],
                         @[[UIImage imageNamed:@"card_background_front_ice_common"],
                           [UIImage imageNamed:@"card_background_front_ice_common"],
                           [UIImage imageNamed:@"card_background_front_ice_common"],
                           [UIImage imageNamed:@"card_background_front_ice_common"],
                           [UIImage imageNamed:@"card_background_front_ice_common"],
                           ],
                         @[[UIImage imageNamed:@"card_background_front_lightning_common"],
                           [UIImage imageNamed:@"card_background_front_lightning_common"],
                           [UIImage imageNamed:@"card_background_front_lightning_common"],
                           [UIImage imageNamed:@"card_background_front_lightning_common"],
                           [UIImage imageNamed:@"card_background_front_lightning_common"],
                           ],
                         @[[UIImage imageNamed:@"card_background_front_earth_common"],
                           [UIImage imageNamed:@"card_background_front_earth_common"],
                           [UIImage imageNamed:@"card_background_front_earth_common"],
                           [UIImage imageNamed:@"card_background_front_earth_common"],
                           [UIImage imageNamed:@"card_background_front_earth_common"],
                           ],
                         @[[UIImage imageNamed:@"card_background_front_light_common"],
                           [UIImage imageNamed:@"card_background_front_light_common"],
                           [UIImage imageNamed:@"card_background_front_light_common"],
                           [UIImage imageNamed:@"card_background_front_light_common"],
                           [UIImage imageNamed:@"card_background_front_light_common"],
                           ],
                         @[[UIImage imageNamed:@"card_background_front_dark_common"],
                           [UIImage imageNamed:@"card_background_front_dark_common"],
                           [UIImage imageNamed:@"card_background_front_dark_common"],
                           [UIImage imageNamed:@"card_background_front_dark_common"],
                           [UIImage imageNamed:@"card_background_front_dark_common"],
                           ],
                         ];
    
    //ensure order is same as enum order
    abilityIconImages = @[
                          [UIImage imageNamed:@"card_ability_icon_cast_on_move"],
                          [UIImage imageNamed:@"card_ability_icon_cast_on_death"],
                          [UIImage imageNamed:@"card_ability_icon_cast_on_hit"],
                          [UIImage imageNamed:@"card_ability_icon_cast_on_damaged"],
                          [UIImage imageNamed:@"card_ability_icon_taunt"],
                          [UIImage imageNamed:@"card_ability_icon_assassin"],
                          [UIImage imageNamed:@"card_ability_icon_pierce"],
                          [UIImage imageNamed:@"card_ability_icon_remove_ability"],
                          ];
    
    backgroundOverlayImages = @[
     [UIImage imageNamed:@"card_background_front_overlay_common"],
     //TODO other rarities
     [UIImage imageNamed:@"card_background_front_overlay_common"],
     [UIImage imageNamed:@"card_background_front_overlay_common"],
     [UIImage imageNamed:@"card_background_front_overlay_common"],
     [UIImage imageNamed:@"card_background_front_overlay_common"],
    ];
    
    backgroundMonsterOverlayImage = [UIImage imageNamed:@"card_background_front_monster_overlay"];
    
    
    selectHighlightImage = [UIImage imageNamed:@"card_glow_select"];
    heroSelectHighlightImage = [UIImage imageNamed:@"hero_glow_select"];
    targetHighlightImage = [UIImage imageNamed:@"card_glow_target"];
    heroTargetHighlightImage = [UIImage imageNamed:@"hero_glow_target"];
    
    abilityTextParagrahStyle = [[NSMutableParagraphStyle alloc] init];
    //[abilityTextParagrahStyle setLineSpacing:];
    [abilityTextParagrahStyle setMaximumLineHeight:10];
    abilityTextAttributtes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle,};
    
    
}

-(instancetype)initWithModel:(CardModel *)cardModel cardImage:(UIImageView*)cardImage viewMode:(enum CardViewMode)cardViewMode
{
    self = [super init]; //does not actually make an image because highlight has to be behind it..
    
    if (self != nil)
    {
        self.cardViewMode = cardViewMode;
        
        NSArray*elementArray = backgroundImages[cardModel.element];
        //TODO
        
        self.abilityIcons = [NSMutableArray array];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:elementArray[0]];
        backgroundImageView.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
        backgroundImageView.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        [self addSubview: backgroundImageView];

        self.cardImage = cardImage;
        self.cardImage.bounds = CGRectMake(10, 30, CARD_FULL_WIDTH - 16, (CARD_FULL_WIDTH-16) * CARD_IMAGE_RATIO);
        self.cardImage.center = CGPointMake(CARD_FULL_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y - 4);
        
        [self addSubview:self.cardImage];
        
        UIImageView *cardOverlay = [[UIImageView alloc] initWithImage:backgroundOverlayImages[cardModel.rarity]];
        cardOverlay.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
        cardOverlay.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        [self addSubview:cardOverlay];
        
        _cardModel = cardModel;
        cardModel.cardView = self; //point model's view back to itself
        
        self.userInteractionEnabled = true; //allows interaction
        
        self.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        
        CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+14,self.frame.size.height+14);
        self.highlight = [[UIImageView alloc] initWithImage:selectHighlightImage];
        self.highlight.bounds = highlightBounds;
        self.highlight.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        self.highlight.alpha = 0.5;
        
        [self insertSubview:self.highlight atIndex:0];
        
        //draws common card elements such as name and cost
        self.nameLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,96,30)];
        self.nameLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + CARD_FULL_WIDTH/10 + 2, 16);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont fontWithName:cardMainFont size:15];
        [self.nameLabel setMinimumScaleFactor:8.f/15];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview: nameLabel];
        
        self.costLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.costLabel.center = CGPointMake(21, 19);
        self.costLabel.textAlignment = NSTextAlignmentCenter;
        self.costLabel.textColor = [UIColor whiteColor];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [UIFont fontWithName:cardMainFontBlack size:24];
        self.costLabel.strokeOn = YES;
        self.costLabel.strokeColour = [UIColor blackColor];
        self.costLabel.strokeThickness = 3;
        
        [self addSubview: costLabel];
        
        self.elementLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.elementLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 150);
        self.elementLabel.textAlignment = NSTextAlignmentCenter;
        self.elementLabel.textColor = [UIColor whiteColor];
        self.elementLabel.backgroundColor = [UIColor clearColor];
        self.elementLabel.strokeOn = YES;
        self.elementLabel.strokeColour = [UIColor blackColor];
        self.elementLabel.strokeThickness = 2.5;
        self.elementLabel.font = [UIFont fontWithName:cardMainFont size:10];
        self.elementLabel.text = [CardModel elementToString:cardModel.element];
        
        [self addSubview: elementLabel];
        
        self.baseAbilityLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(10, 150, CARD_FULL_WIDTH - 20, 135)]; //NOTE changing this is useless, do it down below
       
        self.baseAbilityLabel.textColor = [UIColor blackColor];
        self.baseAbilityLabel.backgroundColor = [UIColor clearColor];
        self.baseAbilityLabel.font = [UIFont fontWithName:cardMainFont size:10];
        self.baseAbilityLabel.numberOfLines = 6;
        self.baseAbilityLabel.textAlignment = NSTextAlignmentLeft;
        self.baseAbilityLabel.lineBreakMode = NSLineBreakByWordWrapping;

        [self.baseAbilityLabel sizeToFit];
        [self addSubview: baseAbilityLabel];
        
        //draws specific card elements for monster card
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel*monsterCard = (MonsterCardModel*)cardModel;

            //player hero's card only has life (TODO maybe damage or spells in future)
            if (cardModel.type == cardTypePlayer)
            {
                self.nameLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, 10);
                
                self.lifeLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
                self.lifeLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT - 10);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor whiteColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                self.lifeLabel.strokeOn = YES;
                self.lifeLabel.strokeColour = [UIColor blackColor];
                self.lifeLabel.strokeThickness = 2.5;
                self.lifeLabel.font = [UIFont fontWithName:cardMainFont size:20];
                self.lifeLabel.text = [NSString stringWithFormat:@"%d", monsterCard.life];
                
                [self addSubview: lifeLabel];
                
                //change the background and size
                self.cardImage.image = [UIImage imageNamed:@"hero_default"];
                
                //change the main image size
                self.cardImage.bounds = CGRectMake(5, 20, PLAYER_HERO_WIDTH - 10, (PLAYER_HERO_WIDTH-20) * CARD_IMAGE_RATIO);
                self.cardImage.center = CGPointMake(PLAYER_HERO_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y);
                
                [self.costLabel removeFromSuperview];
                
                self.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                backgroundImageView.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                
                self.highlight.image = heroSelectHighlightImage;
                //change the highlight size
                CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+5,self.frame.size.height+5);
                self.highlight.bounds = highlightBounds;
                self.highlight.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT/2);
                
                //removing this for now
                [cardOverlay removeFromSuperview];
                [elementLabel removeFromSuperview];
            }
            //other cards
            else
            {
                //monster overlay
                UIImageView *monsterOverlay = [[UIImageView alloc] initWithImage:backgroundMonsterOverlayImage];
                monsterOverlay.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
                monsterOverlay.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
                [self addSubview:monsterOverlay];
                
                self.attackLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,CARD_FULL_WIDTH/2,20)];
                self.attackLabel.center = CGPointMake(35, 138);
                self.attackLabel.textAlignment = NSTextAlignmentCenter;
                self.attackLabel.textColor = [UIColor whiteColor];
                self.attackLabel.backgroundColor = [UIColor clearColor];
                self.attackLabel.font = [UIFont fontWithName:cardMainFont size:18];
                self.attackLabel.strokeOn = YES;
                self.attackLabel.strokeColour = [UIColor blackColor];
                self.attackLabel.strokeThickness = 2.5;
                self.attackLabel.text = [NSString stringWithFormat:@"%d", monsterCard.damage];
                
                [self addSubview: attackLabel];
                
                self.lifeLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,CARD_FULL_WIDTH/2,20)];
                self.lifeLabel.center = CGPointMake(CARD_FULL_WIDTH - 33, 138);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor whiteColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                self.lifeLabel.strokeOn = YES;
                self.lifeLabel.strokeColour = [UIColor blackColor];
                self.lifeLabel.strokeThickness = 2.5;
                self.lifeLabel.font = [UIFont fontWithName:cardMainFont size:18];
                self.lifeLabel.text = [NSString stringWithFormat:@"%d", monsterCard.life];
                
                [self addSubview: lifeLabel];
                
                self.cooldownLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
                self.cooldownLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 129);
                self.cooldownLabel.textAlignment = NSTextAlignmentCenter;
                self.cooldownLabel.textColor = [UIColor whiteColor];
                self.cooldownLabel.backgroundColor = [UIColor clearColor];
                self.cooldownLabel.strokeOn = YES;
                self.cooldownLabel.strokeColour = [UIColor blackColor];
                self.cooldownLabel.strokeThickness = 2.5;
                self.cooldownLabel.font = [UIFont fontWithName:cardMainFont size:18];
                self.cooldownLabel.text = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
                
                [self addSubview: cooldownLabel];
            }
        }
        //draws specific card elements for spell card
        else if ([cardModel isKindOfClass:[SpellCardModel class]])
        {
            
            //TODO
            
            //element is a little higher
            self.elementLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 144);
        }
        
        self.damagePopup = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        self.damagePopup.center = self.center;
        self.damagePopup.textAlignment = NSTextAlignmentCenter;
        self.damagePopup.textColor = [UIColor redColor];
        self.damagePopup.backgroundColor = [UIColor clearColor];
        self.damagePopup.font = [UIFont fontWithName:cardMainFontBlack size:28];
        //self.damagePopup.strokeOn = YES;
        //self.damagePopup.strokeColour = [UIColor blackColor];
        //self.damagePopup.strokeThickness = 2.5;
        self.damagePopup.text = @"";
        self.damagePopup.alpha = 0;
        [self addSubview:self.damagePopup];
        
        //adds correct text to all of the labels
        [self updateView];
    }
    
    self.mask = [[UIView alloc] initWithFrame:self.bounds];
    [self.mask setUserInteractionEnabled:NO];
    [self.mask setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.7]];
    self.mask.alpha = 0;
    [self addSubview:self.mask];
    
    self.cardHighlightType = cardHighlightNone;
    self.cardViewState = cardViewStateNone;
    
    return self;
}

-(void)updateView{
    self.nameLabel.text = self.cardModel.name;
    self.costLabel.text = [NSString stringWithFormat:@"%d", self.cardModel.cost];
    
    if ([self.cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel* monsterCard = (MonsterCardModel*) self.cardModel;

        //update damage label
        UIColor *newDamageColour;
        if (monsterCard.damage != monsterCard.baseDamage)
            newDamageColour = [UIColor redColor];
        else
            newDamageColour = [UIColor whiteColor];
        
        NSString *newDamageString = [NSString stringWithFormat:@"%d", monsterCard.damage];
        
        if ((self.damageViewNeedsUpdate || ![newDamageString isEqualToString:self.attackLabel.text]) && self.cardViewMode == cardViewModeIngame)
        {
            self.damageViewNeedsUpdate = NO;
            [CardView animateUILabelChange:self.attackLabel changeTo:newDamageString newColour:newDamageColour];
        }
        else
        {
            self.attackLabel.text = newDamageString;
            self.attackLabel.textColor = newDamageColour;
        }
        
        //update life label
        UIColor *newLifeColour;
        if (monsterCard.life > monsterCard.maximumLife || monsterCard.maximumLife > [monsterCard baseMaxLife])
            newLifeColour = [UIColor redColor];
        else
            newLifeColour = [UIColor whiteColor];
        
        NSString *newLifeString = [NSString stringWithFormat:@"%d", monsterCard.life];
        
        if (self.lifeViewNeedsUpdate && self.cardViewMode == cardViewModeIngame)
        {
            self.lifeViewNeedsUpdate = NO;
            [CardView animateUILabelChange:self.lifeLabel changeTo:newLifeString newColour:newLifeColour];
        }
        else
        {
            self.lifeLabel.text = newLifeString;
            self.lifeLabel.textColor = newLifeColour;
        }
        
        //update cooldown label
        UIColor *newCooldownColour;
        if (monsterCard.cooldown > monsterCard.maximumCooldown || monsterCard.cooldown > monsterCard.baseMaxCooldown || monsterCard.maximumCooldown > monsterCard.baseMaxCooldown)
            newCooldownColour = [UIColor redColor];
        else if (monsterCard.cooldown == 0)
            newCooldownColour = [UIColor greenColor]; //green when at 0 cooldown
        else
            newCooldownColour = [UIColor whiteColor];
        
        NSString* newCooldownString = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
        
        if (self.cooldownViewNeedsUpdate && self.cardViewMode == cardViewModeIngame)
        {
            self.cooldownViewNeedsUpdate = NO;
            [CardView animateUILabelChange:self.cooldownLabel changeTo:newCooldownString newColour:newCooldownColour];
        }
        else
        {
            self.cooldownLabel.text = newCooldownString;
            self.cooldownLabel.textColor = newCooldownColour;
        }
        
        if (self.cardViewMode == cardViewModeIngame || self.cardViewMode == cardViewModeZoomedIngame)
        {
            NSMutableArray *currentAbilityIconImages = [NSMutableArray array];
            
            for (Ability *ability in monsterCard.abilities)
            {
                UIImage *iconImage;
                if (ability.castType == castOnMove || ability.castType == castOnEndOfTurn)
                    iconImage = abilityIconImages[abilityIconCastOnMove];
                else if (ability.castType == castOnDeath)
                    iconImage = abilityIconImages[abilityIconCastOnDeath];
                else if (ability.castType == castOnHit)
                    iconImage = abilityIconImages[abilityIconCastOnHit];
                else if (ability.castType == castOnDamaged)
                    iconImage = abilityIconImages[abilityIconCastOnDamaged];
                else if (ability.targetType == targetSelf)
                {
                    if (ability.abilityType == abilityTaunt)
                        iconImage = abilityIconImages[abilityIconTaunt];
                    else if (ability.abilityType == abilityAssassin)
                        iconImage = abilityIconImages[abilityIconAssassin];
                    else if (ability.abilityType == abilityPierce)
                        iconImage = abilityIconImages[abilityIconPierce];
                    else if (ability.abilityType == abilityRemoveAbility)
                        iconImage = abilityIconImages[abilityIconRemoveAbility];
                }
                
                if (iconImage != nil && ![currentAbilityIconImages containsObject:iconImage])
                    [currentAbilityIconImages addObject:iconImage];
            }
            
            NSMutableArray*abilityIcons = [NSMutableArray array];
            
            //first step, remove all icons that no longer exists
            //loop backwards to prevent con cur mod
            for (int i = self.abilityIcons.count-1; i >= 0 ; i--)
            {
                UIImageView*iconImageView = self.abilityIcons[i];
                
                //remove if doesn't exist
                if (![currentAbilityIconImages containsObject:iconImageView.image])
                {
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         iconImageView.alpha = 0;
                                     }
                                     completion:^(BOOL finished){
                                         [iconImageView removeFromSuperview];
                                     }];
                    [self.abilityIcons removeObjectAtIndex:i];
                }
            }
            
            
            float iconCenterIndex = currentAbilityIconImages.count/2; //for positioning the cards
            if (currentAbilityIconImages.count % 2 == 0)
                iconCenterIndex -= 0.5;
            
            int index = 0;
            
            //go through every new iconImage
            for (UIImage *iconImage in currentAbilityIconImages)
            {
                UIImageView*icon;
                //go through existing images and update them
                for (UIImageView*iconImageView in self.abilityIcons)
                {
                    //already exist, move it here
                    if (iconImageView.image == iconImage)
                    {
                        icon = iconImageView;
                        break;
                    }
                }
                
                int x = (index-iconCenterIndex) * 15 + ((currentAbilityIconImages.count+1)%2 * 3) + self.bounds.size.width/2;
                
                //this is a new icon, create it
                if (icon==nil)
                {
                    icon = [[UIImageView alloc] initWithImage:iconImage];
                    icon.frame = CGRectMake(0, 0, 20, 20);
                    icon.center = CGPointMake(x, self.bounds.size.height - 4);
                    icon.alpha = 0;
                    
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         icon.alpha = 1;
                                     }
                                     completion:nil];
                    
                    [self addSubview:icon];
                }
                else
                {
                    //already exist, simply animate to new position
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         icon.center = CGPointMake(x, self.bounds.size.height - 4);
                                     }
                                     completion:nil];
                }
                
                [abilityIcons addObject:icon]; //add to new array
                index++;
            }
            
            //point to new array
            self.abilityIcons = abilityIcons;
        }
        
        //TODO: need a special view to show both current and max values
        
    }
    else if ([self.cardModel isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel* spellCard = (SpellCardModel*) self.cardModel;
        
        //TODO
    }
    
    NSString *abilityDescription = @"";
    for (Ability *ability in self.cardModel.abilities)
    {
        if (!ability.expired && ability.isBaseAbility)
            abilityDescription = [NSString stringWithFormat:@"%@%@\n", abilityDescription, [[Ability getDescription:ability fromCard:self.cardModel] string]];
    }
    
    self.baseAbilityLabel.attributedText = [[NSAttributedString alloc] initWithString:abilityDescription
                                                                           attributes:abilityTextAttributtes];
    
    self.baseAbilityLabel.frame = CGRectMake(10, 157, CARD_FULL_WIDTH - 20, 140);
    [self.baseAbilityLabel sizeToFit];
}

/** Overwritten center getter. Returns the position based on the card's state */
-(CGPoint)center
{
    /*
     if (self.cardViewState == cardViewStateHighlighted)
     {
     CGPoint newPoint = super.center;
     newPoint.y -= 30;
     return newPoint;
     }
     else if (self.cardViewState == cardViewStateSelected)
     {
     CGPoint newPoint = super.center;
     newPoint.y -= 50;
     return newPoint;
     }*/
    return super.center;
}

/** overwritten center */
-(void)setCenter: (CGPoint)center
{
    self.originalPosition = center;
    super.center = center;
}

-(enum CardViewState) cardViewState
{
    return _cardViewState;
}

-(void)setCardViewState:(enum CardViewState)cardViewState
{
    if (cardViewState == cardViewStateHighlighted)
    {
        //set super position higher
        CGPoint newPoint = self.originalPosition;
        newPoint.y -= 20;
        
        super.center = newPoint;
    }
    else if (cardViewState == cardViewStateSelected)
    {
        //set super position higher
        CGPoint newPoint = self.originalPosition;
        newPoint.y -= 50;
        
        super.center = newPoint;
    }
    else if (cardViewState == cardViewStateDragging)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DRAGGING_SCALE, CARD_DRAGGING_SCALE);
        //self.transform = CGAffineTransformScale(CGAffineTransformIdentity, DRAGGING_SCALE, DRAGGING_SCALE);
        
        //set super position higher
        super.center = self.originalPosition;
    }
    else if (cardViewState == cardViewStateMaximize)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }
    else if (cardViewState == cardViewStateCardViewer)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{self.mask.alpha = 0.0;}
                         completion:nil];
    }
    else if (cardViewState == cardViewStateCardViewerGray)
    {
        //TODO eventually should change this to an image
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{self.mask.alpha = 0.8;}
                         completion:nil];
    }
    else{
        if (self.cardModel.type != cardTypePlayer)
        {
            super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DEFAULT_SCALE, CARD_DEFAULT_SCALE);
        }
        
        //revert super's position
        super.center = self.originalPosition;
    }
    
    //NSLog(@"I'm called on %@", self);
    
    _cardViewState = cardViewState;
}

-(void)setPopupDamage:(int)damage
{
     //assuming this will always be animated in this scale
    
    //new damage
    if ([self.damagePopup.text isEqualToString:@""])
    {
        self.damagePopup.text = [NSString stringWithFormat:@"%d", damage];
        NSLog(@"empty");
    }
    //recently been damaged, update the label
    else
    {
        int totalDamage = [self.damagePopup.text intValue] + damage;
        self.damagePopup.text = [NSString stringWithFormat:@"%d", totalDamage];
        NSLog(@"not empty");
        return;
    }
    
    self.damagePopup.alpha = 1;
    self.damagePopup.transform = CGAffineTransformMakeScale(0, 0);
    
    NSLog(@"starting animation");

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (self.cardModel.type != cardTypePlayer)
                             self.damagePopup.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f/CARD_DEFAULT_SCALE, 1.f/CARD_DEFAULT_SCALE);
                         else
                             self.damagePopup.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1,1);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5 delay:1.3 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.damagePopup.alpha = 0;
                                          }
                                          completion:^(BOOL finished){
                                              self.damagePopup.text = @"";
                                          }];
                     }];
    
    
    
}

-(enum CardHighlightType) cardHighlightType
{
    return _cardHighlightType;
}

-(void)setCardHighlightType:(enum CardHighlightType)cardHighlightType
{
    if(cardHighlightType == cardHighlightNone)
    {
        self.highlight.alpha = 0;
        //[self stopCardHighlightAnimation:self.highlight];
        [self.highlight.layer removeAllAnimations];
    }
    else if (cardHighlightType == cardHighlightSelect)
    {
        if (self.cardModel.type == cardTypePlayer)
            self.highlight.image = heroSelectHighlightImage;
        else
            self.highlight.image = selectHighlightImage;
        
        self.highlight.alpha = 0.5;
        [self animateCardHighlightBrighten:self.highlight];
    }
    else if (cardHighlightType == cardHighlightTarget)
    {
        if (self.cardModel.type == cardTypePlayer)
            self.highlight.image = heroTargetHighlightImage;
        else
            self.highlight.image = targetHighlightImage;
        
        self.highlight.alpha = 0.5;
        [self animateCardHighlightBrighten:self.highlight];
    }
    
    _cardHighlightType = cardHighlightType;
}

-(void)resetTransformations
{
    self.cardViewState = self.cardViewState; //this causes the setCardViewState to be called again
}

-(void)castedAbility:(Ability*)ability
{
    //TODO could add a cast on summon, would be nice
    if (ability.castType == castOnDeath)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnDeath])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
    else if (ability.castType == castOnHit)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnHit])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
    else if (ability.castType == castOnDamaged)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnDamaged])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
    else if (ability.castType == castOnMove || ability.castType == castOnEndOfTurn)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnMove])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
}

-(void)animateCardHighlightBrighten: (UIImageView*)highlight
{
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{highlight.alpha = 1;}
                     completion:^(BOOL finished){
                         if (!finished)return; //stops the animation on removal
                         [self animateCardHighlightDim:highlight];
                     }];
}

-(void)animateCardHighlightDim: (UIImageView*)highlight
{
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{highlight.alpha = 0.5;}
                     completion:^(BOOL finished){
                         if (!finished)return; //stops the animation on removal
                         [self animateCardHighlightBrighten:highlight];
                     }];
}

+(void)animateUILabelChange: (UILabel*)label changeTo:(NSString*)newString newColour:(UIColor*)newColour
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         label.transform = CGAffineTransformMakeScale(2, 2);
                     }
                     completion:^(BOOL finished){
                         label.text = newString;
                         label.textColor = newColour;
                         [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              label.transform = CGAffineTransformMakeScale(1, 1);
                                          }
                                          completion:nil];
                     }];
}

+(void)animateIconCast: (UIView*)view
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(4, 4);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(1, 1);
                                          }
                                          completion:nil];
                     }];
}

@end
