//
//  CTRLRoomViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/22/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLRoomViewController.h"
#import "CTRLDataStack.h"
#import "Room.h"
#import "Fixture.h"
#import "Breaker.h"
#import "UIImage+FixtureIcons.h"

@interface CTRLRoomViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;

@end

@implementation CTRLRoomViewController

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
    
    self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fixture"];
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"room = %@", self.room];
    self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    

    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
#pragma mark - Cell Helpers

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Fixture *fixture = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = fixture.name;
    cell.detailTextLabel.text = fixture.breaker.name;
    
    UIImage *fixtureImage = nil;
    
    if (fixture.breaker.on.boolValue) {
        fixtureImage = [UIImage selectedImageForFixtureIconIndex:fixture.iconIndex.integerValue];
    }
    else {
        fixtureImage = [UIImage imageForFixtureIconIndex:fixture.iconIndex.integerValue];
    }
    
    fixtureImage = [fixtureImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.image = fixtureImage;
    cell.imageView.tintColor = ((fixture.breaker.color && fixture.breaker.on.boolValue) ? fixture.breaker.color : [UIColor blackColor]);
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
