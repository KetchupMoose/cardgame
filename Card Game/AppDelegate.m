//
//  AppDelegate.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AppDelegate.h"
#import "AbilityWrapper.h"
#import "Campaign.h"
#import "SSKeychain.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString*SERVICE_NAME = @"com.contentgames.cardgame";
NSString*ACCOUNT_NAME = @"default_account";

const BOOL OFFLINE_DEBUGGING = NO;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"yekARh373R6T7z42RzFD8R1ywZVYELpOS1gCVD5C"
                  clientKey:@"Y46eRRr2QOFIu9kJGmmJldxV0xbPdtdbC6DJ7Q53"];
    
    [UIConstants loadResources];
    [AbilityWrapper loadAllAbilities];
    [CardView loadResources];
    [Campaign loadResources];
    
    userCDContext = [self managedObjectContext];
    
    if (OFFLINE_DEBUGGING)
        userInfoLoaded = YES;
    else
    {
        //TODO should be in main screen
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
        NSError*error;
        NSString *password = [SSKeychain passwordForService:SERVICE_NAME account:ACCOUNT_NAME error:&error];
        
        //new account
        if (error || password == nil)
        {
            NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            NSError*error;
            [SSKeychain setPassword:idfv forService:SERVICE_NAME account:ACCOUNT_NAME error:&error];
            
            if (error)
            {
                NSLog(@"%@", [error localizedDescription]);
                //TODO handle this
            }
            else
            {
                NSLog(@"creation success: %@", idfv);
                password = idfv;
            }
        }
        //already have account
        else{
            NSLog(@"already have account: %@", password);
        }
        
        NSString *username = [password substringToIndex:7];
        
        //TODO, username is that for now
        [PFUser logInWithUsernameInBackground:username password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                [UserModel setupUser];
                                            } else {
                                                if(error)
                                                {
                                                    NSLog(@"%d", [error code]);
                                                    //no username, register one
                                                    if ([error code] == 101) //101 is invalid login credentials
                                                    {
                                                        userPF = [PFUser user];
                                                        userPF.username = username;
                                                        userPF.password = password;
                                                        NSError*error;
                                                        [userPF signUp:&error];
                                                        
                                                        if (error)
                                                        {
                                                            NSLog(@"%@", [error localizedDescription]);
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"signup succecss");
                                                            [UserModel setupUser];
                                                        }
                                                    }
                                                    else{
                                                        NSLog(@"%@", [error localizedDescription]);
                                                    }
                                                }
                                                else
                                                {
                                                    NSLog(@"no error but no user. not suppose to happen");
                                                }
                                            }
                                        }];
    }
    //[PFUser enableAutomaticUser];
    
    /*
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        //NSLog(@"%d", succeeded);
        
        //load resources
        [UserModel setupUser]; //also loads user data such as gold
    }];*/
    
    
    /*
     CDCardModel *card = [NSEntityDescription
     insertNewObjectForEntityForName:@"Card"
     inManagedObjectContext:context];
     card.name = @"Card name";
     card.cardId = @1;
     card.cardType = @1;
     
     NSError *error;
     if (![context save:&error]) {
     NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
     }
     */
    
    
    
    
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CardGame" withExtension:@"momd"]; //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CardGame.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! this is actually easy to solve, just load all data from parse again
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
