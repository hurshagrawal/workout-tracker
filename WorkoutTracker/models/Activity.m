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

- (NSString *)setDescription
{
    NSMutableArray *exerciseText = [[NSMutableArray alloc] init];
    for (Set *set in self.sets) {
        NSString *setString = [NSString stringWithFormat:@"%@ x %@", set.repetitions, set.weight];
        [exerciseText addObject:setString];
    }
    
    return [exerciseText componentsJoinedByString:@", "];
}

@end
