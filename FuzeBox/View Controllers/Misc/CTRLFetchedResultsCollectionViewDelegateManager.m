//
//  CTRLFetchedResultsCollectionViewDelegateManager.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLFetchedResultsCollectionViewDelegateManager.h"

@interface CTRLFetchedResultsCollectionViewDelegateManager ()

@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *objectChanges;

@end

@implementation CTRLFetchedResultsCollectionViewDelegateManager

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    self.sectionChanges = [NSMutableArray array];
    self.objectChanges = [NSMutableArray array];
    
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
}

#pragma mark - Fetched Results Delegate
//Shamelessly stolen from http://ashfurrow.com/blog/uicollectionview-example

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.collectionView) return;
    
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @[@(sectionIndex)];
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @[@(sectionIndex)];
            break;
    }
    
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.collectionView) return;
    
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.collectionView) return;
    
    if ([self.sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                    if ([obj isKindOfClass:[NSArray class]]) {
                        for (NSNumber *index in obj) {
                            [indexSet addIndex:index.integerValue];
                        }
                    }
                    else if ([obj isKindOfClass:[NSNumber class]]){
                        [indexSet addIndex:[(NSNumber *)obj integerValue]];
                    }
                    
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:indexSet];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:indexSet];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:indexSet];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

@end
