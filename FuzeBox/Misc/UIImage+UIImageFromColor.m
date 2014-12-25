//
//  UIImage+UIImageFromColor.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/26/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "UIImage+UIImageFromColor.h"

@implementation UIImage (UIImageFromColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
