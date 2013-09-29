//
//  WTExerciseViewController.h
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/15/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTExerciseViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSDate *currentlyEditingDate;

@end
