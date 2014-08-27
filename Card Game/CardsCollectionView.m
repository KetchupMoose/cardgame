//
//  CardsCollectionView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-24.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardsCollectionView.h"
#import "CardView.h"
#import "DeckEditorViewController.h"
#import "CFLabel.h"

@implementation CardsCollectionView

@synthesize currentCardModels = _currentCardModels;
@synthesize collectionView = _collectionView;
@synthesize parentViewController = _parentViewController;
@synthesize isScrolling = _isScrolling;



- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout: (UICollectionViewLayout*)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionView = [[CustomCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        
        
        self.currentCardModels = [NSMutableArray array];
        
        [self.collectionView registerClass:[CardsCollectionCell class] forCellWithReuseIdentifier:@"cardsCollectionCell"];
        
        //CFLabel*background = [[CFLabel alloc] initWithFrame:self.bounds];
        //[_collectionView setBackgroundView:background];
        [_collectionView setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
        
        [self.collectionView setDataSource:self];
        [self.collectionView setDelegate:self];
        [self setUserInteractionEnabled:YES];
        
        [self addSubview:self.collectionView];
        
        /*
        self.layer.cornerRadius = 15;
        
        CAShapeLayer * _border;
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor blackColor].CGColor;
        _border.fillColor = nil;
        _border.lineWidth = 2;
        _border.lineDashPattern = @[@5, @8];
        CGRect boundsRect = CGRectMake(self.bounds.origin.x + 7, self.bounds.origin.y + 7, self.bounds.size.width - 14, self.bounds.size.height - 14);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:boundsRect cornerRadius:15];
        _border.path = path.CGPath;
        _border.cornerRadius = 15;
        _border.frame = self.bounds;
        [self.layer addSublayer:_border];
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor blackColor].CGColor;
         */
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentCardModels count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardsCollectionCell" forIndexPath:indexPath];
    
    //cell.backgroundColor=[UIColor greenColor];
    //if (cell.cardView != nil)
    
    [cell.cardView removeFromSuperview];
    
    CardModel*card = self.currentCardModels[indexPath.row];
    
    cell.cardView = [[CardView alloc] initWithModel:card viewMode:card.cardViewState viewState:card.cardViewState];
    cell.cardView.frontFacing = YES;
    cell.cardView.cardHighlightType = cardHighlightNone;
    cell.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
    cell.cardView.center = cell.center;
    cell.cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
    
    [cell addSubview:cell.cardView];
    
    NSLog(@"%d", cell.cardView.cardViewState);
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CARD_FULL_WIDTH*CARD_VIEWER_SCALE,CARD_FULL_HEIGHT*CARD_VIEWER_SCALE);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0); //removes insets
}

-(void)removeCellAt:(int)index onFinish:(void (^)())block
{
    if (index < self.currentCardModels.count)
    {
        [self.collectionView performBatchUpdates:^{
            [self.currentCardModels removeObjectAtIndex:index];
            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        } completion:^(BOOL finished) {
            block();
        }];
    }
}

-(void)removeAllCells
{
    [self.currentCardModels removeAllObjects];
    [self.collectionView reloadData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
    {
        [self.superview touchesEnded:touches withEvent:event];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesCancelled:touches withEvent:event];
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isScrolling = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
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
