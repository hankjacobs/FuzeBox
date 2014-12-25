//
//  CTRLFetchedResultsCollectionViewDelegateManager.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>

//This should be a subclass of UICollectionViewController
@interface CTRLFetchedResultsCollectionViewDelegateManager : NSObject<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UICollectionView *collectionView;

@end
