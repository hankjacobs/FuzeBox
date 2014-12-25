//
//  CTRLMenuDrawerViewController.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/26/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@class House;
@interface CTRLMenuDrawerViewController : UITableViewController

@property (nonatomic, strong) House *activeHouse;

- (void)expandHouse:(House *)house animated:(BOOL)animated;
- (void)collapseExpandedHouse:(BOOL)animated;

@end

@protocol CTRLFrontPanelRootViewController <NSObject>
@required

@property (nonatomic, strong) House *house;

- (void)rebuildDataSource;

@end

@interface SWRevealViewController (CTRLFrontPanelRootViewController)

- (UIViewController<CTRLFrontPanelRootViewController> *)activeFrontViewController;


@end