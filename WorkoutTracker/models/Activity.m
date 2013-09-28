//
//  Activity.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/14/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "Activity.h"
#import "Set.h"


@implementation Activity

@dynamic createdAt;
@dynamic exercise;
@dynamic sets;

- (NSArray *)setsSortedByDate
{
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    NSArray *sets = [self.sets sortedArrayUsingDescriptors:@[sortDescriptors]];
    
    return sets;
}

- (NSString *)descriptionForSets
{
    NSMutableArray *exerciseText = [[NSMutableArray alloc] init];
    for (Set *set in [self setsSortedByDate]) {
        NSString *setString = [NSString stringWithFormat:@"%@ x %@", set.repetitions, set.weight];
        [exerciseText addObject:setString];
    }
    
    return [exerciseText componentsJoinedByString:@", "];
}

@end
