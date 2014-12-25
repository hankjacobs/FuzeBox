//
//  UIImage+FixtureIcons.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/15/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FixtureIcons)

+ (UIImage *)imageForFixtureIconIndex:(NSInteger)iconIndex;
+ (UIImage *)selectedImageForFixtureIconIndex:(NSInteger)iconIndex;

@end
