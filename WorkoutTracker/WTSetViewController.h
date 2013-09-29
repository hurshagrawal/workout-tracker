//
//  WTSetViewController.h
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/15/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

@interface WTSetViewController : UITableViewController <UITextFieldDelegate>

typedef NS_ENUM(NSInteger, WTSetTextViewTag) {
    WTWeightTextViewTag = 1,
    WTRepsTextViewTag = 2
};

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) Activity* activity;

@end
