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
        cell = [tableView dequeueReusableCellWithIdentifier:@"SetCell" forIndexPath:indexPath];
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
