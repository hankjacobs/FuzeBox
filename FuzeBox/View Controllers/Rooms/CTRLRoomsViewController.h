//
//  CTRLRoomsViewController.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/15/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTRLMenuDrawerViewController.h"

@class House;
@interface CTRLRoomsViewController : UITableViewController<CTRLFrontPanelRootViewController>

@property (nonatomic, strong) House *house;

- (void)rebuildDataSource;

@end
