//
//  CTRLBreakersViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/2/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLCollectionViewFetchedResultsController.h"

@class Panel;
@interface CTRLBreakerColumnViewController : UITableViewController

@property (nonatomic, strong) Panel *panel;
@property (nonatomic, strong) NSNumber *panelColumn;

- (void)addTapped:(UIBarButtonItem *)barButton;

@end
