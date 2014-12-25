//
//  CTRLBreakersViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/2/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLBreakerColumnViewController.h"
#import "CTRLEditBreakerViewController.h"
#import "CTRLSwitch.h"
#import "CTRLBreakerCell.h"
#import "CTRLBreakerLayout.h"
#import "UIColor+UIColorFromRGB.h"
#import "CTRLDataStack.h"
#import "Breaker.h"
#import "Breaker+Helpers.h"
#import "Panel.h"
#import "Panel+Helpers.h"

static UIColor *lastChosenColor;
static SwitchOrientation lastOrientation = 0;
static NSString *const CTRLBreakerLeftCellSingle = @"BreakerLeftCellSingle";
static NSString *const CTRLBreakerLeftCellDouble = @"BreakerLeftCellDouble";
static NSString *const CTRLBreakerRightCellSingle = @"BreakerRightCellSingle";
static NSString *const CTRLBreakerRightCellDouble = @"BreakerRightCellDouble";
static NSString *const CTRLBreakerLeftCellQuadruple = @"BreakerLeftCellQuadruple";
static NSString *const CTRLBreakerRightCellQuadruple = @"BreakerRightCellQuadruple";

@class UIDeviceRGBColor;
@interface CTRLBreakerColumnViewController ()<CTRLEditBreakerDelegate, CTRLBreakerCellDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISegmentedControl *panelSideSegmentedControl;
@property (nonatomic, strong) UIView *segmentedBackgroundView;
@property (nonatomic, strong) UIView *emptyPanelView;
@property (nonatomic, assign, getter = isReorderings) BOOL reordering;
@property (nonatomic, strong) NSManagedObjectContext *breakerOnContext;

@end

@implementation CTRLBreakerColumnViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!lastChosenColor) {
        lastChosenColor = [UIColor colorWithR:76 g:217 b:100];
    }

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithR:169 g:169 b:169];
    
    [self.tableView registerNib:[UINib nibWithNibName:CTRLBreakerLeftCellSingle bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CTRLBreakerLeftCellSingle];
    [self.tableView registerNib:[UINib nibWithNibName:CTRLBreakerLeftCellDouble bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CTRLBreakerLeftCellDouble];
    [self.tableView registerNib:[UINib nibWithNibName:CTRLBreakerRightCellSingle bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CTRLBreakerRightCellSingle];
    [self.tableView registerNib:[UINib nibWithNibName:CTRLBreakerRightCellDouble bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CTRLBreakerRightCellDouble];
    [self.tableView registerNib:[UINib nibWithNibName:CTRLBreakerLeftCellQuadruple bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CTRLBreakerLeftCellQuadruple];
    [self.tableView registerNib:[UINib nibWithNibName:CTRLBreakerRightCellQuadruple bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CTRLBreakerRightCellQuadruple];
    
    NSString *predicateString = [NSString stringWithFormat:@"panel = %@", self.panel];
    if (self.panelColumn)
        predicateString = [predicateString stringByAppendingFormat:@"AND panelColumn = %@", self.panelColumn];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Breaker"];
    if (self.panelColumn) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"panel = %@ AND panelColumn = %@", self.panel, self.panelColumn];
    }
    else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"panel = %@", self.panel];
    }

    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"panelRow" ascending:YES]];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[CTRLDataStack sharedDataStack] mainContext] sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;

    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showEmptyPanelViewIfNecessary];
    
    self.breakerOnContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.breakerOnContext.parentContext = [[CTRLDataStack sharedDataStack] mainContext];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    [self.breakerOnContext performBlock:^{
        NSError *error;
        
        [self.breakerOnContext save:&error];
        
        if (!error) {
            [[[CTRLDataStack sharedDataStack] mainContext] performBlock:^{
                NSError *mainContextError;
                [[[CTRLDataStack sharedDataStack] mainContext] save:&mainContextError];
            }];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    void (^styleBlock)();
    if (editing) {

        styleBlock = ^(){
            self.tableView.backgroundColor = [UIColor defaultEditingCollectionViewColor];
            self.emptyPanelView.backgroundColor = [UIColor defaultEditingCollectionViewColor];
        };
    }
    else {
        styleBlock = ^(){
            self.tableView.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
            self.emptyPanelView.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
        };
    }
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:styleBlock];
    }
    else {
        styleBlock();
    }
}

#pragma mark - UINavigationItem Bar Button Actions

- (void)addTapped:(UIBarButtonItem *)barButton
{
    NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
    Panel *panel = (Panel *)[moc objectWithID:self.panel.objectID];
    Breaker *breaker = [NSEntityDescription insertNewObjectForEntityForName:@"Breaker"
                                                     inManagedObjectContext:moc];
    
    NSArray *columnBreakers = [self.panel.breakers allObjects];
    
    if (self.panelColumn) {
        NSPredicate *columnPredicate = [NSPredicate predicateWithFormat:@"panelColumn = %@", self.panelColumn];
        columnBreakers = [columnBreakers filteredArrayUsingPredicate:columnPredicate];
    }
    
    columnBreakers = [columnBreakers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"panelRow" ascending:YES]]];
    
    NSNumber *highestIndex = [columnBreakers valueForKeyPath:@"@max.panelRow"];

    breaker.name = [NSString stringWithFormat:@"A%lu", panel.breakers.count+1ul];
    breaker.panel = panel;
    breaker.panelRow = @(highestIndex.intValue+1);
    breaker.panelColumn = (self.panelColumn ? self.panelColumn : @(0));
    breaker.color = lastChosenColor;
    breaker.switchOrientation = lastOrientation;
    [panel addBreakersObject:breaker];
    
    CTRLEditBreakerViewController *editBreakerViewController = [[CTRLEditBreakerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editBreakerViewController.breaker = breaker;
    editBreakerViewController.title = @"New Breaker";
    editBreakerViewController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editBreakerViewController];
    navController.navigationBar.translucent = NO;
    
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Empty Panel

- (void)showEmptyPanelViewIfNecessary
{
    BOOL showEmptyPanel = NO;
    
    if (!self.panelColumn && self.panel.breakers.count == 0) {
        showEmptyPanel = YES;
    }
    else if (self.panelColumn) {
        NSSet *panelColumnBreakers = [self.panel.breakers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"panelColumn = %@", self.panelColumn]];
        
        if (panelColumnBreakers.count == 0)
            showEmptyPanel = YES;
    }

    if (showEmptyPanel) {
        if (self.emptyPanelView.superview)
        {
            return;
        }
        else {
            UIImage *addBreakerImage = nil;
            switch (self.panel.panelType) {
                case PanelVerticalSingleRow:
                    addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerVerticalSingle"];
                    break;
                case PanelVerticalDoubleRow:
                    if (self.panelColumn.intValue == 0) {
                        addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerVerticalDoubleLeft"];
                    }
                    else {
                        addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerVerticalDoubleRight"];
                    }
                    break;
                case PanelHorizontalSingleRow:
                    addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerHorizontalSingle"];
                    break;
                case PanelHorizontalDoubleRow:
                    if (self.panelColumn.intValue == 0) {
                        addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerHorizontalDoubleTop"];
                    }
                    else {
                        addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerHorizontalDoubleBottom"];
                    }
                    break;
                default:
                    addBreakerImage = [UIImage imageNamed:@"addYourFirstBreakerVerticalSingle"];
                    break;
            }
            
            UIButton *addBreakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [addBreakerButton setImage:addBreakerImage forState:UIControlStateNormal];
            addBreakerButton.frame = CGRectMake(CGRectGetMidX(self.tableView.bounds)-addBreakerImage.size.width/2, CGRectGetMidY(self.tableView.bounds)-addBreakerImage.size.height/2, addBreakerImage.size.width, addBreakerImage.size.height);
            [addBreakerButton addTarget:self action:@selector(addBreakerTapped) forControlEvents:UIControlEventTouchUpInside];
            addBreakerButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            
            self.emptyPanelView = [[UIView alloc] initWithFrame:self.tableView.bounds];
            self.emptyPanelView.backgroundColor = self.tableView.backgroundColor;
            
            UILabel *emptyPanelText = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addBreakerButton.frame), CGRectGetWidth(self.emptyPanelView.bounds), 30)];
            emptyPanelText.text = @"To add a breaker, tap Edit";
            emptyPanelText.backgroundColor = [UIColor clearColor];
            emptyPanelText.textColor = [UIColor darkGrayColor];
            emptyPanelText.font  = [UIFont systemFontOfSize:16];
            emptyPanelText.textAlignment = NSTextAlignmentCenter;
            emptyPanelText.center = CGPointMake(addBreakerButton.center.x, emptyPanelText.center.y);

            [self.emptyPanelView addSubview:addBreakerButton];
            [self.emptyPanelView addSubview:emptyPanelText];
            [self.view addSubview:self.emptyPanelView];
            self.tableView.scrollEnabled = NO;
        }
    }
    else {
        [self.emptyPanelView removeFromSuperview];
        self.tableView.scrollEnabled = YES;
    }
}

- (void)addBreakerTapped
{
    [self.parentViewController setEditing:YES animated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Breaker *breaker = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (breaker.amperage.intValue >= 70) {
        return 176.0;
    }
    else if (breaker.isDoublePole) {
        return  88.0;
    }
    else {
        return 44.0;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isEditing;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.fetchedResultsController.fetchedObjects.count) {
        
        [self addTapped:nil];
    }
    else {
        if (self.isEditing) {
            
            Breaker *selectedBreaker = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
            Breaker *breaker = (Breaker *)[moc objectWithID:selectedBreaker.objectID];
            
            CTRLEditBreakerViewController *editBreakerViewController = [[CTRLEditBreakerViewController alloc] initWithStyle:UITableViewStyleGrouped];
            editBreakerViewController.breaker = breaker;
            editBreakerViewController.title = @"Edit Breaker";
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editBreakerViewController];
            
            
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isEditing;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    Breaker *breaker = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    Breaker *toBreaker = [self.fetchedResultsController objectAtIndexPath:toIndexPath];
    NSNumber *targetRow = toBreaker.panelRow;
    
    if (fromIndexPath.row < toIndexPath.row) {
        NSArray *allBreakers = [self.fetchedResultsController.sections.firstObject objects];
        NSArray *affectedBreakers = [allBreakers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"panelRow <= %@", targetRow]];
        
        for (Breaker *affectedBreaker in affectedBreakers) {
            affectedBreaker.panelRow = @(affectedBreaker.panelRow.intValue-1);
        }
        
        breaker.panelRow = targetRow;
    }
    else {
        
        NSNumber *originalRow = breaker.panelRow;

        NSArray *allBreakers = [self.fetchedResultsController.sections.firstObject objects];
        NSArray *affectedBreakers = [allBreakers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"panelRow >= %@ AND panelRow <= %@", targetRow, originalRow]];
        
        for (Breaker *affectedBreaker in affectedBreakers) {
            affectedBreaker.panelRow = @(affectedBreaker.panelRow.intValue+1);
        }
        
        breaker.panelRow = targetRow;
    }
    self.reordering = YES;
    [self.panel.managedObjectContext performBlockAndWait:^{
        
        NSError *error;
        [self.panel.managedObjectContext save:&error];
    }];
    self.reordering = NO;
//    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Breaker *breaker = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!breaker)
        return;
    
    [breaker.managedObjectContext deleteObject:breaker];
    
    [breaker.managedObjectContext performBlock:^{
        NSError *error;
        [breaker.managedObjectContext save:&error];
    }];
    
    
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    UITableViewCell *breakerCell = nil;
    Breaker *breaker = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (breaker.amperage.intValue >= 70) {
        if (breaker.switchOrientation == SwitchOrientationRight)
            breakerCell = [self.tableView dequeueReusableCellWithIdentifier:CTRLBreakerRightCellQuadruple];
        else
            breakerCell = [self.tableView dequeueReusableCellWithIdentifier:CTRLBreakerLeftCellQuadruple];
    }
    else {
        if (breaker.isDoublePole) {
            if (breaker.switchOrientation == SwitchOrientationRight)
                breakerCell = [self.tableView dequeueReusableCellWithIdentifier:CTRLBreakerRightCellDouble];
            else
                breakerCell = [self.tableView dequeueReusableCellWithIdentifier:CTRLBreakerLeftCellDouble];
        }
        else {
            if (breaker.switchOrientation == SwitchOrientationRight)
                breakerCell = [self.tableView dequeueReusableCellWithIdentifier:CTRLBreakerRightCellSingle];
            else
                breakerCell = [self.tableView dequeueReusableCellWithIdentifier:CTRLBreakerLeftCellSingle];
        }
    }
    
    [self configureCell:(CTRLBreakerCell *)breakerCell withBreaker:breaker];
    
    
    return breakerCell;
}

- (void)configureCell:(CTRLBreakerCell *)breakerCell withBreaker:(Breaker *)breaker
{
    breakerCell.showsReorderControl = YES;
    breakerCell.backgroundColor = [UIColor colorWithR:240 g:240 b:240];
    breakerCell.delegate = self;
    breakerCell.nameText = breaker.name;
    
    breakerCell.breakerAccentColor = breaker.color;
    NSNumber *amperage = breaker.amperage;
    
    if (breaker.amperage.intValue >= 70)
        amperage = @(amperage.intValue/2);
    
    breakerCell.amperageText = [NSString stringWithFormat:@"%@A", amperage];
    breakerCell.showGFCI = breaker.isGFCI;
    breakerCell.punchout = breaker.isPunchout;
    
    Breaker *onContextBreaker = (Breaker *)[self.breakerOnContext objectWithID:breaker.objectID];
    if (onContextBreaker.on.boolValue && !breaker.isPunchout && breaker.fixtures.count ) {
        breakerCell.breakerSwitch.on = YES;
        [breakerCell showBadge:NO];
        breakerCell.badgeText = @(breaker.fixtures.count).stringValue;
    }
    else {
        [breakerCell hideBadge:NO];
    }
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - NSFetchedResulsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if (self.reordering)
        return;
    
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (self.reordering)
        return;
    
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
    
    if (self.reordering)
        return;
    
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
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    if (self.reordering)
        return;
    
    [self.tableView endUpdates];
    
    [self showEmptyPanelViewIfNecessary];
}

#pragma mark - CTRLBreakerCellDelegate

- (void)breakerCell:(CTRLBreakerCell *)cell didDetectSwitchChangeButtonTap:(CTRLSwitch *)flipSwitch
{
    NSIndexPath *breakerIndexPath = [self.tableView indexPathForCell:cell];
    
    Breaker *breaker = [self.fetchedResultsController objectAtIndexPath:breakerIndexPath];

    if (!breaker)
        return;
    
    Breaker *onContextBreaker = (Breaker *)[self.breakerOnContext objectWithID:breaker.objectID];
    onContextBreaker.on = @(flipSwitch.on);

    if (onContextBreaker.on.boolValue && breaker.fixtures.count) {
        cell.badgeText = @(breaker.fixtures.count).stringValue;
        [cell showBadge:YES];
    }
    else {
        [cell hideBadge:YES];
    }
}

#pragma mark - EditBreakerDelegate

- (void)editBreakerController:(CTRLEditBreakerViewController *)controller didSaveBreaker:(Breaker *)breaker
{
    lastOrientation = breaker.switchOrientation;
    lastChosenColor = breaker.color;
}

@end
