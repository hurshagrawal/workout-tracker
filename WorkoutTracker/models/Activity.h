//
//  Activity.h
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/14/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Exercise.h"

@class Set;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) Exercise *exercise;
@property (nonatomic, retain) NSSet *sets;
@end

@interface Activity (CoreDataGeneratedAccessors)

- (void)addSetsObject:(Set *)value;
- (void)removeSetsObject:(Set *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;
- (NSString *)setDescription;

@end
