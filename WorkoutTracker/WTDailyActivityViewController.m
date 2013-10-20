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

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadDataWithAnimation:UITableViewRowAnimationNone];
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

    // Get only activities from the proper date range
    NSDate *startDate = self.currentlyEditingDate;
    NSDate *endDate = [self.currentlyEditingDate endOfDay];
    NSPredicate *dateFilter = [NSPredicate predicateWithFormat:@"(performedAt >= %@) AND (performedAt <= %@)", startDate, endDate];

    self.displayedActivities = [Activity findAllSortedBy:@"createdAt" ascending:YES withPredicate:dateFilter];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];

    [self.tableView endUpdates];
}

- (IBAction)selectPreviousDay:(UIButton *)sender {
    NSDateComponents *previousDayComponents = [[NSDateComponents alloc] init];
    [previousDayComponents setDay:-1];

    self.currentlyEditingDate = [[NSCalendar currentCalendar] dateByAddingComponents:previousDayComponents toDate:self.currentlyEditingDate options:0];

    [self reloadDataWithAnimation:UITableViewRowAnimationRight];
}

- (IBAction)selectNextDay:(UIButton *)sender {
    NSDateComponents *nextDayComponents = [[NSDateComponents alloc] init];
    [nextDayComponents setDay:1];

    self.currentlyEditingDate = [[NSCalendar currentCalendar] dateByAddingComponents:nextDayComponents toDate:self.currentlyEditingDate options:0];

    [self reloadDataWithAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayedActivities count] + 1; // 1 extra for the "new exercise" button
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.row == [self.displayedActivities count]) {
        // If this is the last cell - i.e. "New exercise button"
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewExerciseCell" forIndexPath:indexPath];
    } else {
        // If this is an existing activity
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];

        Activity *activity = self.displayedActivities[indexPath.row];

        cell.textLabel.text = activity.exercise.name;
        cell.detailTextLabel.text = [activity descriptionForSets];
    }

    return cell;
}

#pragma mark - Editing and deleting rows
// Override support for conditional editing of rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.displayedActivities count]) {
        return NO;
    } else {
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"TODO: Delete the item!!");
        //[self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - Navigation

// If the user chose "new exercise," take him to the exerciseViewController
// Otherwise, take him to his sets/reps (setViewController)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ActivityToExercise"]) {
        WTExerciseViewController *controller = [segue destinationViewController];
        controller.managedObjectContext = [NSManagedObjectContext defaultContext];
        controller.currentlyEditingDate = self.currentlyEditingDate;
    } else if ([segue.identifier isEqualToString:@"ActivityToSet"]) {
        WTSetViewController *controller = [segue destinationViewController];
        controller.managedObjectContext = [NSManagedObjectContext defaultContext];

        // Pull the activity corresponding to the cell and set it in the target controller
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Activity *activity = self.displayedActivities[indexPath.row];
        controller.activity = activity;
    }
}

@end
