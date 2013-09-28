//
//  UIView+WTView.m
//  WorkoutTracker
//
//  Created by Hursh Agrawal on 9/28/13.
//  Copyright (c) 2013 Hursh Agrawal. All rights reserved.
//

#import "UIView+WTView.h"

@implementation UIView (WTView)

- (UIView *)wt_superviewOfClass:(Class)class
{
    UIView *view = self.superview;
    
    while (view && ![view isKindOfClass:class])
    {
        view = view.superview;
    }
    
    return view;
}

@end
