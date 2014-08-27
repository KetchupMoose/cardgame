//
//  DeckChooserViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-03.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckChooserViewController.h"
#import "UserModel.h"
#import "UIConstants.h"
#import "CardView.h"


@interface DeckChooserViewController ()

@end

@implementation DeckChooserViewController

@synthesize deckBackground = _deckBackground;

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    self.view.backgroundColor = COLOUR_INTERFACE_BLUE_DARK;
    
    self.deckView = [[DeckTableView alloc] initWithFrame:CGRectMake(230,0,90,SCREEN_HEIGHT)];
    
    [self.view addSubview:self.deckView];
    [self.deckView setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    
    self.deckBackground = [[UIView alloc]initWithFrame:CGRectMake(20, 160, 190, 230)];
    [self.deckBackground setBackgroundColor:COLOUR_NEUTRAL_DARK];
    [self.deckBackground.layer setCornerRadius:8];
    [self.deckBackground.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.deckBackground.layer setBorderWidth:2];
    [self.view addSubview:self.deckBackground];
    
    //CFLabel*titleBackground = [[CFLabel alloc] initWithFrame:CGRectMake(-3, 10, self.deckBackground.bounds.size.width+6, 40)];
    _titleBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0, 0, self.deckBackground.bounds.size.width+6, 40)];
    _titleBackground.center = CGPointMake(115, 190);
    _titleBackground.backgroundColor = COLOUR_INTERFACE_BLUE;
    [self.view addSubview:_titleBackground]; //cannot add to deckbackground due to layer stuff
    _titleBackground.alpha = 0;
    
    self.deckBackground.alpha = 0;
    
    
    //label showing opponent's name:
    if (![self.opponentName isEqualToString:@""])
    {
        UILabel*opponentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,200,30)];
        [opponentLabel setFont:[UIFont fontWithName:cardMainFont size:18]];
        [opponentLabel setText:@"Your Opponent:"];
        [opponentLabel setTextAlignment:NSTextAlignmentCenter];
        [opponentLabel setCenter:CGPointMake(115, 40)];
        [opponentLabel setTextColor:[UIColor blackColor]];
        
        [self.view addSubview:opponentLabel];
        
        self.opponentNameLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(0,0,200,30)];
        [self.opponentNameLabel setFont:[UIFont fontWithName:cardMainFont size:22]];
        [self.opponentNameLabel setText:self.opponentName];
        [self.opponentNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.opponentNameLabel setCenter:CGPointMake(115, 70)];
        [self.opponentNameLabel setTextColor:[UIColor blackColor]];
        
        [self.view addSubview:self.opponentNameLabel];
    }
    
    //label that informs the player to choose a deck
    self.chooseDeckLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,200,30)];
    [self.chooseDeckLabel setFont:[UIFont fontWithName:cardMainFont size:18]];
    [self.chooseDeckLabel setText:@"Choose A Deck"];
    [self.chooseDeckLabel setTextAlignment:NSTextAlignmentCenter];
    [self.chooseDeckLabel setCenter:CGPointMake(115, 130)];
    [self.chooseDeckLabel setTextColor:[UIColor blackColor]];
    
    [self.view addSubview:self.chooseDeckLabel];
    
    //name of the deck currently chosen
    self.chosenDeckNameLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,200,40)];
    self.chosenDeckNameLabel.center = CGPointMake(_titleBackground.bounds.size.width/2, 20);
    self.chosenDeckNameLabel.textAlignment = NSTextAlignmentCenter;
    self.chosenDeckNameLabel.textColor = [UIColor whiteColor];
    self.chosenDeckNameLabel.backgroundColor = [UIColor clearColor];
    self.chosenDeckNameLabel.font = [UIFont fontWithName:cardMainFont size:20];
    [self.chosenDeckNameLabel setMinimumScaleFactor:12.f/20];
    self.chosenDeckNameLabel.adjustsFontSizeToFitWidth = YES;
    self.chosenDeckNameLabel.strokeColour = [UIColor blackColor];
    self.chosenDeckNameLabel.strokeOn = YES;
    self.chosenDeckNameLabel.strokeThickness = 3;
    //self.chosenDeckNameLabel.text = @"New Deck";
    
    [_titleBackground addSubview: self.chosenDeckNameLabel];
    
    
    
    CFLabel*elementsBackground = [[CFLabel alloc] initWithFrame:CGRectMake(6,55,self.deckBackground.bounds.size.width/2-6-3,168)];
    elementsBackground.backgroundColor = COLOUR_NEUTRAL;
    [self.deckBackground addSubview:elementsBackground];
    
    self.chosenDeckElementSummaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,55,self.deckBackground.bounds.size.width-90,160)];
    self.chosenDeckElementSummaryLabel.numberOfLines = 5;
    [self.chosenDeckElementSummaryLabel setTextAlignment:NSTextAlignmentLeft];
    [self.chosenDeckElementSummaryLabel setFont:[UIFont fontWithName:cardMainFont size:14]];
    [self.chosenDeckElementSummaryLabel setTextColor:[UIColor blackColor]];
    
    [self.deckBackground addSubview:self.chosenDeckElementSummaryLabel];
    
    CFLabel*tagsBackground = [[CFLabel alloc] initWithFrame:CGRectMake(self.deckBackground.bounds.size.width/2 + 3,55,self.deckBackground.bounds.size.width/2-6-3,168)];
    tagsBackground.backgroundColor = COLOUR_NEUTRAL;
    [self.deckBackground addSubview:tagsBackground];
    
    self.chosenDeckTagsLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.deckBackground.bounds.size.width/2+5,55,self.deckBackground.bounds.size.width/2-10,180)];
    [self.chosenDeckTagsLabel setFont:[UIFont fontWithName:cardMainFont size:14]];
    self.chosenDeckTagsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.chosenDeckTagsLabel.numberOfLines = 8;
    [self.chosenDeckTagsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.chosenDeckTagsLabel setTextColor:[UIColor blackColor]];
    
    [self.deckBackground addSubview:self.chosenDeckTagsLabel];
    
    self.chooseDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 90, 75)];
    self.chooseDeckButton.buttonStyle = CFButtonStyleWarning;
    self.chooseDeckButton.center = CGPointMake(115, SCREEN_HEIGHT-41);
    self.chooseDeckButton.label.text = @"Battle";
    [self.chooseDeckButton setTextSize:22];
    
    //[self.chooseDeckButton setImage:[UIImage imageNamed:@"battle_button"] forState:UIControlStateNormal];
    //[self.chooseDeckButton setImage:[UIImage imageNamed:@"battle_button_gray"] forState:UIControlStateDisabled];
    [self.chooseDeckButton addTarget:self action:@selector(battleButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.chooseDeckButton setEnabled:NO];
    
    [self.view addSubview:self.chooseDeckButton];
    
    self.backButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    
    [self.backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.backButton];
    
    [self resetAllViews];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    UIView*view = touch.view;
    
    //selecting an existing deck
    NSIndexPath *indexPath = [self.deckView.tableView indexPathForRowAtPoint:[touch locationInView:self.deckView]];
    
    if (indexPath)
    {
        if ([self.deckView.currentCells[indexPath.row] isKindOfClass:[DeckModel class]])
        {
            DeckModel *deck = self.deckView.currentCells[indexPath.row];
            if (deck.isInvalid) //not a valid deck, can't be clicked
                return;
            
            self.currentDeck = deck;
            
            self.deckBackground.alpha = 1;
            self.titleBackground.alpha = 1;
            
            self.chosenDeckElementSummaryLabel.text = [DeckModel getElementSummary:deck];
            self.chosenDeckElementSummaryLabel.frame = CGRectMake(15,60,self.deckBackground.bounds.size.width/2-24,160);
            [self.chosenDeckElementSummaryLabel sizeToFit];
            
            NSString*tags = @"";
            for (NSString *tag in deck.tags)
            {
                if (tags.length > 0)
                    tags = [NSString stringWithFormat:@"%@, %@", tags, tag];
                else
                    tags = [NSString stringWithFormat:@"%@", tag];
            }
            
            [self.chosenDeckTagsLabel setText:tags];
            self.chosenDeckTagsLabel.frame = CGRectMake(self.deckBackground.bounds.size.width/2+10,60,self.deckBackground.bounds.size.width/2-24,160);
            [self.chosenDeckTagsLabel sizeToFit];
            
            self.chosenDeckNameLabel.text = self.currentDeck.name;
            
            if (self.currentDeck.isInvalid)
                [self.chooseDeckButton setEnabled:NO];
            else
                [self.chooseDeckButton setEnabled:YES];
        }
    }
    
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)resetAllViews
{
    [self.deckView removeAllCells];
    self.currentDeck = nil;
    
    //[self.view addSubview:backButton];
    
    //add user decks
    self.deckView.viewMode = deckTableViewDecks;
    for (DeckModel*deck in userAllDecks)
    {
        [DeckModel validateDeck:deck];
        [self.deckView.currentCells addObject:deck];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0];
        [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.deckView.tableView reloadInputViews];
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)battleButtonPressed
{
    userCurrentDeck = self.currentDeck;
    [self presentViewController:self.nextScreen animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {return YES;}

@end