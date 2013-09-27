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
    NSInteger section = [self.tableView numberOfSections] - 1;
    NSInteger row = [self.tableView numberOfRowsInSection:section] - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    // Scroll to the bottom of the view
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    // Select the first cell in the last (the empty) row
    WTSetsTableViewCell *selectedCell = (WTSetsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [selectedCell.weightTextField becomeFirstResponder];
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
    
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    NSArray *sets = [self.activity.sets sortedArrayUsingDescriptors:@[sortDescriptors]];
    
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
    
    return cell;
}


@end
