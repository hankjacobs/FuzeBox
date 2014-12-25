//
//  CTRLRoomsViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/15/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLRoomsViewController.h"
#import "CTRLDataStack.h"
#import "CTRLRoomViewController.h"
#import "Room.h"

@interface CTRLRoomsViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation CTRLRoomsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self enableDefaultiCloudStoreChangeHandling];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Room"];
    self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"house = %@ AND name != %@ AND fixtures.@count != 0", self.house, @"Unassigned"];

    [self fetchRooms];
    
    if (!self.fetchedResultsController)
        [self showLoadingSpinner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self disableDefaultiCloudStoreChangeHandling];
}

#pragma mark - Table view data source

- (void)rebuildDataSource
{
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"house = %@", self.house];
    
    [self fetchRooms];
    [self.tableView reloadData];
}

- (void)fetchRooms
{
    if (!self.fetchedResultsController)
        return;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 0)
        return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLRoomViewController *roomViewController = (CTRLRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CTRLRoomViewController"];
    
    Room *room = [self.fetchedResultsController objectAtIndexPath:indexPath];
    roomViewController.room  = room;
    roomViewController.title = room.name;
    
    [self.navigationController pushViewController:roomViewController animated:YES];
}

#pragma mark - Cell Helpers

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Room *room = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = room.name;
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    NSManagedObjectContext *context = [CTRLDataStack sharedDataStack].mainContext;
    
    // If we have no MOC, persistence is currently offline.  No fetching.
    if (!context)
        return nil;
    
    // If our MOC changed, invalidate the fetchedResultsController so it gets recreated.
    if (context != _fetchedResultsController.managedObjectContext)
        _fetchedResultsController = nil;
    
    // If we have no fetchedResultsController, create one and perform a fetch to get the latest managed objects.
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        NSError *error;
        [_fetchedResultsController performFetch:&error];
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
