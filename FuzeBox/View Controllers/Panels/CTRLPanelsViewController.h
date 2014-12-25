//
//  CTRLPanelsViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLCollectionViewFetchedResultsController.h"
#import "CTRLMenuDrawerViewController.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@class House;
@interface CTRLPanelsViewController : CTRLCollectionViewFetchedResultsController<CTRLFrontPanelRootViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

@property (nonatomic, strong) House *house;

- (void)addTapped:(UIBarButtonItem *)sender;
- (void)rebuildDataSource;

@end
