//
//  WTDailyActivityViewController.h
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/14/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTDailyActivityViewController : UITableViewController <NSFetchedResultsControllerDelegate>

typedef NS_ENUM(NSInteger, WTDailyActivityViewSection) {
    WTActivitySection = 0,
    WTExerciseSection = 1
};

@property (nonatomic, strong) NSDate *currentlyEditingDate;
@property (nonatomic, strong) NSArray *displayedActivities;
@property (nonatomic, strong) NSArray *displayedExercises;

@end
