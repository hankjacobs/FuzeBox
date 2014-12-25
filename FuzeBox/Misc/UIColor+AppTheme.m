//
//  UIColor+AppTheme.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/28/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "UIColor+AppTheme.h"
#import "UIColor+UIColorFromRGB.h"

@implementation UIColor (AppTheme)

+ (UIColor *)defaultNavigationBarColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultEditingNavigationBarColor
{
    return [UIColor colorWithR:131 g:131 b:131];
}

+ (UIColor *)defaultCollectionViewBackgroundColor
{
    return [UIColor colorWithR:222 g:222 b:222];
}

+ (UIColor *)defaultEditingCollectionViewColor
{
    return [UIColor colorWithR:190 g:190 b:190];
}

@end
