//
//  UIImage+FixtureIcons.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/15/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "UIImage+FixtureIcons.h"
#import "Fixture+Helpers.h"

@implementation UIImage (FixtureIcons)

+ (UIImage *)imageForFixtureIconIndex:(NSInteger)iconIndex
{
    NSString *iconName = [self iconImageNameForIconIndex:iconIndex];

    if (iconName) {
        return [UIImage imageNamed:iconName];
    }
    else {
        return nil;
    }
}

+ (UIImage *)selectedImageForFixtureIconIndex:(NSInteger)iconIndex
{
    NSString *iconName = [self iconImageNameForIconIndex:iconIndex];
    iconName = [iconName stringByAppendingString:@"Selected"];
    
    if (iconName) {
        return [UIImage imageNamed:iconName];
    }
    else {
        return nil;
    }
}

+ (NSString *)iconImageNameForIconIndex:(NSInteger)iconIndex
{
    NSString *iconType = @"CTRLLaymenIcons";
    
    if (iconIndex & CTRLElectricalIconOffset) {
        iconType = @"CTRLElectricalIcons";
        iconIndex = iconIndex^CTRLElectricalIconOffset;
    }
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *iconFileNames = [infoDict objectForKey:iconType];
    
    if (iconIndex < iconFileNames.count) {
        return iconFileNames[iconIndex];
    }
    else {
        return nil;
    }
}

@end
