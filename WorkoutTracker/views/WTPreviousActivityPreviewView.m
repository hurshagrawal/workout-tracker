//
//  WTPreviousActivityPreviewView.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 10/19/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "WTPreviousActivityPreviewView.h"

@implementation WTPreviousActivityPreviewView

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect titleRect = CGRectMake(0, 0, self.bounds.size.width, 20);
    UILabel *title = [[UILabel alloc] initWithFrame:titleRect];
    title.text = @"Last performed:";
    [self addSubview:title];

    UILabel *exerciseDateLabel = [[UILabel alloc] initWithFrame:titleRect];
    exerciseDateLabel.text = self.exerciseDate;
    exerciseDateLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:exerciseDateLabel];

    CGRect setsRect = CGRectMake(0, 20, self.bounds.size.width, 50);
    UITextView *setsDescriptionLabel = [[UITextView alloc] initWithFrame:setsRect];
    setsDescriptionLabel.text = self.setsDescription;
    [setsDescriptionLabel setFont:[UIFont systemFontOfSize:17]];
    setsDescriptionLabel.userInteractionEnabled = NO;
    [self addSubview:setsDescriptionLabel];
}

@end
