//
//  CTRLCollectionViewFetchedResultsController.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/23/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLCollectionViewFetchedResultsController : UICollectionViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
