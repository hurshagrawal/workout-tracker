//
//  WTSetsTableViewCell.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/16/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "WTSetsTableViewCell.h"

@implementation WTSetsTableViewCell

- (void)prepareForReuse
{
    self.weightTextField.delegate = nil;
    self.repsTextField.delegate = nil;
}

@end
