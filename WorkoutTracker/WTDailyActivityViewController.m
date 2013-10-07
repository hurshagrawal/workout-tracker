//
//  WTDailyActivityViewController.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/14/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "WTDailyActivityViewController.h"
#import "Exercise.h"
#import "Activity.h"
#import "Set.h"
#import "WTExerciseViewController.h"
#import "WTSetViewController.h"

@interface WTDailyActivityViewController ()

@end

@implementation WTDailyActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentlyEditingDate = [[NSDate date] beginningOfDay];
    [self reloadDataWithAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    // Setup the fetchedResultsController and pull activities
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];

    [fetchRequest setFetchBatchSize:20];

    // Get only activities from the proper date range
    NSDate *startDate = self.currentlyEditingDate;
    NSDate *endDate = [self.currentlyEditingDate endOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(performedAt >= %@) AND (performedAt <= %@)", startDate, endDate];
    [fetchRequest setPredicate:predicate];

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

#pragma mark - Day navigation

- (void)resetTitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d ''yy"];

    self.title = [dateFormatter stringFromDate:self.currentlyEditingDate];
}

- (void)reloadDataWithAnimation:(UITableViewRowAnimation)animation
{
    [self resetTitle];

    [self.tableView beginUpdates];
    
    self.fetchedResultsController = nil;

    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        exit(-1);
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
    
    [self.tableView endUpdates];
}

- (IBAction)selectPreviousDay:(UIButton *)sender {
    NSTimeInterval subtractDay = -24 * 60 * 60;
    self.currentlyEditingDate = [self.currentlyEditingDate dateByAddingTimeInterval:subtractDay];
    [self reloadDataWithAnimation:UITableViewRowAnimationRight];
}

- (IBAction)selectNextDay:(UIButton *)sender {
    NSTimeInterval addDay = 24 * 60 * 60;
    self.currentlyEditingDate = [self.currentlyEditingDate dateByAddingTimeInterval:addDay];
    [self reloadDataWithAnimation:UITableViewRowAnimationLeft];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = self.fetchedResultsController.sections[section];
    return ([sectionInfo numberOfObjects] + 1); // 1 extra for the "new exercise" button
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSLog(@"Rendering a cell at index path %@", indexPath);
    

    if (indexPath.row == [self.fetchedResultsController.fetchedObjects count]) {
        // If this is the last cell - i.e. "New exercise button"
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewExerciseCell" forIndexPath:indexPath];
    } else {
        // If this is an existing activity
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];

        Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];

        cell.textLabel.text = activity.exercise.name;
        cell.detailTextLabel.text = [activity descriptionForSets];
    }
    
    return cell;
}

#pragma mark - Navigation

// If the user chose "new exercise," take him to the exerciseViewController
// Otherwise, take him to his sets/reps (setViewController)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ActivityToExercise"]) {
        WTExerciseViewController *controller = [segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.currentlyEditingDate = self.currentlyEditingDate;
    } else if ([segue.identifier isEqualToString:@"ActivityToSet"]) {
        WTSetViewController *controller = [segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;

        // Pull the activity corresponding to the cell and set it in the target controller
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.activity = activity;
    }
}

#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
