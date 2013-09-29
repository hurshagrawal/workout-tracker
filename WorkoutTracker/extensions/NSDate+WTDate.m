//
//  NSDate+WTDate.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/28/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "NSDate+WTDate.h"

@implementation NSDate (WTDate)

-(NSDate *)beginningOfDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
}

-(NSDate *)endOfDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];
}

@end
