//
//  CTRLFixturesViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/17/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLFixturesViewController.h"
#import "CTRLEditFixtureViewController.h"
#import "CTRLDataStack.h"
#import "Fixture.h"
#import "UIImage+FixtureIcons.h"
#import "Breaker.h"
#import "Room.h"
#import "Room+Helpers.h"
#import "House.h"
#import "Panel.h"

@interface CTRLFixturesViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem; //Strong due to changing to add button
                                                                          //will dealloc this otherwise

@end

@implementation CTRLFixturesViewController

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
    
    [self.revealButtonItem setTarget:self.revealViewController];
    [self.revealButtonItem setAction:@selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fixture"];
    self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"breaker.name" ascending:YES],
                                          [NSSortDescriptor sortDescriptorWithKey:@"breaker.panel.name" ascending:YES]];
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"room.house = %@", self.house];
    
    [self fetchFixtures];

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

#pragma mark - UIViewController

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped:)];
        [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
    }
    else {
        [self.navigationItem setLeftBarButtonItem:self.revealButtonItem animated:YES];
    }
}

#pragma mark - UINavigation Button Actions

- (void)addTapped:(UIBarButtonItem *)barButton
{
    NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
    Fixture *fixture = [NSEntityDescription insertNewObjectForEntityForName:@"Fixture"
                                                     inManagedObjectContext:moc];
    fixture.name = @"Fixture";
    fixture.room = [Room unassignedRoomForHouse:(House *)[moc objectWithID:self.house.objectID]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLEditFixtureViewController *fixtureEditorViewController = (CTRLEditFixtureViewController *)[storyboard instantiateViewControllerWithIdentifier:@"fixtureEditor"];
    fixtureEditorViewController.fixture = fixture;
    fixtureEditorViewController.title = @"New Fixture";
    fixtureEditorViewController.allowsBreakerChange = YES;
    fixtureEditorViewController.house = (House *)[moc objectWithID:self.house.objectID];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fixtureEditorViewController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (void)rebuildDataSource
{
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"house = %@", self.house];
    
    [self fetchFixtures];
    [self.tableView reloadData];
}

- (void)fetchFixtures
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
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 0) {

        return [[self.fetchedResultsController.sections objectAtIndex:section] name];
    }
    else {
        return nil;
    }
}

#pragma mark - Cell Helpers

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Fixture *fixture = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = fixture.name;
    cell.detailTextLabel.text = fixture.room.name;
    
    UIImage *fixtureImage = nil;
    
    if (fixture.breaker.on.boolValue) {
        fixtureImage = [UIImage selectedImageForFixtureIconIndex:fixture.iconIndex.integerValue];
    }
    else {
        fixtureImage = [UIImage imageForFixtureIconIndex:fixture.iconIndex.integerValue];
    }
    
    fixtureImage = [fixtureImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.image = fixtureImage;
    cell.imageView.tintColor = (fixture.breaker.on.boolValue && fixture.breaker.color ? fixture.breaker.color : [UIColor blackColor]);
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
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:context sectionNameKeyPath:@"sectionDisplayName" cacheName:nil];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        Fixture *selectedFixture = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
        Fixture *fixture = (Fixture *)[moc objectWithID:selectedFixture.objectID];
        House *currentHouse = (House *)[moc objectWithID:self.house.objectID];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CTRLEditFixtureViewController *fixtureEditorViewController = (CTRLEditFixtureViewController *)[storyboard instantiateViewControllerWithIdentifier:@"fixtureEditor"];
        fixtureEditorViewController.fixture = fixture;
        fixtureEditorViewController.title = @"Edit Fixture";
        fixtureEditorViewController.allowsBreakerChange = YES;
        fixtureEditorViewController.house = currentHouse;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fixtureEditorViewController];
        
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Fixture *fixture = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [fixture.managedObjectContext performBlockAndWait:^{
            [fixture.managedObjectContext deleteObject:fixture];
        }];
        
        //Workaround for the weird dangling delete button when deleting last row
        NSInteger sectionsAmount = [self.tableView numberOfSections];
        NSInteger rowsAmount = [self.tableView numberOfRowsInSection:sectionsAmount-1];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:(rowsAmount - 1) inSection:(sectionsAmount - 1)];
        
        if (lastIndexPath.section == indexPath.section && lastIndexPath.row <= indexPath.row)
           [self.tableView reloadData];
    }
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
