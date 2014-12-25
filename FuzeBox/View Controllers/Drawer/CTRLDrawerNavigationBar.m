//
//  CTRLDrawerNavigationBar.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/26/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLDrawerNavigationBar.h"
#import "UIImage+UIImageFromColor.h"
#import "UIColor+UIColorFromRGB.h"

@implementation CTRLDrawerNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initNavBar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initNavBar];
    }
    return self;
}

- (void)initNavBar
{
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    self.translucent = NO;
    self.barTintColor = [UIColor colorWithR:131 g:131 b:131];
}

@end
