//
//  CTRLEditFixtureViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/17/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Fixture;
@class House;
@interface CTRLEditFixtureViewController : UITableViewController

@property (nonatomic, strong) Fixture *fixture;
@property (nonatomic, strong) House *house;
@property (nonatomic, assign) BOOL allowsBreakerChange;
@property (nonatomic, assign) BOOL useElectricalIcons;

@end
