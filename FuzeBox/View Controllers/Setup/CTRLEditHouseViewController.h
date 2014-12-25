//
//  CTRLHouseInitialSetupViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@class House;
@interface CTRLEditHouseViewController : UITableViewController

@property (nonatomic, strong) void(^rightButtonTappedBlock)();
@property (strong, nonatomic) House *house;
@property (nonatomic, assign) BOOL allowPanelCreation;
@property (nonatomic, assign) BOOL showMyHouseAlreadyExists;

- (void)resetAndDismiss;

@end
