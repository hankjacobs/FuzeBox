//
//  UIColor+UIColorFromRGB.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "UIColor+UIColorFromRGB.h"

@implementation UIColor (UIColorFromRGB)

+ (UIColor *) colorWithR:(int)r g:(int)g b:(int)b
{
    if (r > 255 || r < 0)
        r = 255;
    
    if (g > 255 || g < 0)
        g = 255;
    
    if (b > 255 || b < 0)
        b = 255;
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
