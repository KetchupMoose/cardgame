//
//  UserModel.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeckModel.h"
/** Stores all the data of a user, such as cards, decks, coins, etc. NOT to be confused with PlayerModel, which is used during in-game. All data is stored as static variables */
@interface UserModel : NSObject

+(void)setupUser;
+(void)loadAllCards;
+(void)loadAllDecks;
+(BOOL)saveDeck:(DeckModel*)deck;
+(BOOL)deleteDeck:(DeckModel*)deck;
/** Returns success */
+(BOOL)publishCard:(CardModel*)card withImage:(UIImage*)image;
//+(void)saveCard:(CardModel*)card;
/** Refreshes the parse user by querying from database */
+(void)updateUser:(void (^)())onFinishBlock;
/** Returns true if userAllCards contains a card with same ID */
+(BOOL)ownsCardWithID:(int)idNumber;

/** The following functions are used to get the interaction values of a card. It includes cards that are liked, edited, and owned. All flags are stored in a single number using its bits. Returns NO if failed to save properly, so do not call the set functions on main thread. Liked card uses first bit. */
+(BOOL)setLikedCard:(CardModel*)card;
/** Uses second bit */
+(BOOL)setEditedCard:(CardModel*)card;
/** Uses third bit */
+(BOOL)setOwnedCard:(CardModel*)card;
+(BOOL)setNotOwnedCard:(CardModel*)card;

+(BOOL)getLikedCard:(CardModel*)card;
/** Uses second bit */
+(BOOL)getEditedCard:(CardModel*)card;
/** Uses third bit */
+(BOOL)getOwnedCard:(CardModel*)card;

+(BOOL)getLikedCardID:(int)idNumber;
+(BOOL)getOwnedCardID:(int)idNumber;

/** Note that this only removes from userAllCards and userAllDecks, rather than Parse objects */
+(void)removeOwnedCard:(int)idNumber;

+(NSArray*)getAllOwnedCardID;

@end

/** Array of CardModel's that the player has. */
NSMutableArray*userAllCards;
NSMutableArray*userAllCDCards;
NSMutableArray*userAllDecks;
NSManagedObjectContext*userCDContext;
DeckModel *userCurrentDeck;
int userDeckLimit;
int userGold;
PFUser *userPF;
BOOL userInfoLoaded;
BOOL userInitError;
NSString*userTutorialOneCardName;


/** The number of decks allowed per player at the very beginning of the game. Can gain more via quests etc. */
extern const int INITIAL_DECK_LIMIT;