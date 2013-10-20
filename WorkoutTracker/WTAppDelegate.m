//
//  WTAppDelegate.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/14/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "WTAppDelegate.h"
#import "WTDailyActivityViewController.h"
#import "Exercise.h"
#import "Activity.h"
#import "Set.h"

@implementation WTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup core data
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"WorkoutTracker.sqlite"];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

@end
