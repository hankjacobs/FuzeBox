//
//  CTRLFixturesViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/17/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTRLMenuDrawerViewController.h"

@class House;
@interface CTRLFixturesViewController : UITableViewController<CTRLFrontPanelRootViewController>

@property (nonatomic, strong) House *house;

- (void)rebuildDataSource;

@end
