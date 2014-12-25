//
//  CTRLMainServicePanelViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Panel+Helpers.h"

@protocol CTRLEditServicePanelDelegate;
@interface CTRLEditPanelTypeViewController : UITableViewController

@property (nonatomic, weak) id<CTRLEditServicePanelDelegate> delegate;

@end

@protocol CTRLEditServicePanelDelegate <NSObject>

- (void)editServicePanelController:(CTRLEditPanelTypeViewController *)editServicePanelController didSelectPanelType:(PanelType)panelType;

@end