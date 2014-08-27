//
//  DeckCollectionView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-25.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckTableView.h"
#import "CardView.h"
#import "DeckModel.h"
#import "DeckCell.h"
#import "DeckCardCell.h"
#import "CFLabel.h"

@implementation DeckTableView

@synthesize tableView = _tableView;
@synthesize currentCells = _currentCells;
@synthesize viewMode = _viewMode;

const double DECK_EDITOR_CARD_SCALE = 0.6;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.viewMode = deckTableViewCards;
        
        _tableView = [[CustomTableView alloc] initWithFrame:self.bounds];
        
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        CFLabel*background = [[CFLabel alloc] initWithFrame:self.bounds];
        [background setBackgroundColor:COLOUR_INTERFACE_BLUE];
        [_tableView setBackgroundView:background];
        
        [_tableView registerClass:[DeckCardCell class] forCellReuseIdentifier:@"deckTableCardCell"];
        [_tableView registerClass:[DeckCell class] forCellReuseIdentifier:@"deckTableDeckCell"];
        _tableView.rowHeight = 40;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        [self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentCells = [NSMutableArray array];
    }
    
    return self;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentCells count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewMode == deckTableViewCards)
    {
        DeckCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deckTableCardCell" forIndexPath:indexPath];
        
        [cell.cardView removeFromSuperview];
        
        CardModel*card = self.currentCells[indexPath.row];
        CardView*originalView = card.cardView;
        CardView*cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeEditor];
        cardView.frontFacing = YES;
        card.cardView = originalView; //recover pointer
        cardView.cardHighlightType = cardHighlightNone;
        cardView.cardViewState = cardViewStateCardViewer;
        //cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DECK_EDITOR_CARD_SCALE, DECK_EDITOR_CARD_SCALE);
        
        cardView.center = CGPointMake(cell.center.x, 68);
        cell.cardView = cardView;
        [cell addSubview:cardView];
        
        return cell;
    }
    else if (self.viewMode == deckTableViewDecks)
    {
        DeckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deckTableDeckCell" forIndexPath:indexPath];
        
        DeckModel*deck = self.currentCells[indexPath.row];
        
        cell.nameLabel.text = deck.name;
        //because cell size is wrong in its constructor..
        cell.nameLabel.frame = CGRectMake(0,0,cell.bounds.size.width - 20, 20);
        cell.nameLabel.center = CGPointMake(cell.bounds.size.width/2, cell.nameLabel.center.y);
        
        cell.invalidLabel.center = CGPointMake(cell.bounds.size.width/2, cell.invalidLabel.center.y);
        
        //remove all element icons
        for (UIView*elementIcon in cell.elementIcons)
            [elementIcon removeFromSuperview];
        
        NSArray*elementSummary = [DeckModel getElementArraySummary:deck];
        NSMutableArray*includedElements = [NSMutableArray array];
        
        //add all element icons that are in the deck
        for (int i = 0; i < elementSummary.count; i++)
        {
            NSNumber*elementCount = elementSummary[i];
            if ([elementCount intValue] > 0)
                [includedElements addObject:cell.elementIcons[i]];
        }
        
        double centerIndex = (includedElements.count-1)/2.f;
        
        //add the element icons to cell
        for (int i = 0; i < includedElements.count; i++)
        {
            UIView*elementIcon = includedElements[i];
            elementIcon.center = CGPointMake(cell.bounds.size.width/2 + (i-centerIndex)*elementIcon.frame.size.width,cell.bounds.size.height-10);
            [cell addSubview:elementIcon];
        }
        
        if (deck.isInvalid)
            [cell addSubview:cell.invalidLabel];
        else
            [cell.invalidLabel removeFromSuperview];

        
        return cell;
    }
    
    
    
    //greatly improves performance but freezes scale?
    //cell.layer.shouldRasterize = YES;
    //cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return nil;
}

-(BOOL)containsCardId:(int)idNumber
{
    if (_viewMode == deckTableViewCards)
    {
        for (CardModel*card in _currentCells)
        {
            if (card.idNumber == idNumber)
                return YES;
        }
    }
    
    return NO;
}

-(void)removeCellAt:(int)index {
    if (index < self.currentCells.count)
    {
        [self.currentCells removeObjectAtIndex:index];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)removeAllCells
{
    [self.currentCells removeAllObjects];
    [self.tableView reloadData];
    
    //clear all cells
    //while([self.tableView dequeueReusableCellWithIdentifier:@"deckTableCell"]!=nil);
}

@end
