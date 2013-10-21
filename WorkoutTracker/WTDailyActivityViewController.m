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
#import "WTSetViewController.h"

@interface WTDailyActivityViewController ()

@end

@implementation WTDailyActivityViewController

CGFloat exerciseHeaderHeight = 40.0;
CGFloat activityRowHeight = 90.0;
CGFloat exerciseRowHeight = 50.0;
UITextField *activeField;
UIEdgeInsets defaultInset;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerForKeyboardNotifications];

    self.currentlyEditingDate = [[NSDate date] beginningOfDay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadActivityDataWithAnimation:UITableViewRowAnimationNone];
    [self reloadExerciseDataWithAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Day navigation
- (void)resetTitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d ''yy"];

    self.title = [dateFormatter stringFromDate:self.currentlyEditingDate];
}

- (void)reloadActivityDataWithAnimation:(UITableViewRowAnimation)animation
{
    [self resetTitle];

    // Hide keyboard if shown
    [self.tableView wt_findAndResignFirstResponder];

    [self.tableView beginUpdates];

    // Get only activities from the proper date range
    NSDate *startDate = self.currentlyEditingDate;
    NSDate *endDate = [self.currentlyEditingDate endOfDay];
    NSPredicate *dateFilter = [NSPredicate predicateWithFormat:@"(performedAt >= %@) AND (performedAt <= %@)", startDate, endDate];

    self.displayedActivities = [Activity findAllSortedBy:@"createdAt" ascending:YES withPredicate:dateFilter];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:WTActivitySection] withRowAnimation:animation];

    [self.tableView endUpdates];
}

- (IBAction)selectPreviousDay:(UIButton *)sender {
    NSDateComponents *previousDayComponents = [[NSDateComponents alloc] init];
    [previousDayComponents setDay:-1];

    self.currentlyEditingDate = [[NSCalendar currentCalendar] dateByAddingComponents:previousDayComponents toDate:self.currentlyEditingDate options:0];

    [self reloadActivityDataWithAnimation:UITableViewRowAnimationRight];
}

- (IBAction)selectNextDay:(UIButton *)sender {
    NSDateComponents *nextDayComponents = [[NSDateComponents alloc] init];
    [nextDayComponents setDay:1];

    self.currentlyEditingDate = [[NSCalendar currentCalendar] dateByAddingComponents:nextDayComponents toDate:self.currentlyEditingDate options:0];

    [self reloadActivityDataWithAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - Exercise list view
- (void)reloadExerciseDataWithAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView beginUpdates];

    // Get only activities from the proper date range
    self.displayedExercises = [Exercise findAllSortedBy:@"createdAt" ascending:YES];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:WTExerciseSection] withRowAnimation:animation];

    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == WTActivitySection) {
        return [self.displayedActivities count];
    } else {
        return [self.displayedExercises count] + 1; // 1 extra for the "new exercise" button
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == WTExerciseSection) {
        return @"New exercise";
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.displayedActivities count] > 0 && section == WTExerciseSection) {
        return exerciseHeaderHeight;
    } else {
        return 0.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WTActivitySection) {
        return activityRowHeight;
    } else {
        return exerciseRowHeight;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.section == WTActivitySection) {
        // If this is an existing activity
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];

        Activity *activity = self.displayedActivities[indexPath.row];

        cell.textLabel.text = activity.exercise.name;
        cell.detailTextLabel.text = [activity descriptionForSets];
    } else if (indexPath.section == WTExerciseSection) {
        if (indexPath.row == [self.displayedExercises count]) {
            // If this is the "new exercise" button
            cell = [tableView dequeueReusableCellWithIdentifier:@"NewExerciseCell" forIndexPath:indexPath];
        } else {
            // If this is an existing exercise
            cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseCell" forIndexPath:indexPath];

            Exercise *exercise = self.displayedExercises[indexPath.row];

            cell.textLabel.text = exercise.name;
        }
    }

    return cell;
}

#pragma mark - Editing and deleting rows
// Override support for conditional editing of rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WTExerciseSection && indexPath.row == [self.displayedExercises count]) {
        // If new exercise field, don't allow deletion
        return NO;
    } else {
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == WTActivitySection) {
            Activity *deletedActivity = self.displayedActivities[indexPath.row];

            NSMutableArray *activities = [self.displayedActivities mutableCopy];
            [activities removeObjectAtIndex:indexPath.row];
            self.displayedActivities = activities;

            [deletedActivity deleteEntity];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            [UIAlertView showAlertViewWithTitle:@"Delete this exercise?"
                                        message:@"Deleting this will delete all sets and reps of this exercise, as well."
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@[ @"Do it!" ]
                                        handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                            Exercise *deletedExercise = self.displayedExercises[indexPath.row];

                                            NSMutableArray *exercises = [self.displayedExercises mutableCopy];
                                            [exercises removeObjectAtIndex:indexPath.row];
                                            self.displayedExercises = exercises;

                                            [deletedExercise deleteEntity];
                                            
                                            [self.tableView reloadData];
                                            [self reloadActivityDataWithAnimation:UITableViewRowAnimationNone];
                                        }];
        }
    }
}

#pragma mark - UITextFieldDelegate (new exercise text field)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // Hide the keyboard

    [self performSegueWithIdentifier:@"ExerciseToSet" sender:textField];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToActiveField:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(resetScrollPosition)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];

}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)scrollToActiveField:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    defaultInset = self.tableView.contentInset;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;

    // From http://stackoverflow.com/a/4837510/938799
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = activeField.frame.origin;
    origin.y -= self.tableView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y - (aRect.size.height));
        [self.tableView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)resetScrollPosition
{
    self.tableView.contentInset = defaultInset;
    self.tableView.scrollIndicatorInsets = defaultInset;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WTSetViewController *controller = [segue destinationViewController];
    controller.managedObjectContext = [NSManagedObjectContext defaultContext];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    if ([segue.identifier isEqualToString:@"ExerciseToSet"]) {
        // If creating a new activity
        Exercise *exercise;

        if ([sender isKindOfClass:[UITextField class]]) {
            // If creating a new exercise
            UITextField *textField = sender;

            exercise = [Exercise createEntity];
            exercise.createdAt = [NSDate date];
            exercise.name = textField.text;

            textField.text = nil;
        } else {
            exercise = self.displayedExercises[indexPath.row];
        }

        Activity *activity = [Activity createEntity];
        activity.createdAt = [NSDate date];
        activity.performedAt = self.currentlyEditingDate;
        activity.exercise = exercise;
        [exercise addActivitiesObject:activity];

        controller.activity = activity;

    } else if ([segue.identifier isEqualToString:@"ActivityToSet"]) {
        // If viewing an existing activity
        controller.activity = self.displayedActivities[indexPath.row];
    }
}

@end
