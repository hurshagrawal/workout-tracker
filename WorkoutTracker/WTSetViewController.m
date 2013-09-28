//
//  WTSetViewController.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/15/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "WTSetViewController.h"
#import "WTSetsTableViewCell.h"
#import "Set.h"

@interface WTSetViewController ()

@end

@implementation WTSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.activity.sets count] == 0) {
        NSInteger section = [self.tableView numberOfSections] - 1;
        NSInteger row = [self.tableView numberOfRowsInSection:section] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        // Select the first cell in the last (the empty) row
        WTSetsTableViewCell *selectedCell = (WTSetsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [selectedCell.weightTextField becomeFirstResponder];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activity.sets count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTSetsTableViewCell *cell;
    
    NSArray *sets = [self.activity setsSortedByDate];
    
    if (indexPath.row >= [sets count]) {
        // Last, empty cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"SetCell" forIndexPath:indexPath];
        
        cell.weightTextField.text = nil;
        cell.repsTextField.text = nil;
    } else {
        // Fill each text field with the correct value
        cell = [tableView dequeueReusableCellWithIdentifier:@"SetCell" forIndexPath:indexPath];
        Set *set = sets[indexPath.row];
        
        cell.weightTextField.text = [set.weight stringValue];
        cell.repsTextField.text = [set.repetitions stringValue];
    }
    
    cell.weightTextField.delegate = self;
    cell.repsTextField.delegate = self;
    
    return cell;
}

#pragma mark - UI TextView Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    WTSetsTableViewCell* cell = (WTSetsTableViewCell *)[textField wt_superviewOfClass:[WTSetsTableViewCell class]];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    Set *set = nil;
    
    if (indexPath.row >= [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
        // If it's the last text field
        
        if (cell.weightTextField.text.length == 0 || cell.repsTextField.text.length == 0) {
            return;
        }
        
        set = [NSEntityDescription insertNewObjectForEntityForName:@"Set" inManagedObjectContext:self.managedObjectContext];
        set.createdAt = [NSDate date];
        set.activity = self.activity;
        
        [self.activity addSetsObject:set];
    } else {
        set = [self.activity setsSortedByDate][indexPath.row];
    }
    
    set.weight = [NSNumber numberWithInt:[cell.weightTextField.text intValue]];
    set.repetitions = [NSNumber numberWithInt:[cell.repsTextField.text intValue]];
    
    [self.tableView reloadData];
}

@end
