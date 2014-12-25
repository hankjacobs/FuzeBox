//
//  CTRLMenuDrawerViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/26/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLMenuDrawerViewController.h"
#import "CTRLMenuTableViewCell.h"
#import "UIColor+UIColorFromRGB.h"
#import "CTRLPanelsViewController.h"
#import "CTRLFixturesViewController.h"
#import "CTRLRoomsViewController.h"
#import "CTRLEditHouseViewController.h"
#import "CTRLSettingsViewController.h"
#import "CTRLDataStack.h"
#import "House.h"

typedef NS_ENUM(NSInteger, CTRLMenuCellType)
{
    CTRLMenuCellHouse,
    CTRLMenuCellPanels,
    CTRLMenuCellFixtures,
    CTRLMenuCellRooms,
    CTRLMenuCellOther
};

typedef NS_ENUM(NSInteger, CTRLMenuTransitionCompletionActionType)
{
    CTRLMenuTransitionCompletionNone,
    CTRLMenuTransitionCompletionAddBreaker,
    CTRLMenuTransitionCompletionAddPanel
};

@interface CTRLMenuDrawerViewController ()<NSFetchedResultsControllerDelegate, SWRevealViewControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) House *expandedHouse;
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;
@property (nonatomic, strong) NSIndexPath *panelsIndexPath;
@property (nonatomic, strong) NSIndexPath *fixturesIndexPath;
@property (nonatomic, strong) NSIndexPath *roomsIndexPath;
@property (nonatomic, assign) CTRLMenuTransitionCompletionActionType menuTransitionCompletionActionType;

@end

@implementation CTRLMenuDrawerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"House"];
        self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.revealViewController.delegate = self;
    
    [self enableDefaultiCloudStoreChangeHandling];
    
    [self.tableView registerClass:[CTRLMenuTableViewCell class] forCellReuseIdentifier:@"MenuCell"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithR:110 g:110 b:110];
    self.tableView.backgroundColor = [UIColor colorWithR:110 g:110 b:110];
    self.revealViewController.rearViewStatusBarBackgroundColor = self.navigationController.navigationBar.barTintColor;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"drawerLogo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    logo.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = logo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self collapseExpandedHouse:animated];
    }
    else {
        [self.tableView reloadData];
        
        if (self.expandedHouse)
            [self expandHouse:self.expandedHouse animated:animated];
        
        [self selectActiveFrontViewControllerCell:animated];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self expandHouse:self.activeHouse animated:NO];
    [self selectActiveFrontViewControllerCell:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { //Prevents weird animation in
                                                              //compatibility mode on ipad
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)dealloc
{
    [self disableDefaultiCloudStoreChangeHandling];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.1;
    else if (section == 1)
        return 52.0;
    else
        return 9.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTRLMenuCellType cellType = [self menuCellTypeAtIndexPath:indexPath];
    if (cellType == CTRLMenuCellHouse){
        
        House *house = [self houseAtIndexPath:indexPath];
        if (house == self.activeHouse && house == self.expandedHouse) {
            return NO;
        }
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self handleHouseRowSelection:indexPath];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            self.menuTransitionCompletionActionType = CTRLMenuTransitionCompletionAddPanel;
            if (![self showPanelsControllerForActiveHouse]) {
                self.menuTransitionCompletionActionType = CTRLMenuTransitionCompletionNone;
            }
            
            [self selectActiveFrontViewControllerCell:YES];
        }
        else if (indexPath.row == 1) {
            
            NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
            House *house = [NSEntityDescription insertNewObjectForEntityForName:@"House"
                                                              inManagedObjectContext:moc];
            [self presentEditHouseControllerForHouse:house expandHouseOnCompletion:YES];
        }
    }
    else if (indexPath.section == 2) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *settingsNavVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"settingsNavigationViewController"];
        [self.revealViewController setFrontViewController:settingsNavVC animated:YES];
        self.activeHouse = nil;
    }
}

- (void)handleHouseRowSelection:(NSIndexPath *)indexPath
{
    CTRLMenuCellType cellType = [self menuCellTypeAtIndexPath:indexPath];
    
    if (cellType == CTRLMenuCellHouse){
        House *house = [self houseAtIndexPath:indexPath];
        
        if (house == self.activeHouse && house == self.expandedHouse) {
            [self selectActiveFrontViewControllerCell:YES];
            return;
        }
        
        self.expanded = YES;
        [self expandHouse:house animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (cellType == CTRLMenuCellPanels) {
        self.activeHouse = self.expandedHouse;
        [self showPanelsControllerForActiveHouse];
    }
    else if (cellType == CTRLMenuCellFixtures) {
        self.activeHouse = self.expandedHouse;
        [self showFixturesControllerForActiveHouse];
    }
    else if (cellType == CTRLMenuCellRooms) {
        self.activeHouse = self.expandedHouse;
        [self showRoomsControllerForActiveHouse];
    }
    else {
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Expand/Collapse Helpers

- (void)expandHouse:(House *)house animated:(BOOL)animated
{
    if (!house || ![self.fetchedResultsController indexPathForObject:house])
        return;
    
    if (!animated) {
        self.expandedHouse = house;
        self.expanded = YES;
        [self.tableView reloadData];
        NSIndexPath *actualIndexPath = [self.fetchedResultsController indexPathForObject:house];
        self.panelsIndexPath = [NSIndexPath indexPathForRow:actualIndexPath.row+1
                                                          inSection:actualIndexPath.section];
        self.fixturesIndexPath = [NSIndexPath indexPathForRow:actualIndexPath.row+2
                                                            inSection:actualIndexPath.section];
        self.roomsIndexPath = [NSIndexPath indexPathForRow:actualIndexPath.row+3
                                                         inSection:actualIndexPath.section];
        
        if (self.expandedHouse == self.activeHouse) {
            [self selectActiveFrontViewControllerCell:animated];
        }
        else {
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
        }
    }
    else if ((house != self.expandedHouse) || (!self.expanded && self.expandedHouse)) {
        self.expandedHouse = house;
        self.expanded = YES;
        
        NSIndexPath *actualIndexPath = [self.fetchedResultsController indexPathForObject:house];
        NSIndexPath *panelsIndexPath = [NSIndexPath indexPathForRow:actualIndexPath.row+1
                                                          inSection:actualIndexPath.section];
        NSIndexPath *fixturesIndexPath = [NSIndexPath indexPathForRow:actualIndexPath.row+2
                                                            inSection:actualIndexPath.section];
        NSIndexPath *roomsIndexPath = [NSIndexPath indexPathForRow:actualIndexPath.row+3
                                                         inSection:actualIndexPath.section];
        UITableViewRowAnimation animation = UITableViewRowAnimationMiddle;
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[panelsIndexPath, fixturesIndexPath, roomsIndexPath]
                              withRowAnimation:animation];
        if (self.panelsIndexPath && self.fixturesIndexPath && self.roomsIndexPath) {
            
            [self.tableView deleteRowsAtIndexPaths:@[self.panelsIndexPath,
                                                     self.fixturesIndexPath,
                                                     self.roomsIndexPath]
                                  withRowAnimation:animation];
        }
        [self.tableView endUpdates];
        
        self.panelsIndexPath = panelsIndexPath;
        self.fixturesIndexPath = fixturesIndexPath;
        self.roomsIndexPath = roomsIndexPath;
        
        if (self.expandedHouse == self.activeHouse) {
            [self selectActiveFrontViewControllerCell:animated];
        }
        else {
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
        }
    }
}

- (void)collapseExpandedHouse:(BOOL)animated;
{
    
    if (self.expandedHouse && self.isExpanded && self.panelsIndexPath && self.fixturesIndexPath && self.roomsIndexPath) {
        self.expanded = NO;
        
        if (animated) {
            UITableViewRowAnimation animation = UITableViewRowAnimationFade;
            [self.tableView deleteRowsAtIndexPaths:@[self.panelsIndexPath,
                                                     self.fixturesIndexPath,
                                                     self.roomsIndexPath]
                                  withRowAnimation:animation];
        }
        else {
            [self.tableView reloadData];
        }
        self.panelsIndexPath = nil;
        self.fixturesIndexPath = nil;
        self.roomsIndexPath = nil;
    }
}

- (void)selectActiveFrontViewControllerCell:(BOOL)animated
{
    UINavigationController *currentNavController = (UINavigationController *)self.revealViewController.frontViewController;
    UIViewController *activeVC = currentNavController.viewControllers.firstObject;
    
    if ([activeVC isKindOfClass:[CTRLSettingsViewController class]]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] animated:animated scrollPosition:UITableViewScrollPositionNone];
        return;
    }
    
    if (!self.panelsIndexPath || !self.fixturesIndexPath || !self.roomsIndexPath)
        return;
    
    if ([activeVC isKindOfClass:[CTRLPanelsViewController class]]) {
        [self.tableView selectRowAtIndexPath:self.panelsIndexPath
                                    animated:animated
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
    else if ([activeVC isKindOfClass:[CTRLFixturesViewController class]]) {
        [self.tableView selectRowAtIndexPath:self.fixturesIndexPath
                                    animated:animated
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
    else if ([activeVC isKindOfClass:[CTRLRoomsViewController class]]) {
        [self.tableView selectRowAtIndexPath:self.roomsIndexPath
                                    animated:animated
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}
#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *colorView = [[UIView alloc] init];
    colorView.backgroundColor = [UIColor colorWithR:110 g:110 b:110];
    
    return colorView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.fetchedResultsController)
        return 0;
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.fetchedResultsController)
        return 0;
    
    if (section == 0) {
        if (self.fetchedResultsController.sections.count > 0) {
            
            NSInteger numOfRows = [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
            if (self.expandedHouse && self.isExpanded) {
                numOfRows += 3;
            }
            
            return numOfRows;
        }
        else
            return 0;
    }
    else if (section == 1) {
        return 2;
    }
    else if (section == 2) {
        return 1;
    }
    else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    CTRLMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(CTRLMenuTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        cell.menuImageView.image = [self imageForHouseCellAtIndexPath:indexPath];
        
        House *house = [self houseAtIndexPath:indexPath];
        
        if (house) {

            cell.menuTextLabel.text =  house.name ? house.name : @"House";
        }
        else {
            cell.indentationLevel = 3;
            CTRLMenuCellType cellType = [self menuCellTypeAtIndexPath:indexPath];
            switch (cellType) {
                case CTRLMenuCellPanels:
                    cell.menuTextLabel.text = @"Panels";
                    break;
                case CTRLMenuCellFixtures:
                    cell.menuTextLabel.text = @"Fixtures";
                    break;
                case CTRLMenuCellRooms:
                    cell.menuTextLabel.text = @"Rooms";
                    break;
                default:
                    break;
            }
        }
        
    }
    else if (indexPath.section == 1) {
        
        NSString *cellLabel = @"Breaker";
        switch (indexPath.row) {
            case 0:
                cellLabel = @"Panel";
                break;
            case 1:
                cellLabel = @"House";
                break;
            default:
                break;
        }
        
        cell.menuTextLabel.text = cellLabel;
        cell.menuImageView.image = [[UIImage imageNamed:@"drawerAddIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
    }
    else {
        cell.menuTextLabel.text = @"Settings";
        cell.menuImageView.image = [[UIImage imageNamed:@"drawerSettingsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing && indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    else
        return UITableViewCellEditingStyleNone;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return YES;
    else
        return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        House *deletedHouse = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        
        NSManagedObjectContext *moc = self.fetchedResultsController.managedObjectContext;
        [moc performBlockAndWait:^{
            [moc deleteObject:deletedHouse];
            
            NSError *error;
            [moc save:&error];
        }];
        
        if (deletedHouse == self.activeHouse) {
            self.activeHouse = [[[self.fetchedResultsController.sections firstObject] objects] firstObject];
            
            UINavigationController *navController = (UINavigationController *)self.revealViewController.frontViewController;
            [navController popToRootViewControllerAnimated:NO];
            
            [[self.revealViewController activeFrontViewController] setHouse:self.activeHouse];
            [[self.revealViewController activeFrontViewController] rebuildDataSource];
        }
    }   
}

#pragma mark - NSFetchedResulsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
    NSManagedObjectContext *context = [CTRLDataStack sharedDataStack].mainContext;
    
    // If we have no MOC, persistence is currently offline.  No fetching.
    if (!context) {
        self.activeHouse = nil;
        self.expandedHouse = nil;
        self.panelsIndexPath = nil;
        self.fixturesIndexPath = nil;
        self.roomsIndexPath = nil;
        self.expanded = NO;
        return nil;
    }
    
    // If our MOC changed, invalidate the fetchedResultsController so it gets recreated.
    if (context != _fetchedResultsController.managedObjectContext) {
        self.panelsIndexPath = nil;
        self.fixturesIndexPath = nil;
        self.roomsIndexPath = nil;
        _fetchedResultsController = nil;
    }
    
    // If we have no fetchedResultsController, create one and perform a fetch to get the latest managed objects.
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        
        if (self.activeHouse)
            self.activeHouse = (House *)[context objectWithID:self.activeHouse.objectID];
        
        if (self.expandedHouse)
            self.expandedHouse = (House *)[context objectWithID:self.expandedHouse.objectID];
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self collapseExpandedHouse:YES];
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
            [self configureCell:(CTRLMenuTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
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
    
    if (self.activeHouse.isDeleted) {
        self.activeHouse = [[[self.fetchedResultsController.sections firstObject] objects] firstObject];
        
        UINavigationController *nc = (UINavigationController *)self.revealViewController.frontViewController;
        [nc popToRootViewControllerAnimated:NO];
        
        [[self.revealViewController activeFrontViewController] setHouse:self.activeHouse];
        [[self.revealViewController activeFrontViewController] rebuildDataSource];
    }

    if (self.expandedHouse.isDeleted) {
        self.expandedHouse = self.activeHouse;
        self.panelsIndexPath = nil;
        self.fixturesIndexPath = nil;
        self.roomsIndexPath = nil;
    }
    
    if (!self.isEditing) {
        [self expandHouse:self.expandedHouse animated:(self.revealViewController.frontViewPosition == FrontViewPositionRight)];
    }
}

#pragma mark - Helpers

- (House *)houseAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.expandedHouse && self.isExpanded) {
        NSIndexPath *expandedHouseIndexPath = [self.fetchedResultsController indexPathForObject:self.expandedHouse];
        
        if ([expandedHouseIndexPath isEqual:indexPath]) {
            return self.expandedHouse;
        }
        else if (indexPath.row < expandedHouseIndexPath.row) {
            return [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        else if (indexPath.row > expandedHouseIndexPath.row &&
                 (indexPath.row <= expandedHouseIndexPath.row + 3)) {
            return nil;
        }
        else {
            NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-3
                                                                inSection:indexPath.section];
            
            return [self.fetchedResultsController objectAtIndexPath:adjustedIndexPath];
        }
        
    }
    else {
        House *house = [self.fetchedResultsController objectAtIndexPath:indexPath];
        return house;
    }
}

- (UIImage *)imageForHouseCellAtIndexPath:(NSIndexPath *)indexPath
{
    CTRLMenuCellType cellType = [self menuCellTypeAtIndexPath:indexPath];
    
    if (cellType == CTRLMenuCellHouse) {
        return [[UIImage imageNamed:@"drawerHousesIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else if (cellType == CTRLMenuCellPanels) {
        return [[UIImage imageNamed:@"drawerPanelsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else if (cellType == CTRLMenuCellFixtures) {
        return [[UIImage imageNamed:@"drawerFixtureIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else if (cellType == CTRLMenuCellRooms) {
        return [[UIImage imageNamed:@"drawerRoomsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else {
        return nil;
    }
}

- (CTRLMenuCellType)menuCellTypeAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return CTRLMenuCellOther;
    }
    else {
        if (self.expandedHouse && self.isExpanded) {
            NSIndexPath *expandedHouseIndexPath = [self.fetchedResultsController indexPathForObject:self.expandedHouse];
            
            if (indexPath.row <= expandedHouseIndexPath.row) {
                return CTRLMenuCellHouse;
            }
            else if (indexPath.row > expandedHouseIndexPath.row+3) {
                return CTRLMenuCellHouse;
            }
            else {
                NSInteger expandedRowType = indexPath.row - expandedHouseIndexPath.row;
                
                if (expandedRowType == 1) {
                    return CTRLMenuCellPanels;
                }
                else if (expandedRowType == 2) {
                    return CTRLMenuCellFixtures;
                }
                else if (expandedRowType == 3) {
                    return CTRLMenuCellRooms;
                }
                else {
                    return CTRLMenuCellOther;
                }
            }
        }
        else {
            return CTRLMenuCellHouse;
        }
    }
    
    return CTRLMenuCellOther;
}


#pragma mark - Navigation

- (void)disableActiveControllerUserInteraction
{
    UINavigationController *navViewController = (UINavigationController *)self.revealViewController.frontViewController;
    
    UIViewController *vc = navViewController.viewControllers.firstObject;
    vc.view.userInteractionEnabled = NO;
}

- (void)enableActiveControllerUserInteraction
{
    UINavigationController *navViewController = (UINavigationController *)self.revealViewController.frontViewController;
    
    UIViewController *vc = navViewController.viewControllers.firstObject;
    vc.view.userInteractionEnabled = YES;
}

- (BOOL)showPanelsControllerForActiveHouse
{
    if (!self.activeHouse)
        return NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLPanelsViewController *panelsVC = (CTRLPanelsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"panelsViewController"];
    panelsVC.house = self.activeHouse;
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:panelsVC];
    [self.revealViewController setFrontViewController:nc animated:YES];
    
    return YES;
}

- (void)showFixturesControllerForActiveHouse
{
    if (!self.activeHouse)
        return;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLFixturesViewController *fixturesVC = (CTRLFixturesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"fixturesViewController"];
    fixturesVC.house = self.activeHouse;
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:fixturesVC];
    [self.revealViewController setFrontViewController:nc animated:YES];
}

- (void)showRoomsControllerForActiveHouse
{
    if (!self.activeHouse)
        return;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLRoomsViewController *roomsVC = (CTRLRoomsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"roomsViewController"];
    roomsVC.house = self.activeHouse;
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:roomsVC];
    [self.revealViewController setFrontViewController:nc animated:YES];
}


- (void)presentEditHouseControllerForHouse:(House *)house expandHouseOnCompletion:(BOOL)selectOnCompletion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLEditHouseViewController *editHouseVC = (CTRLEditHouseViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editHouseViewController"];
    
    
    editHouseVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:editHouseVC action:@selector(resetAndDismiss)];

    editHouseVC.rightButtonTappedBlock = ^(){
        [self dismissViewControllerAnimated:YES completion:^(){
            if (selectOnCompletion) {
                NSManagedObjectContext *mainContext = [[CTRLDataStack sharedDataStack] mainContext];
                House *edittedHouse = (House *)[mainContext objectWithID:house.objectID];
                
                [self expandHouse:edittedHouse animated:YES];
            }
        }];
    };
    editHouseVC.allowPanelCreation = YES;
    editHouseVC.house = house;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editHouseVC];
    
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position
{
    if (self.editing)
        [self setEditing:NO animated:YES];
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionLeft) {
        [self enableActiveControllerUserInteraction];
        [self.revealViewController.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];

        UIViewController *rootViewController = [revealController activeFrontViewController];
        
        if (self.menuTransitionCompletionActionType == CTRLMenuTransitionCompletionAddBreaker) {
            
        }
        else if (self.menuTransitionCompletionActionType == CTRLMenuTransitionCompletionAddPanel) {
            [(CTRLPanelsViewController *)rootViewController addTapped:nil];
        }
        
        self.menuTransitionCompletionActionType = CTRLMenuTransitionCompletionNone;
    }
    else if (position == FrontViewPositionRight) {
        
        [self disableActiveControllerUserInteraction];
        [self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    return self.revealViewController.frontViewPosition == FrontViewPositionRight;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
   return UIStatusBarAnimationSlide;
}

#pragma mark - UITableViewController+CoreDataiCloud Override

- (void)showLoadingSpinner
{
    UIView *loadingView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = loadingView.center;
    [activityIndicatorView startAnimating];
    
    [loadingView addSubview:activityIndicatorView];
    self.tableView.backgroundView = loadingView;
}

@end

#pragma mark - SWRevealViewController Helper Category

@implementation SWRevealViewController (CTRLFrontPanelRootViewController)

- (UIViewController<CTRLFrontPanelRootViewController> *)activeFrontViewController
{
    UIViewController<CTRLFrontPanelRootViewController> *activeViewController = (UIViewController<CTRLFrontPanelRootViewController> *)self.frontViewController;
    
    if ([activeViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController<CTRLFrontPanelRootViewController> *activeVC = [[(UINavigationController *)activeViewController viewControllers] firstObject];
        return ([activeVC conformsToProtocol:@protocol(CTRLFrontPanelRootViewController)] ? activeVC : nil);
    }
    else if ([activeViewController conformsToProtocol:@protocol(CTRLFrontPanelRootViewController)]){
        return (UIViewController<CTRLFrontPanelRootViewController> *)activeViewController;
    }
    else {
        return nil;
    }
}

@end
