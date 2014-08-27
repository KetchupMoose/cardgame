//
//  StoreCardsCollectionView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StoreCardsCollectionView.h"
#import "StoreCardCell.h"
#import "GameStore.h"
#import "StoreViewController.h"

@implementation StoreCardsCollectionView

@synthesize currentCards = _currentCards;
@synthesize collectionView = _collectionView;

int STORE_CARD_WIDTH, STORE_CARD_HEIGHT;
int STORE_CELL_WIDTH, STORE_CELL_HEIGHT;

/** Depends on device. Iphone = 2 */
int numberOfColumns;

const int CARD_CELL_INSET = 8;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        numberOfColumns = 2; //TODO different for ipad
        STORE_CELL_WIDTH = self.bounds.size.width/numberOfColumns - 2; //a little border
        STORE_CELL_HEIGHT = STORE_CELL_WIDTH * CARD_HEIGHT_RATIO/CARD_WIDTH_RATIO + 50; //TODO the 50 should also scale
        
        STORE_CARD_WIDTH = STORE_CELL_WIDTH-CARD_CELL_INSET;
        STORE_CARD_HEIGHT = STORE_CARD_WIDTH * CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO;
        
        _currentCards = [NSMutableArray array];
        _loadingCells = [NSMutableArray array];
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.collectionView = [[CustomCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        
        [self.collectionView registerClass:[StoreCardCell class] forCellWithReuseIdentifier:@"storeCardsCollectionCell"];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        
        [self.collectionView setDataSource:self];
        [self.collectionView setDelegate:self];
        //self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self setUserInteractionEnabled:YES];
        
        [self addSubview:self.collectionView];
        
        
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentSales count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoreCardCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"storeCardsCollectionCell" forIndexPath:indexPath];
    
    //cell.backgroundColor=[UIColor greenColor];
    //if (cell.cardView != nil)
    [cell.cardView removeFromSuperview];
    [cell.statsView removeFromSuperview];
    
    [cell addSubview:cell.activityView];
    [cell.activityView startAnimating];
    
    if (indexPath.row >= 0 && indexPath.row < self.currentCards.count)
    {
        CardModel*card = self.currentCards[indexPath.row];
        
        //card may be null at this point (hasn't been loaded)
        if (card == (id)[NSNull null] && ![_loadingCells containsObject:indexPath])
        {
            [self loadCellAtIndexPath:indexPath];
        }
        //loaded
        else if (![_loadingCells containsObject:indexPath]) //i.e. not loading
        {
            //CardModel*card = self.currentCards[indexPath.row];
            PFObject*cardPF = self.currentCardsPF[indexPath.row];
            
            cell.cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeEditor viewState:card.cardViewState];
            cell.cardView.frontFacing = YES;
            cell.cardView.cardHighlightType = cardHighlightNone;
            cell.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            cell.cardView.center = cell.center;
            
            cell.cardView.frame = CGRectMake(CARD_CELL_INSET,CARD_CELL_INSET,STORE_CARD_WIDTH,STORE_CARD_HEIGHT);
            cell.costLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:card]];
            cell.likesLabel.text = [NSString stringWithFormat:@"%d", [cardPF[@"likes"] intValue]];
            
            [cell addSubview:cell.cardView];
            [cell addSubview:cell.statsView];
            
            [cell.activityView stopAnimating];
            [cell.activityView removeFromSuperview];
        }
    }
    return cell;
}

//this function prevents loading for the wrong cell when scrolling is too fast
-(void)loadCellAtIndexPath:(NSIndexPath*)indexPath
{
    //saves the query ID so that when card is loaded, the ID is compared to check if it's out of date
    int queryID = cardStoreQueryID;
    //NSLog(@"saved query id: %d for indexPath: %d",  queryID, indexPath.row);
    [_loadingCells addObject:indexPath];
    
    //NSLog(@"%d got into null", indexPath.row);
    //[self performBlockInBackground:^(void){
    int i = indexPath.row;
    
    if (i >= self.currentSales.count)
    {
        [_loadingCells removeObject:indexPath];
        //NSLog(@"INDEX LARGER THAN SALE COUNT");
        //try again
        /*
        [self performBlockInBackground:^{
            sleep(0.1);
        } onFinish:^{
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                if (![_loadingCells containsObject:indexPath])
                    [self loadCellAtIndexPath:indexPath];
            });
        }];
        */
        return;
    }
    
    //NSLog(@"%d %d", i, self.currentSales.count-1);
    if (i == self.currentSales.count-1)
    {
        //NSLog(@"reached end");
        [self scrolledToEnd];
    }
    
    PFObject *sale = self.currentSales[i];
    PFObject *cardPF = sale[@"card"];
    
    [sale save];
    [self performBlockInBackground:^(void){
        //somehow even query has include, cardPF can still be nil
        NSError*error;
        [cardPF fetchIfNeeded:&error];
        if (error)
            return;
        //[cardPF fetch];
        self.currentCardsPF[i] = cardPF;
        
        //TODO this is still not exactly correct, as when a tab/filter is hit, all these cells progresses should be destroyed
        CardModel *cardModel = [CardModel createCardFromPFObject:cardPF onFinish:^(CardModel*cardModel){
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                //if query ID has been updated (i.e. new query sent), then this query is out of date and should be removed
                //NSLog(@"original id: %d currentID %d for path:%d", queryID, cardStoreQueryID, indexPath.row);
                if (i < 0 || i >= self.currentCards.count || queryID != cardStoreQueryID)
                {
                    //failed to load this cell, no longer loading
                    [_loadingCells removeObject:indexPath];
                    
                    //reload the cell
                    if (![_loadingCells containsObject:indexPath])
                        [self loadCellAtIndexPath:indexPath];
                    return;
                }
                
                self.currentCards[i] = cardModel;
                StoreCardCell *cell = (StoreCardCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                cell.cardView = [[CardView alloc] initWithModel:cardModel viewMode:cardViewModeEditor viewState:cardModel.cardViewState];
                cell.cardView.frontFacing = YES;
                cell.cardView.cardHighlightType = cardHighlightNone;
                cell.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                cell.cardView.center = cell.center;
                cell.cardView.frame = CGRectMake(CARD_CELL_INSET,CARD_CELL_INSET,STORE_CARD_WIDTH, STORE_CARD_HEIGHT);
                cell.costLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:cardModel]];
                cell.likesLabel.text = [NSString stringWithFormat:@"%d", [cardPF[@"likes"] intValue]];
                
                [cell.activityView stopAnimating];
                [cell.activityView removeFromSuperview];
                
                [cell addSubview:cell.cardView];
                [cell addSubview:cell.statsView];
                
                [self.collectionView reloadInputViews];
                
                [_loadingCells removeObject:indexPath];
            });
        }];
        
        if (cardModel == nil)
            NSLog(@"ERROR: Create card from parse returned nil in StoreCardsCollectionView");
        //}];
        
    } onFinish:nil];
    
}

-(void)scrolledToEnd
{
    if (_parentViewController != nil && [_parentViewController isKindOfClass:[StoreViewController class]])
    {
        NSLog(@"scrolled to end");
        StoreViewController *svc = (StoreViewController*)_parentViewController;
        [svc storeScrolledToEnd];
    }
}

- (void)performBlockInBackground:(void (^)())block onFinish:(void (^)())onFinish {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (block!=nil)
            block();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (onFinish!=nil)
                onFinish();
        });
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return CGSizeMake(CARD_FULL_WIDTH*STORE_CARD_SCALE,CARD_FULL_HEIGHT*STORE_CARD_SCALE + 50);
    
    return CGSizeMake(STORE_CELL_WIDTH, STORE_CELL_HEIGHT);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0); //removes insets
}

@end
