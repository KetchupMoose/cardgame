//
//  DeckEditorViewController.m
//  cardgame
//
//  Created by Macbook on 2014-06-21.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckEditorViewController.h"
#import "DeckModel.h"
#import "CardView.h"
#import "CardModel.h"
#import "SinglePlayerCards.h"
#import "UserModel.h"
#import "MainScreenViewController.h"
#import "StrokedLabel.h"

@interface DeckEditorViewController ()

@end


@implementation DeckEditorViewController
@synthesize cardsView = _cardsView;
@synthesize deckView = _deckView;

//double CARD_VIEWER_SCALE = 0.8;
/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

/** UILabel used to darken the screen during card selections */
UILabel *darkFilter;

/** Currently maximized card */
CardView *currentCard;
/** Original view of the currently maximized card */
CardView *originalCurrentCard;
/** Index of currentCard in the collection */
int currentIndex = -1;

CFButton *addCardToDeckButton, *removeCardFromDeckButton;

/** Shows the number of cards currently in the deck */
UILabel *deckCountLabel;

/** Label explaining why the card cannot be added */
UILabel *cannotAddCardReasonLabel;

/** Used to add another deck */
CFButton *addDeckButton;

/** Buttons for pressing the addDeckButton when the deck is invalid */
CFButton *autoAddCardsButton, *notAutoAddCardsButton, *autoAddCardsFailedButton, *notFixDeckButton, *cancelNotFixButton;
UILabel *autoAddCardsLabel, *autoAddCardsFailedLabel;
UIView*autoAddView;
UIView*fixCardView;

/** Used to save and return to organizing decks*/
CFButton *saveDeckButton;

/** Add a new deck */
CFButton *addDeckButton;

/** Returns to main menu */
CFButton *backButton;

/** The current deck being organized when deckView is in card mode if is nil, a new deck is being created. */
DeckModel* currentDeck;

UILabel *deleteDeckLabel;

CFButton*invalidDeckButton;
StrokedLabel*invalidDeckLabel;

/** For unmaximizing */
enum CardCollectinViewMode lastVCardCollectionViewMode;

DeckModel * allCards;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
   
    //cost 0 to 10
    _costFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)]];
    
    //7 elements
    _elementFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)]];
    
    //5 rarities
    _rarityFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES)]];
    
    //get the single player deck TODO
    //allCards = userAllCards;
    allCards = [[DeckModel alloc] init];
    
    for (CardModel* card in userAllCards)
    {
        [allCards addCard:[[CardModel alloc] initWithCardModel: card]];
    }
    
    //sort the cards
    [allCards.cards sortUsingComparator:^(CardModel* a, CardModel* b){
         return [a compare:b];
     }];
    
    //set up cards view
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.cardsView = [[CardsCollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-366-42, SCREEN_WIDTH-88, 366) collectionViewLayout:layout];
    self.cardsView.parentViewController = self; //for callbacks
    self.cardsView.backgroundColor = COLOUR_INTERFACE_BLUE_TRANSPARENT;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.cardsView];
    
    [self.view setUserInteractionEnabled:YES];
    [self.cardsView setUserInteractionEnabled:YES];
    
    //set up deck view
    self.deckView = [[DeckTableView alloc] initWithFrame:CGRectMake(230,0,90,SCREEN_HEIGHT-42)];
    
    [self.view addSubview:self.deckView];
    [self.deckView setUserInteractionEnabled:YES];
    
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT-44,SCREEN_WIDTH, 44)];
    //_footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    CFLabel*footerBackground = [[CFLabel alloc] initWithFrame:CGRectMake(-8, 0, _footerView.frame.size.width+16, _footerView.frame.size.height+8)];
    [footerBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    [_footerView addSubview:footerBackground];
    
    //set up UI
    darkFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
    darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    
    addCardToDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    addCardToDeckButton.center = CGPointMake(SCREEN_WIDTH - 45, SCREEN_HEIGHT-85);
    [addCardToDeckButton setImage:[UIImage imageNamed:@"add_button"] forState:UIControlStateNormal];
    [addCardToDeckButton addTarget:self action:@selector(addCardToDeckPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    removeCardFromDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    removeCardFromDeckButton.center = CGPointMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT-80);
    [removeCardFromDeckButton setImage:[UIImage imageNamed:@"remove_button"] forState:UIControlStateNormal];
    
    [removeCardFromDeckButton addTarget:self action:@selector(removeCardFromDeckPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //deck count label
    deckCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 115, 8, 90, 40)];
    deckCountLabel.textAlignment = NSTextAlignmentCenter;
    deckCountLabel.textColor = [UIColor blackColor];
    deckCountLabel.backgroundColor = [UIColor clearColor];
    deckCountLabel.font = [UIFont fontWithName:cardMainFont size:16];
    [_footerView addSubview:deckCountLabel];
    
    cannotAddCardReasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 120, 200, 120)];
    cannotAddCardReasonLabel.textColor = [UIColor redColor];
    cannotAddCardReasonLabel.backgroundColor = [UIColor clearColor];
    cannotAddCardReasonLabel.font = [UIFont fontWithName:cardMainFont size:14];
    cannotAddCardReasonLabel.textAlignment = NSTextAlignmentLeft;
    cannotAddCardReasonLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cannotAddCardReasonLabel.numberOfLines = 6;
    
    //save deck button
    saveDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    [saveDeckButton setImage:[UIImage imageNamed:@"save_deck_button"] forState:UIControlStateNormal];
    [saveDeckButton addTarget:self action:@selector(saveDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveDeckButton];
    
    addDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT-36, 46, 32)];
    [addDeckButton setImage:[UIImage imageNamed:@"add_deck_button"] forState:UIControlStateNormal];
    [addDeckButton addTarget:self action:@selector(addDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    backButton = [[CFButton alloc] initWithFrame:CGRectMake(4, 8, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 8, 46, 32)];
    [self.deleteDeckButton setImage:[UIImage imageNamed:@"remove_deck_button"] forState:UIControlStateNormal];
    [self.deleteDeckButton addTarget:self action:@selector(deleteButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    autoAddView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    //---------------------filter view----------------------//
    _filterToggleButton = [[CFButton alloc] initWithFrame:CGRectMake(4 + 50, 8, 46, 32)];
    _filterToggleButton.label.text = @"Filter";
    [_filterToggleButton setTextSize:10];
    [_filterToggleButton addTarget:self action:@selector(filterToggleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_filterToggleButton];
    
    //save deck dialog
    autoAddCardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    autoAddCardsLabel.textColor = [UIColor whiteColor];
    autoAddCardsLabel.backgroundColor = [UIColor clearColor];
    autoAddCardsLabel.font = [UIFont fontWithName:cardMainFont size:25];
    autoAddCardsLabel.textAlignment = NSTextAlignmentCenter;
    autoAddCardsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    autoAddCardsLabel.numberOfLines = 0;
    //autoAddCardsLabel.text;
    [autoAddCardsLabel sizeToFit];
    [autoAddView addSubview:autoAddCardsLabel];
    
    autoAddCardsButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    autoAddCardsButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    autoAddCardsButton.label.text = @"Yes";
    [autoAddCardsButton setTextSize:18];
    [autoAddCardsButton addTarget:self action:@selector(autoAddCardsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    notAutoAddCardsButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    notAutoAddCardsButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    notAutoAddCardsButton.label.text = @"No";
    [notAutoAddCardsButton setTextSize:18];
    [notAutoAddCardsButton addTarget:self action:@selector(notAutoAddCardsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    notFixDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    notFixDeckButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    notFixDeckButton.label.text = @"Yes";
    [notFixDeckButton setTextSize:18];
    [notFixDeckButton addTarget:self action:@selector(notFixDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    cancelNotFixButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    cancelNotFixButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    cancelNotFixButton.label.text = @"No";
    [cancelNotFixButton setTextSize:18];
    [cancelNotFixButton addTarget:self action:@selector(cancelNotFixButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    autoAddCardsFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    autoAddCardsFailedLabel.textColor = [UIColor whiteColor];
    autoAddCardsFailedLabel.backgroundColor = [UIColor clearColor];
    autoAddCardsFailedLabel.font = [UIFont fontWithName:cardMainFont size:25];
    autoAddCardsFailedLabel.textAlignment = NSTextAlignmentCenter;
    autoAddCardsFailedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    autoAddCardsFailedLabel.numberOfLines = 0;
    autoAddCardsFailedLabel.text = @"Sorry, you don't have enough valid cards to fill up this deck. Please try again with different cards.";
    [autoAddCardsFailedLabel sizeToFit];
    
    autoAddCardsFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    autoAddCardsFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    autoAddCardsFailedButton.label.text = @"Ok";
    [autoAddCardsFailedButton setTextSize:18];
    [autoAddCardsFailedButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
    //[saveDeckButton addTarget:self action:@selector(saveDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //delete deck dialog
    deleteDeckLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT/2)];
    deleteDeckLabel.textColor = [UIColor whiteColor];
    deleteDeckLabel.backgroundColor = [UIColor clearColor];
    deleteDeckLabel.font = [UIFont fontWithName:cardMainFont size:25];
    deleteDeckLabel.textAlignment = NSTextAlignmentCenter;
    deleteDeckLabel.lineBreakMode = NSLineBreakByWordWrapping;
    deleteDeckLabel.numberOfLines = 0;
    deleteDeckLabel.text = @"Are you sure you want to delete this deck?";
    [deleteDeckLabel sizeToFit];
    
    self.deleteDeckConfirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.deleteDeckConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    self.deleteDeckConfirmButton.label.text = @"Ok";
    [self.deleteDeckConfirmButton setTextSize:18];
    [self.deleteDeckConfirmButton addTarget:self action:@selector(deleteDeckConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteDeckCancelButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.deleteDeckCancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    self.deleteDeckCancelButton.label.text = @"No";
    [self.deleteDeckCancelButton setTextSize:18];
    [self.deleteDeckCancelButton addTarget:self action:@selector(deleteDeckCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    
    _searchResult = [[StrokedLabel alloc] initWithFrame:CGRectMake(10, self.cardsView.frame.size.height/2 - 40, self.cardsView.frame.size.width - 20, self.cardsView.frame.size.height)];
    _searchResult.textColor = [UIColor whiteColor];
    _searchResult.backgroundColor = [UIColor clearColor];
    _searchResult.font = [UIFont fontWithName:cardMainFont size:20];
    _searchResult.textAlignment = NSTextAlignmentCenter;
    _searchResult.lineBreakMode = NSLineBreakByWordWrapping;
    _searchResult.numberOfLines = 0;
    _searchResult.strokeOn = YES;
    _searchResult.strokeColour = [UIColor blackColor];
    _searchResult.strokeThickness = 3;
    _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
    [_cardsView addSubview:_searchResult];
    
    invalidDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(104,8,58, 32)];
    invalidDeckButton.buttonStyle = CFButtonStyleWarning;
    invalidDeckButton.label.text = @"Problems";
    [invalidDeckButton setTextSize:9];
    [invalidDeckButton addTarget:self action:@selector(invalidDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    _deckLimitationsButton = [[CFButton alloc] initWithFrame:CGRectMake(164,SCREEN_HEIGHT-36,58, 32)];
    _deckLimitationsButton.label.text = @"Limits";
    [_deckLimitationsButton setTextSize:10];
    [_deckLimitationsButton addTarget:self action:@selector(deckLimitationsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];

    /** Activity */
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicator setFrame:self.view.bounds];
    [_activityIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
    [_activityIndicator setUserInteractionEnabled:YES];
    _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _activityLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _activityLabel.text = [NSString stringWithFormat:@"Processing..."];
    [_activityIndicator addSubview:_activityLabel];
    
    _activityFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _activityFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _activityFailedButton.label.text = @"Ok";
    [_activityFailedButton setTextSize:18];
    [_activityFailedButton addTarget:self action:@selector(activityFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    _invalidDeckReasonsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    _invalidDeckReasonsLabel.textColor = [UIColor whiteColor];
    _invalidDeckReasonsLabel.backgroundColor = [UIColor clearColor];
    _invalidDeckReasonsLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _invalidDeckReasonsLabel.textAlignment = NSTextAlignmentCenter;
    _invalidDeckReasonsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _invalidDeckReasonsLabel.numberOfLines = 10;
    
    _invalidDeckReasonsOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _invalidDeckReasonsOkButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _invalidDeckReasonsOkButton.label.text = @"Ok";
    [_invalidDeckReasonsOkButton setTextSize:18];
    [_invalidDeckReasonsOkButton addTarget:self action:@selector(invalidDeckReasonsOkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //property view
    _propertiesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-_deckView.frame.size.width, _cardsView.frame.origin.y)];
    //_propertiesView.backgroundColor = [UIColor redColor];
    
    CFLabel*propertiesBackground = [[CFLabel alloc] initWithFrame:CGRectMake(_propertiesView.frame.origin.x, _propertiesView.frame.origin.y - 8, _propertiesView.frame.size.width+2, _propertiesView.frame.size.height + 8)];
    [propertiesBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    [self.view addSubview:propertiesBackground];
    
    _tagsPopularButton = [[CFButton alloc] initWithFrame:CGRectMake(_propertiesView.frame.size.width - 52 - 4, _propertiesView.frame.size.height - 36, 50, 28)];
    
    if (SCREEN_HEIGHT >= 568)
    {
        _tagsPopularButton = [[CFButton alloc] initWithFrame:CGRectMake(8, _propertiesView.frame.size.height - 40, 50, 32)];
    }
    _tagsPopularButton.label.text = @"Suggest";
    [_tagsPopularButton setTextSize:9];
    
    

    [_propertiesView addSubview:_tagsPopularButton];
    
    UILabel*deckNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 5, 45, 25)];
    deckNameLabel.textColor = [UIColor blackColor];
    deckNameLabel.font = [UIFont fontWithName:cardMainFont size:16];
    deckNameLabel.textAlignment = NSTextAlignmentRight;
    deckNameLabel.text = @"Name:";
    [_propertiesView addSubview:deckNameLabel];
    
    _nameField =  [[UITextField alloc] initWithFrame:CGRectMake(59,4,_propertiesView.frame.size.width - 55 - 12,30)];
    _nameField.textColor = [UIColor blackColor];
    _nameField.font = [UIFont fontWithName:cardMainFont size:16];
    _nameField.returnKeyType = UIReturnKeyDone;
    [_nameField setPlaceholder:@"Name your deck"];
    [_nameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    //[_nameField addTarget:self action:@selector(searchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    //[_nameField addTarget:self action:@selector(searchFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    [_nameField setDelegate:self];
    [_nameField.layer setBorderColor:[UIColor blackColor].CGColor];
    [_nameField.layer setBorderWidth:2];
    _nameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    [_nameField setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    
    [_propertiesView addSubview:_nameField];
    
    UILabel*deckTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 40, 45, 25)];
    deckTagsLabel.textColor = [UIColor blackColor];
    deckTagsLabel.font = [UIFont fontWithName:cardMainFont size:16];
    deckTagsLabel.textAlignment = NSTextAlignmentRight;
    deckTagsLabel.text = @"Tags:";
    [_propertiesView addSubview:deckTagsLabel];
    
    _tagsArea = [[UITextView alloc] initWithFrame:CGRectMake(59, 38, _propertiesView.frame.size.width - 105 - 12, _propertiesView.frame.size.height - 38 - 8)];
    _tagsArea.textColor = [UIColor blackColor];
    [_tagsArea setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    _tagsArea.font = [UIFont fontWithName:cardMainFont size:16];
    [_tagsArea setAutocorrectionType:UITextAutocorrectionTypeNo];
    //[_nameField addTarget:self action:@selector(searchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    //[_nameField addTarget:self action:@selector(searchFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    [_tagsArea setDelegate:self];
    [_tagsArea.layer setBorderColor:[UIColor blackColor].CGColor];
    [_tagsArea.layer setBorderWidth:2];
    _tagsArea.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    //_tagsArea.layer.cornerRadius = 4.0;
    
    if (SCREEN_HEIGHT >= 568)
        _tagsArea.frame = CGRectMake(59, 38, _propertiesView.frame.size.width - 55 - 12, _propertiesView.frame.size.height - 38 - 8);
    
    [_propertiesView addSubview:_tagsArea];
    
    [self.view addSubview:_propertiesView];
    
    //-------------------filter view------------------//
    _filterView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 250)];
    [self.view insertSubview:_filterView aboveSubview:_deckView];
    [_filterView setUserInteractionEnabled:YES];
    [_filterView setBackgroundColor:[UIColor whiteColor]];
    
    //cost buttons
    CGPoint costFilterStartPoint = CGPointMake(20, 20);
    _costFilterButtons = [NSMutableArray arrayWithCapacity:11];
    for (int i = 0; i < 11; i++)
    {
        UIButton*costFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,28,28)];
        [costFilterButton setImage:RESOURCE_ICON_IMAGE forState:UIControlStateNormal];
        [costFilterButton addTarget:self action:@selector(costFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        costFilterButton.center = CGPointMake(costFilterStartPoint.x + i*28, costFilterStartPoint.y);
        
        [_filterView addSubview:costFilterButton];
        
        StrokedLabel*costLabel = [[StrokedLabel alloc]initWithFrame:costFilterButton.bounds];
        costLabel.textAlignment = NSTextAlignmentCenter;
        costLabel.textColor = [UIColor whiteColor];
        costLabel.backgroundColor = [UIColor clearColor];
        costLabel.font = [UIFont fontWithName:cardMainFontBlack size:22];
        costLabel.strokeOn = YES;
        costLabel.strokeColour = [UIColor blackColor];
        costLabel.strokeThickness = 3;
        costLabel.text = [NSString stringWithFormat:@"%d", i];
        [costFilterButton addSubview:costLabel];
        //costLabel.center = costFilterButton.center;
        
        [_costFilterButtons addObject:costFilterButton];
    }
    
    //rarity buttons
    CGPoint rarityFilterStartPoint = CGPointMake(SCREEN_WIDTH/3, 60);
    _rarityFilterButtons = [NSMutableArray arrayWithCapacity:cardRarityLegendary+1];
    for (int i = 0; i <= cardRarityLegendary; i++)
    {
        CFButton*rarityFilterButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [rarityFilterButton.dottedBorder removeFromSuperlayer];
        rarityFilterButton.label.text = [CardModel getRarityText:i];
        [rarityFilterButton setTextSize:14];
        //[rarityFilterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        [rarityFilterButton addTarget:self action:@selector(rarityFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        rarityFilterButton.center = CGPointMake(rarityFilterStartPoint.x, rarityFilterStartPoint.y + i*28);
        
        [_filterView addSubview:rarityFilterButton];
        
        /*
        StrokedLabel*rarityLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(0, 0, 90, 25)];
        rarityLabel.textAlignment = NSTextAlignmentCenter;
        rarityLabel.textColor = [UIColor whiteColor];
        rarityLabel.backgroundColor = [UIColor clearColor];
        rarityLabel.font = [UIFont fontWithName:cardMainFont size:18];
        //rarityLabel.strokeOn = YES;
        rarityLabel.strokeColour = [UIColor blackColor];
        rarityLabel.strokeThickness = 3;
        rarityLabel.text = [CardModel getRarityText:i];
        [rarityFilterButton addSubview:rarityLabel];
        //rarityLabel.backgroundColor = [UIColor blueColor];
        //costLabel.center = costFilterButton.center;
        */
        [_rarityFilterButtons addObject:rarityFilterButton];
    }
    
    //element buttons
    CGPoint elementFilterStartPoint = CGPointMake(SCREEN_WIDTH*2/3, 60);
    _elementFilterButtons = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 7; i++)
    {
        CFButton*elementFilterButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [elementFilterButton.dottedBorder removeFromSuperlayer];
        elementFilterButton.label.text = [CardModel elementToString:i];
        [elementFilterButton setTextSize:14];
        [elementFilterButton addTarget:self action:@selector(elementFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        elementFilterButton.center = CGPointMake(elementFilterStartPoint.x, elementFilterStartPoint.y + i*28);
        
        [_filterView addSubview:elementFilterButton];

        //costLabel.center = costFilterButton.center;
        
        [_elementFilterButtons addObject:elementFilterButton];
    }
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
    
    [self resetAllViews];
}

/** Update all cards to ensure cards that cannot be added are grayed out */
- (void) updateCardsViewCards
{
    for (CardModel* card in self.cardsView.currentCardModels)
    {
        [self updateCard:card];
    }
}

-(void) updateCard:(CardModel*)card
{
    if ([self.deckView containsCardId:card.idNumber])
    {
        card.cardViewState = cardViewStateCardViewerTransparent;
    }
    else if ([[self canAddCardToDeck: card] count] == 0)
    {
        //NSLog(@"can add");
        card.cardViewState = cardViewStateCardViewer;
    }
    else
    {
        //NSLog(@"can't add");
        card.cardViewState = cardViewStateCardViewerGray;
    }
    
    //prevent updating pointers that wrongly points to the deckview
    if (card.cardView != nil && card.cardView.superview != nil && [card.cardView.superview isKindOfClass:[CardsCollectionCell class]])
        card.cardView.cardViewState = card.cardViewState;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIView*touchedView = touch.view;
    
    //touched a card in current list of cards
    if ([touchedView isKindOfClass:[CardView class]])
    {
        CardView*cardView = (CardView*)touchedView;
        UIView*view = cardView.superview;
        
        //cardsView
        if ([cardView.superview isKindOfClass:[UICollectionViewCell class]])
        {
            if (cardView != currentCard && currentCard == nil && cardView.cardViewState != cardViewStateCardViewerTransparent)
            {
                CardView*newMaximizedView = [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor]; //constructor also modifies monster's cardView pointer
                newMaximizedView.frontFacing = YES;
                [newMaximizedView setCardViewState:cardView.cardViewState];
                
                newMaximizedView.cardModel.cardView = cardView; //recover the pointer
                
                //find index of cardView
                for (int i = 0; i < self.cardsView.currentCardModels.count; i++)
                    if (self.cardsView.currentCardModels[i] == [cardView cardModel])
                    {
                        currentIndex = i;
                        break;
                    }
                
                //store this card as currentCard
                currentCard = newMaximizedView;
                originalCurrentCard = cardView;
                
                CGPoint cardViewCenter = [self.view convertPoint:cardView.center fromView:cardView];
                
                //scrolls to left or right side depending on current position (TODO: may feel kinda weird)
                enum UICollectionViewScrollPosition scrollDir;
                
                if (cardViewCenter.x < self.cardsView.frame.origin.x + self.cardsView.frame.size.width/2)
                    scrollDir = UICollectionViewScrollPositionLeft;
                else
                    scrollDir = UICollectionViewScrollPositionRight;
                
                [self.cardsView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]  animated:YES scrollPosition:scrollDir];
                
                //NSLog(@"%@ %@", NSStringFromCGRect(cardViewRect), NSStringFromCGRect(self.cardsView.frame));
                
                
                //[self.cardsView.collectionView scrollRectToVisible:CGRectMake(cardViewTopLeft.x, cardViewTopLeft.y, cardView.frame.size.width, cardView.frame.size.height) animated:YES];
                
                [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionAddCard];
                if ([self isFilterOpen])
                    [self setFilterViewState:NO];
            }
        }
        else if ([cardView.superview isKindOfClass:[UIScrollView class]])
        {
            //nearly identical code with cardview
            if (cardView != currentCard && currentCard == nil)
            {
                CardView*newMaximizedView = [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor]; //constructor also modifies monster's cardView pointer
                newMaximizedView.frontFacing = YES;
                [newMaximizedView setCardViewState:cardView.cardViewState];
                
                newMaximizedView.cardModel.cardView = cardView; //recover the pointer
                
                //find index of cardView in table
                for (int i = 0; i < self.deckView.currentCells.count; i++)
                    if (self.deckView.currentCells[i] == cardView.cardModel)
                    {
                        currentIndex = i;
                        break;
                    }
                
                //store this card as currentCard
                currentCard = newMaximizedView;
                originalCurrentCard = cardView;
                
                CGPoint cardViewCenter = [self.view convertPoint:cardView.center fromView:cardView];
                
                [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionRemoveCard];
                if ([self isFilterOpen])
                    [self setFilterViewState:NO];
            }
        }
        else if (cardView == currentCard)
        {
            //[self addCardToDeckPressed];
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
                                 currentCard.center = [self.view convertPoint:originalCurrentCard.center fromView:originalCurrentCard];
                             }
                             completion:^(BOOL completed){
                                 [currentCard removeFromSuperview];
                                 currentCard = nil;
                             }];
            
            [self unmaximizeCard:lastVCardCollectionViewMode];
        }
    }
    else
    {
        //selecting an existing deck
        NSIndexPath *indexPath = [self.deckView.tableView indexPathForRowAtPoint:[touch locationInView:self.deckView]];
        
        if (indexPath)
        {
            //because for whatever reason it's possible to select a card view here
            if ([self.deckView.currentCells[indexPath.row] isKindOfClass:[DeckModel class]])
            {
                currentDeck = self.deckView.currentCells[indexPath.row];
                
                [self setupDeckEditView];
            }
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(BOOL)isRowVisible: (int)row {
    NSArray *indexes = [self.cardsView.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexes)
        if (index.row == row)
            return YES;
    
    return NO;
}

-(void)cardsViewFinishedScrollingAnimation
{
   
}

/** Performs the animation of the card maximizing. Will wait for cardsView's scrolling to finish before playing. */
-(void) maximizeCardAnimation:(CardView*)newMaximizedView originalCard:(CardView*)cardView mode:(enum CardCollectinViewMode)mode
{
    [self performBlock:^{
        if (self.cardsView.isScrolling)
        {
            [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:mode];
        }
        else
        {
            //darken the background (also disables views)
            [self maximizeCard:mode];
            
            //[currentCard setCardViewState:cardViewStateMaximize];
            
            //for the maximizing animation, the new card starts out in the same size and pos as the original card
            currentCard.transform = originalCurrentCard.transform;
            currentCard.center = [self.view convertPoint:originalCurrentCard.center fromView:originalCurrentCard];
            
            //the new view is a maxed card for closing viewing
            [self.view addSubview:currentCard];
            
            //animate the maximizing
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_MAXED_SCALE, CARD_VIEWER_MAXED_SCALE);
                                 currentCard.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 40);
                             }
                             completion:nil];
        }
    } afterDelay:0.05];
}

-(void)darkenScreen
{
    darkFilter.alpha = 0;
    [self.view addSubview:darkFilter];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0.9;
                     }
                     completion:nil];
}

-(void)undarkenScreen
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [darkFilter removeFromSuperview];
                     }];
}

-(void)maximizeCard:(enum CardCollectinViewMode)mode
{
    lastVCardCollectionViewMode = mode;
    darkFilter.alpha = 0;
    
    [self.view addSubview:darkFilter];
    
    if (mode == cardCollectionAddCard)
    {
        addCardToDeckButton.alpha = 0;
        cannotAddCardReasonLabel.alpha = 0;
        [addCardToDeckButton setEnabled:YES];
        
        [self.view addSubview:addCardToDeckButton];
        
        NSMutableArray*reasons = [self canAddCardToDeck:currentCard.cardModel];
        if (reasons.count > 0)
        {
            BOOL currentDeckValid = [self isCurrentDeckValidIgnoreTooFewCards];
            
            NSString *reasonsText = @"Cannot add this card to deck.\n";
            
            if (currentDeckValid)
            {
            for (NSString *reason in reasons)
                reasonsText = [NSString stringWithFormat:@"%@- %@\n", reasonsText, reason];
            }
            else
                reasonsText = [NSString stringWithFormat:@"%@- Target deck is currently invalid. Fix the problem first before adding any more cards.", reasonsText];
            
            cannotAddCardReasonLabel.text = reasonsText;
            [cannotAddCardReasonLabel sizeToFit];
            [self.view addSubview:cannotAddCardReasonLabel];
            [addCardToDeckButton setEnabled:NO];
        }
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0.9;
                             addCardToDeckButton.alpha = 1;
                             cannotAddCardReasonLabel.alpha = 1;
                         }
                         completion:nil];
    }
    else if (mode == cardCollectionRemoveCard)
    {
        removeCardFromDeckButton.alpha = 0;
        [self.view addSubview:removeCardFromDeckButton];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0.9;
                             removeCardFromDeckButton.alpha = 1;
                         }
                         completion:nil];
    }
}

-(void)unmaximizeCard:(enum CardCollectinViewMode)mode
{
    if (mode == cardCollectionAddCard)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0;
                             addCardToDeckButton.alpha = 0;
                             cannotAddCardReasonLabel.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [darkFilter removeFromSuperview];
                             [addCardToDeckButton removeFromSuperview];
                             if (cannotAddCardReasonLabel.superview!=nil)
                                 [cannotAddCardReasonLabel removeFromSuperview];
                         }];
    }
    else if (mode == cardCollectionRemoveCard)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0;
                             removeCardFromDeckButton.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [darkFilter removeFromSuperview];
                             [removeCardFromDeckButton removeFromSuperview];
                         }];
    }
}

- (void) addCardToDeckPressed
{
    [currentCard removeFromSuperview];
    
    [self addCardToDeckView:currentCard.cardModel];
    
    currentCard = nil;
    
    [self unmaximizeCard:cardCollectionAddCard];
    //[self.cardsView removeCellAt:currentIndex onFinish:^(void){[self updateCardsViewCards];}];
    //TODO fade it instead
    
    currentIndex = -1;
}

/** Inserts the card into the correct position in the deck view */
-(void)addCardToDeckView: (CardModel*)card
{
    int insertionIndex = -1;
    
    //insert at the first position where card < card at index
    for (int i = 0; i < [self.deckView.currentCells count]; i++)
    {
        CardModel *cellCard = self.deckView.currentCells[i];
        if ([card compare:cellCard] == NSOrderedAscending)
        {
            insertionIndex = i;
            break;
        }
    }
    
    //not found index, insert at end
    if (insertionIndex == -1)
        insertionIndex = self.deckView.currentCells.count;
    
    [self.deckView.currentCells insertObject:card atIndex:insertionIndex];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertionIndex inSection:0];
    [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.deckView.tableView reloadInputViews];
    
    //scroll to the newly inserted position
    [self.deckView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:insertionIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if([self isCurrentDeckValid])
        [invalidDeckButton removeFromSuperview];
    
    [self updateCardsViewCards];
    [self updateCardsCounterLabel];
}

-(void) removeCardFromDeckPressed
{
    [currentCard removeFromSuperview];
    
    currentCard = nil;
    
    [self unmaximizeCard:cardCollectionRemoveCard];
    [self.deckView removeCellAt:currentIndex];
    [self updateCardsCounterLabel];
    [self updateCardsViewCards];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    currentIndex = -1;
    
    if([self isCurrentDeckValid])
        [invalidDeckButton removeFromSuperview];
}

/** Inserts the card into the correct position in the cards view */
/*
-(void)addCardToCardsView: (CardView*)card
{
    int insertionIndex = -1;
    
    //insert at the first position where card < card at index
    for (int i = 0; i < [self.cardsView.currentCardModels count]; i++)
    {
        CardModel *cellCard = self.cardsView.currentCardModels[i];
        if ([card.cardModel compare:cellCard] == NSOrderedAscending)
        {
            insertionIndex = i;
            break;
        }
    }
    
    //not found index, insert at end
    if (insertionIndex == -1)
        insertionIndex = self.cardsView.currentCardModels.count;
    
    card.cardHighlightType = cardHighlightNone;
    card.cardViewState = cardViewStateCardViewer;
    card.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
    
    [self.cardsView.currentCardModels insertObject:card atIndex:insertionIndex];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertionIndex inSection:0];
    [self.cardsView.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
    [self.cardsView.collectionView reloadInputViews];
}*/

-(void) saveDeck
{
    DeckModel *deckToSave;
    if (currentDeck == nil)
    {
        //add this new deck to userModel
        DeckModel* newDeck = [[DeckModel alloc] init];
        newDeck.name = @"New Deck";
        
        for (CardModel* card in self.deckView.currentCells)
            [newDeck addCard:card];
     
        deckToSave = newDeck;
    }
    else
    {
        //clear the deck and add the new cards in
        [currentDeck.cards removeAllObjects];
        
        for (CardModel* card in self.deckView.currentCells)
            [currentDeck addCard:card];
        
        deckToSave = currentDeck;
    }
    
    if (_nameField.text.length == 0)
        deckToSave.name = @"New Deck";
    else
        deckToSave.name = _nameField.text;
    
    if (_tagsArea.text.length > 0)
    {
        NSString *tags = [_tagsArea.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSArray*stringSplit = [tags componentsSeparatedByString:@" "];
        NSMutableArray*tagsNoDup = [NSMutableArray array];
        
        for (NSString*string in stringSplit)
        {
            if (![tagsNoDup containsObject:string] && string.length > 0)
                [tagsNoDup addObject:string];
        }
        
        deckToSave.tags = tagsNoDup;
    }
    
    //save the deck only if it actually exists
    if (deckToSave != nil)
    {
        [self showActivityIndicatorWithBlock:^BOOL{
            BOOL succ = [UserModel saveDeck:deckToSave];
            if (succ)
            {
                [self resetAllViews];
                return YES;
            }
            else
                return NO;
        } loadingText:@"Saving..." failedText:@"Failed to save deck."];
    }
    else
        [self resetAllViews];
}

-(void) saveDeckButtonPressed
{
    if ([self isCurrentDeckValid])
    {
        [self saveDeck];
    }
    else
    {
        NSLog(@"not valid");
        
        DeckModel *deck = [[DeckModel alloc]init];
        for (CardModel* card in self.deckView.currentCells)
            [deck addCard:card];
        
        for (UIView*view in autoAddView.subviews)
            [view removeFromSuperview];
        
        autoAddCardsLabel.frame = CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT);
        
        //TODO: algorithm to automatically add decks is probably impossible (or just not very useful) because of the restriction between cards
        /*
        BOOL deckTooSmall = [DeckModel isDeckInvalidOnlyTooFewCards:deck];
        if (deckTooSmall)
        {
            autoAddCardsLabel.text = @"You haven't added enough cards to fill up the deck. Would you like them to be added automatically?";
            
            [autoAddView addSubview:autoAddCardsButton];
            [autoAddView addSubview:notAutoAddCardsButton];
        }
        else
        {*/
            autoAddCardsLabel.text = @"The deck you are trying to save is invalid. Would you like to quit anyways?";
            
            [autoAddView addSubview:notFixDeckButton];
            [autoAddView addSubview:cancelNotFixButton];
        //}
        
        [autoAddCardsLabel sizeToFit];
        
        [autoAddView addSubview:autoAddCardsLabel];
        
        autoAddView.alpha = 0;
        
        [self darkenScreen];
        [self.view addSubview:autoAddView];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             autoAddView.alpha = 1;
                         }
                         completion:^(BOOL completed){
                         }];
    }
}

-(void) updateCardsCounterLabel
{
    deckCountLabel.text = [NSString stringWithFormat:@"%d/%d", self.deckView.currentCells.count, MAX_CARDS_IN_DECK];
}


-(void) updateDeckCounterLabel
{
    deckCountLabel.text = [NSString stringWithFormat:@"%d/%d", self.deckView.currentCells.count, userDeckLimit];
}


/** Returns list of reasons why the deck is invalid. If is valid, returns empty array */
-(NSMutableArray*) canAddCardToDeck: (CardModel*) card
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [deck addCard:card];
    [DeckModel validateDeckIgnoreTooFewCards:deck];
    
    return deck.invalidReasons;
}

-(BOOL) isCurrentDeckValid
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [DeckModel validateDeck:deck];
    
    return !deck.isInvalid;
}

-(BOOL)isCurrentDeckValidIgnoreTooFewCards
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [DeckModel validateDeckIgnoreTooFewCards:deck];
    
    return !deck.isInvalid;
}

-(void)autoAddCardsButtonPressed
{
    //TODO temporary method, just add random cards
    //TODO later needs to add cards that is actually valid
    NSMutableArray*ownedCards = [NSMutableArray array];
    for (CardModel*card in self.cardsView.currentCardModels)
        [ownedCards addObject:card];
    
    while (self.deckView.currentCells.count < MAX_CARDS_IN_DECK)
    {
        int randomIndex = [[NSNumber numberWithUnsignedInteger:arc4random_uniform(ownedCards.count - 1)] intValue];
        
        CardModel*cardModel = ownedCards[randomIndex];
        
        int insertionIndex = -1;
        
        //insert at the first position where card < card at index
        for (int i = 0; i < [self.deckView.currentCells count]; i++)
        {
            CardModel *cellCard = self.deckView.currentCells[i];
            if ([cardModel compare:cellCard] == NSOrderedAscending)
            {
                insertionIndex = i;
                break;
            }
        }
        
        //not found index, insert at end
        if (insertionIndex == -1)
            insertionIndex = self.deckView.currentCells.count;
        
        [self.deckView.currentCells insertObject:cardModel atIndex:insertionIndex];
        [ownedCards removeObjectAtIndex:randomIndex];
    }
    
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    [self undarkenScreen];
    
    [self saveDeck];
}

-(void)notAutoAddCardsButtonPressed
{
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    
    [self saveDeck];
    
    [self undarkenScreen];
}

-(void)notFixDeckButtonPressed
{
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    
    //save the deck so they can finish it later
    [self saveDeck];
    
    [self undarkenScreen];
}

-(void)cancelNotFixButtonPressed
{
    //removes the view and makes no changes
    
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    
    [self undarkenScreen];
}


/** Resets all views to when it's first opened */
-(void)resetAllViews
{
    [self.deleteDeckButton removeFromSuperview];
    
    [self.cardsView removeAllCells];
    [self.deckView removeAllCells];
    currentDeck = nil;
    
    _searchResult.text = @"Select or create a deck to view your cards.";
    _searchResult.frame = CGRectMake(10, self.cardsView.frame.size.height/2 - 40, self.cardsView.frame.size.width - 20, self.cardsView.frame.size.height);
    [_searchResult sizeToFit];
    
    [saveDeckButton removeFromSuperview];
    [_filterToggleButton removeFromSuperview];
    [_deckLimitationsButton removeFromSuperview];
    
    if ([self isFilterOpen])
        [self setFilterViewState:NO];
    
    for (UIView*view in _propertiesView.subviews)
        view.alpha = 0;
    
    [self.view addSubview:addDeckButton];
    [_footerView addSubview:backButton];
    
    //add user decks
    self.deckView.viewMode = deckTableViewDecks;
    for (DeckModel*deck in userAllDecks)
    {
        [DeckModel validateDeck:deck];
        [self.deckView.currentCells addObject:deck];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0];
        [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
                //scroll to the newly inserted position
        /*
         [self.deckView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
         */
    }
    
    [invalidDeckButton removeFromSuperview];
    [self.deckView.tableView reloadInputViews];
    [self.deckView.tableView reloadData];
    [self updateDeckCounterLabel];
}

/** Setups the views for deck editing. If currentDeck is nil, assuming it's a new deck */
-(void)setupDeckEditView
{
    [backButton removeFromSuperview];
    
    [self.deckView removeAllCells];
    
    self.deckView.viewMode = deckTableViewCards;
    
    //get all cards in the existing deck
    if (currentDeck!=nil)
    {
        for (CardModel*card in currentDeck.cards)
            [self.deckView.currentCells addObject:[[CardModel alloc] initWithCardModel:card]];
        
        if (currentDeck.isInvalid)
            [_footerView addSubview:invalidDeckButton];
        
        [self.view addSubview:_deckLimitationsButton];
        
        _nameField.text = currentDeck.name;
        NSString*tagsString = @"";
        for (NSString *tag in currentDeck.tags)
        {
            tagsString = [NSString stringWithFormat:@"%@%@ ", tagsString, [tag lowercaseString]];
        }
        _tagsArea.text = tagsString;
    }
    else{
        _nameField.text = @"";
        _tagsArea.text = @"";
    }
    
    [_footerView addSubview:self.deleteDeckButton];
    
    [_footerView addSubview:_filterToggleButton];
    for (UIView*view in _propertiesView.subviews)
        view.alpha = 1;
    
    
    [self reloadCardsWithFilter];
    
    [self updateCardsCounterLabel];
    
    [addDeckButton removeFromSuperview];
    _searchResult.text = @"";
    
    [self.view addSubview:saveDeckButton];
    
    //[self.cardsView.collectionView reloadData];
    //[self.cardsView.collectionView reloadInputViews];
}

-(void)addDeckButtonPressed
{
    //TODO if reached limit, ask user to visit store to buy more space
    
    currentDeck = nil;
    [self setupDeckEditView];
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)deleteButtonPressed
{
    [self darkenScreen];
    
    [self.deleteDeckConfirmButton setEnabled:NO];
    [self.deleteDeckCancelButton setEnabled:NO];
    
    self.deleteDeckConfirmButton.alpha = 0;
    self.deleteDeckCancelButton.alpha = 0;
    deleteDeckLabel.alpha = 0;
    
    [self.view addSubview:self.deleteDeckConfirmButton];
    [self.view addSubview:self.deleteDeckCancelButton];
    [self.view addSubview:deleteDeckLabel];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.deleteDeckConfirmButton.alpha = 1;
                         self.deleteDeckCancelButton.alpha = 1;
                         deleteDeckLabel.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [self.deleteDeckConfirmButton setEnabled:YES];
                         [self.deleteDeckCancelButton setEnabled:YES];
                     }];
}

-(void)deleteDeckConfirmButtonPressed
{
    //delete the deck only if it actually exists
    if (currentDeck != nil)
    {
        [self showActivityIndicatorWithBlock:^BOOL{
            BOOL succ = [UserModel deleteDeck:currentDeck];
            if (succ)
            {
                [self deleteDeckCancelButtonPressed]; //just to get rid of the dialogs
                [self resetAllViews];
                return YES;
            }
            else
                return NO;
        } loadingText:@"Deleting..." failedText:@"Failed to delete deck."];
    }
    else
    {
        [self deleteDeckCancelButtonPressed]; //just to get rid of the dialogs
        [self resetAllViews];
    }
}

-(void)deleteDeckCancelButtonPressed
{
    self.deleteDeckConfirmButton.alpha = 1;
    self.deleteDeckCancelButton.alpha = 1;
    deleteDeckLabel.alpha = 1;
    
    [self.deleteDeckConfirmButton setEnabled:NO];
    [self.deleteDeckCancelButton setEnabled:NO];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.deleteDeckConfirmButton.alpha = 0;
                         self.deleteDeckCancelButton.alpha = 0;
                         deleteDeckLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [self.deleteDeckConfirmButton removeFromSuperview];
                         [self.deleteDeckCancelButton removeFromSuperview];
                         [deleteDeckLabel removeFromSuperview];
                     }];
    
    [self undarkenScreen];
}

-(void)invalidDeckButtonPressed
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [DeckModel validateDeck:deck];
    
    NSString *invalidDeckReasons = @"Problems with the deck:\n";
    
    for (NSString *reason in deck.invalidReasons)
        invalidDeckReasons = [NSString stringWithFormat:@"%@- %@\n", invalidDeckReasons, reason];
    
    
    _invalidDeckReasonsLabel.frame = CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/6, SCREEN_WIDTH*6/8, SCREEN_HEIGHT);
    _invalidDeckReasonsLabel.text = invalidDeckReasons;
    
    [_invalidDeckReasonsLabel sizeToFit];
    
    [self darkenScreen];
    
    [self.view addSubview:_invalidDeckReasonsLabel];
    [self.view addSubview:_invalidDeckReasonsOkButton];
    
    _invalidDeckReasonsLabel.alpha = 0;
    _invalidDeckReasonsOkButton.alpha = 0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _invalidDeckReasonsLabel.alpha = 1;
                         _invalidDeckReasonsOkButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)deckLimitationsButtonPressed
{
    //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    
    
    
    
    
    
    
    
    
    
    
}

-(void)invalidDeckReasonsOkButtonPressed
{
    [self undarkenScreen];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _invalidDeckReasonsLabel.alpha = 0;
                         _invalidDeckReasonsOkButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_invalidDeckReasonsLabel removeFromSuperview];
                         [_invalidDeckReasonsOkButton removeFromSuperview];
                     }];
}

-(void)filterToggleButtonPressed
{
    [self setFilterViewState:![self isFilterOpen]];
}

-(BOOL)isFilterOpen
{
    return [_filterToggleButton isSelected];
}

-(void)setFilterViewState:(BOOL)state
{
    _filterToggleButton.selected = state;
    
    CGRect filterViewFrame = _filterView.frame;
    if (state)
    {
        _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/5);
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y - filterViewFrame.size.height, filterViewFrame.size.width, filterViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else
    {
        _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y + filterViewFrame.size.height, filterViewFrame.size.width, filterViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
}

-(void)reloadCardsWithFilter
{
    [self.cardsView.currentCardModels removeAllObjects];
    
    [self.deckView.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    //get the CardView of every card in the deck
    for (CardModel *card in allCards.cards)
    {
        if (card.cost >= 0 && card.cost < _costFilter.count)
        {
            if ([_costFilter[card.cost] boolValue] == NO)
                continue;
        }
        
        if ((int)card.element >= 0 && (int)card.element < _elementFilter.count)
        {
            if ([_elementFilter[card.element] boolValue] == NO)
                continue;
        }
        
        if ((int)card.rarity >= 0 && (int)card.rarity < _rarityFilter.count)
        {
            if ([_rarityFilter[card.rarity] boolValue] == NO)
                continue;
        }
        
        [self updateCard:card];
        [self.cardsView.currentCardModels addObject:card];
    }

    [self.cardsView.collectionView performBatchUpdates:^{
        [self.cardsView.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished){
        [self updateCardsViewCards];
    }];
    
    CGPoint searchResultCenter = _searchResult.center;
    if (self.cardsView.currentCardModels.count == 0)
    {
        _searchResult.text = @"No cards found. Please double check your filter settings.";
    }
    else
    {
        _searchResult.text = @"";
    }
    _searchResult.frame = CGRectMake(10, self.cardsView.frame.size.height/2 - 40, self.cardsView.frame.size.width - 20, self.cardsView.frame.size.height);
    [_searchResult sizeToFit];
    _searchResult.center = searchResultCenter;
}

-(void)costFilterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _costFilterButtons)
    {
        if (senderButton == button)
        {
            _costFilter[i] = @(!([_costFilter[i] boolValue]));
            button.alpha = [_costFilter[i] boolValue] ? 1 : 0.4;
            break;
        }
        i++;
    }
    
    [self reloadCardsWithFilter];
    
}

-(void)rarityFilterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _rarityFilterButtons)
    {
        if (senderButton == button)
        {
            _rarityFilter[i] = @(!([_rarityFilter[i] boolValue]));
            button.alpha = [_rarityFilter[i] boolValue] ? 1 : 0.4;
            break;
        }
        i++;
    }
    
    [self reloadCardsWithFilter];
}

-(void)elementFilterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _elementFilterButtons)
    {
        if (senderButton == button)
        {
            _elementFilter[i] = @(!([_elementFilter[i] boolValue]));
            button.alpha = [_elementFilter[i] boolValue] ? 1 : 0.4;
            break;
        }
        i++;
    }
    
    [self reloadCardsWithFilter];
}

-(void)showActivityIndicatorWithBlock:(BOOL (^)())block loadingText:(NSString*)loadingText failedText:(NSString*)failedText
{
    _activityIndicator.alpha = 0;
    _activityLabel.text = loadingText;
    [_activityIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         BOOL succ = block();
                         
                         if (succ)
                         {
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityIndicator.alpha = 0;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityIndicator stopAnimating];
                                                  [_activityIndicator removeFromSuperview];
                                              }];
                         }
                         else
                         {
                             [_activityIndicator setColor:[UIColor clearColor]];
                             _activityLabel.text = failedText;
                             _activityFailedButton.alpha = 0;
                             [_activityIndicator addSubview:_activityFailedButton];
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityFailedButton.alpha = 1;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityFailedButton setUserInteractionEnabled:YES];
                                              }];
                         }
                     }];
}

-(void)activityFailedButtonPressed
{
    [_activityFailedButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_activityFailedButton removeFromSuperview];
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


-(void)tapRegistered
{
    [_nameField resignFirstResponder];
    [_tagsArea resignFirstResponder];
}

//block delay functions
- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (BOOL)prefersStatusBarHidden {return YES;}

@end
