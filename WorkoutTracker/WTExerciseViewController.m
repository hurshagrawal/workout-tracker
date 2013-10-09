//
//  WTExerciseViewController.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/15/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "WTExerciseViewController.h"
#import "Exercise.h"
#import "Activity.h"
#import "Set.h"
#import "WTSetViewController.h"

@interface WTExerciseViewController ()

@end

@implementation WTExerciseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        exit(-1);
    }
    
    self.title = @"Choose an exercise";
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Exercise" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
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
    
   if (indexPath.row == [self.fetchedResultsController.fetchedObjects count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddExerciseCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseCell" forIndexPath:indexPath];
        
        Exercise *exercise = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = exercise.name;
    }
    
    return cell;
}

// Override support for conditional editing of rows.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.fetchedResultsController.fetchedObjects count]) {
        return NO;
    } else {
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [UIAlertView showAlertViewWithTitle:@"Delete this exercise?"
                                    message:@"Deleting this will delete all sets and reps of this exercise, as well."
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@[ @"Do it!" ]
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                        Exercise *exercise = [self.fetchedResultsController objectAtIndexPath:indexPath];
                                        [self.managedObjectContext deleteObject:exercise];
                                    }];
    }
}


#pragma mark - UITextFieldDelegate (new exercise text field)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // Hide the keyboard
    
    [self performSegueWithIdentifier:@"ExerciseToSet" sender:textField];
    
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WTSetViewController *controller = [segue destinationViewController];
    controller.managedObjectContext = self.managedObjectContext;
    
    Exercise *exercise;
    
    if ([sender isKindOfClass:[UITextField class]]) {
        // If segue is initialized from closing the new exercise text window - create a new exercise
        UITextField *textField = sender;
        NSString *exerciseName = textField.text;
        textField.text = nil;
        
        exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:self.managedObjectContext];
        exercise.name = exerciseName;
        exercise.createdAt = [NSDate date];
        
    } else {
        // Segue is initialized from clicking on an exiting exercise - get the exercise
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        exercise = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    // Create a new activity from the exercise and set it in the new controller
    Activity *activity = [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:self.managedObjectContext];
    activity.createdAt = [NSDate date];
    activity.performedAt = self.currentlyEditingDate;
    activity.exercise = exercise;
    [exercise addActivitiesObject:activity];
    
    controller.activity = activity;
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
