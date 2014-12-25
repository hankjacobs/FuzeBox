//
//  CTRLEditBreakerViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLEditBreakerViewController.h"
#import "CTRLDataStack.h"
#import "CTRLEditAmperageViewController.h"
#import "CTRLEditFixtureViewController.h"
#import "CTRLPropertyEditorViewController.h"
#import "CTRLColorPickerCell.h"
#import "CTRLColorPicker.h"
#import "Breaker+Helpers.h"
#import "Fixture.h"
#import "Panel.h"
#import "House.h"
#import "Room+Helpers.h"

static NSString *CheckMarkCellIdentifier = @"CheckedCell";
static NSString *SwitchCellIdentifier = @"SwitchCell";
static NSString *LeftRightCellIdentifier = @"LeftRightCell";
static NSString *ColorPickerCellIdentifier = @"ColorPickerCell";
static NSString *NewControlledFixtureCell = @"NewControllerFixtureCell";
static NSString *ControlledFixtureCell = @"ControlledFixtureCell";

@interface CTRLEditBreakerViewController ()<CTRLEditPropertyDelegate, CTRLEditAmperageDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISwitch *punchoutSwitch;
@property (nonatomic, strong) UISwitch *gfciSwitch;
@property (nonatomic, strong) UISwitch *tandemSwitch;
@property (nonatomic, strong) CTRLColorPicker *colorPicker;
@property (nonatomic, strong) NSManagedObjectContext *fixtureContext;

@end

@implementation CTRLEditBreakerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneTapped:)];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fixture"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"breaker = %@", self.breaker];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.breaker.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    [self.breaker addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionInitial context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.breaker removeObserver:self forKeyPath:@"name"];
}

#pragma mark - NavBar Button Handles

- (void)cancelTapped:(UIBarButtonItem *)barButtonItem
{
    [self.breaker.managedObjectContext reset];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneTapped:(UIBarButtonItem *)barButtonItem
{

    self.breaker.gfci = @(self.gfciSwitch.isOn);
    self.breaker.tandem = @(self.tandemSwitch.isOn);

    [self.breaker.managedObjectContext performBlock:^{
        NSError *error;
        [self.breaker.managedObjectContext save:&error];
    }];
    
    if ([self.delegate respondsToSelector:@selector(editBreakerController:didSaveBreaker:)]) {
        [self.delegate editBreakerController:self didSaveBreaker:self.breaker];
    }
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.breaker.isPunchout) {
        return 1;
    } else {
        return 5;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case 0:
            title = nil;
            break;
        case 1:
            title = nil;
            break;
        case 2:
            title = @"Breaker Orientation";
            break;
        case 3:
            title = @"Breaker Color";
            break;
        case 4:
            title = @"Controlled Fixtures";
            break;
        default:
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfRows = 0;
    switch (section) {
        case 0: //Punchout
            numOfRows = 1;
            break;
        case 1: //Name,Amp,gfci, (removed tandem)
            numOfRows = 3;
            break;
        case 2: //Breaker orientation
            numOfRows = 2;
            break;
        case 3: // Breaker Color
            numOfRows = 1;
            break;
        case 4: //Controlled Fixtures
            numOfRows = self.breaker.fixtures.count + 1;
            break;
    }
    
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentIdentifier = nil;
    
    if ((indexPath.section == 0 && indexPath.row == 0) ||
        (indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3))) {
        currentIdentifier = SwitchCellIdentifier;
    }
    else if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)){
        currentIdentifier = LeftRightCellIdentifier;
    }
    else if (indexPath.section == 2) {
        currentIdentifier = CheckMarkCellIdentifier;
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        currentIdentifier = ColorPickerCellIdentifier;
    }
    else if (indexPath.section == 4 && indexPath.row == self.breaker.fixtures.count) {
        currentIdentifier = NewControlledFixtureCell;
    }
    else {
        currentIdentifier = ControlledFixtureCell;
    }
    
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:currentIdentifier];
    
    cell = [self configureCell:cell withIdentifier:currentIdentifier forIndexPath:indexPath];
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 3 && indexPath.row == 0)
    {
        return 240;
    }
    else {
        return self.tableView.rowHeight;
    }
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            self.breaker.switchOrientation = SwitchOrientationRight;
        }
        else {
            self.breaker.switchOrientation = SwitchOrientationLeft;
        }
        
        [self.tableView reloadData];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            
            UIViewController *controller = nil;
            if (indexPath.row == 0) {
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CTRLPropertyEditorViewController *propertyEditorViewController = (CTRLPropertyEditorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"propertyEditor"];
                propertyEditorViewController.delegate = self;

                propertyEditorViewController.propertyKey = @"name";
                propertyEditorViewController.value = self.breaker.name;
                propertyEditorViewController.keyboardType = UIKeyboardTypeDefault;
            
                controller = (UIViewController *)propertyEditorViewController;
            }
            else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CTRLEditAmperageViewController *amperageEditorViewController = (CTRLEditAmperageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"amperageEditor"];
                amperageEditorViewController.delegate = self;
                
                amperageEditorViewController.amperage = self.breaker.amperage;
                amperageEditorViewController.isDoublePole = self.breaker.isDoublePole;
                
                controller = (CTRLEditAmperageViewController *)amperageEditorViewController;
            }
            
            [self.navigationController pushViewController:controller animated:YES];
            
            
        }
    }
    else if (indexPath.section == 4 && indexPath.row == self.breaker.fixtures.count) {
        
        if (!self.fixtureContext) {
            self.fixtureContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            self.fixtureContext.parentContext = self.breaker.managedObjectContext;
        }

        Fixture *fixture = [NSEntityDescription insertNewObjectForEntityForName:@"Fixture"
                                                         inManagedObjectContext:self.fixtureContext];
        fixture.breaker = (Breaker *)[self.fixtureContext objectWithID:self.breaker.objectID];
        
        NSString *breakerName = fixture.breaker.name ? fixture.breaker.name : @"";
        fixture.name = [breakerName stringByAppendingString:@" Fixture"];
        
        House *currentHouse = (House *)[self.fixtureContext objectWithID:self.breaker.panel.house.objectID];
        fixture.room = [Room unassignedRoomForHouse:currentHouse];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CTRLEditFixtureViewController *fixtureEditorViewController = (CTRLEditFixtureViewController *)[storyboard instantiateViewControllerWithIdentifier:@"fixtureEditor"];
        fixtureEditorViewController.fixture = fixture;
        fixtureEditorViewController.title = @"New Fixture";
        fixtureEditorViewController.house = currentHouse;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fixtureEditorViewController];
        
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - Cell Helpers

- (UITableViewCell *)configureCell:(UITableViewCell *)cell withIdentifier:(NSString *)identifer forIndexPath:(NSIndexPath *)indexPath
{
    if ([identifer isEqualToString:SwitchCellIdentifier]) {
        cell = [self configureSwitchCell:cell forIndexPath:indexPath];
    }
    else if ([identifer isEqualToString:LeftRightCellIdentifier]) {
        cell = [self configureLeftRightCell:cell forIndexPath:indexPath];
    }
    else if ([identifer isEqualToString:CheckMarkCellIdentifier]) {
        cell = [self configureCheckmarkCell:cell forIndexPath:indexPath];
    }
    else if ([identifer isEqualToString:ColorPickerCellIdentifier]) {
        cell = [self configureColorPickerCell:(CTRLColorPickerCell *)cell forIndexPath:indexPath];
    }
    else if ([identifer isEqualToString:NewControlledFixtureCell]) {
        cell = [self configureNewControlledFixtureCell:cell forIndexPath:indexPath];
    }
    else {
       cell = [self configureControlledFixtureCell:cell forIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell *)configureSwitchCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SwitchCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Blank Knock-Out";
        self.punchoutSwitch.on = self.breaker.isPunchout;
        cell.accessoryView = self.punchoutSwitch;
        
    }
    else if (indexPath.section == 1){
//        if (indexPath.row == 2) {
//            cell.textLabel.text = @"Tandem Breaker";
//            self.tandemSwitch.on = [self.breaker isTandem];
//            cell.accessoryView = self.tandemSwitch;
//        }
//        else {
            cell.textLabel.text = @"GFCI Breaker";
            self.gfciSwitch.on = [self.breaker isGFCI];
            cell.accessoryView = self.gfciSwitch;
//        }
    }

    return cell;
}

- (UITableViewCell *)configureLeftRightCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:LeftRightCellIdentifier];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.breaker.name;
        }
        else {
            cell.textLabel.text = @"Amperage";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.breaker.amperage];
        }
    }
    
    return cell;
}

- (UITableViewCell *)configureCheckmarkCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier];
    }
    
    if (indexPath.section == 2) {
        
        SwitchOrientation orientation = self.breaker.switchOrientation;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Right Switch";
            
            if (orientation == SwitchOrientationRight) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Left Switch";
            
            if (orientation == SwitchOrientationLeft) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    return cell;
}

- (CTRLColorPickerCell *)configureColorPickerCell:(CTRLColorPickerCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        cell = [[CTRLColorPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier];
    }
    
    cell.colorPicker = self.colorPicker;
    cell.colorPicker.selectedColorIndex = [cell.colorPicker.colors indexOfObject:self.breaker.color];
    
    return cell;
}

- (UITableViewCell *)configureNewControlledFixtureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewControlledFixtureCell];
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = @"Add New Fixture";
    
    return cell;
}

- (UITableViewCell *)configureControlledFixtureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ControlledFixtureCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Fixture *fixture = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    cell.textLabel.text = fixture.name;
    
    return cell;
}

#pragma mark - Setters and Getters

- (UISwitch *)punchoutSwitch
{
    if (!_punchoutSwitch) {
        _punchoutSwitch = [[UISwitch alloc] init];
        [_punchoutSwitch addTarget:self action:@selector(punchoutChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _punchoutSwitch;
}

- (UISwitch *)gfciSwitch
{
    if (!_gfciSwitch) {
        _gfciSwitch = [[UISwitch alloc] init];
        [_gfciSwitch addTarget:self action:@selector(gfciChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _gfciSwitch;
}

- (UISwitch *)tandemSwitch
{
    if (!_tandemSwitch) {
        _tandemSwitch = [[UISwitch alloc] init];
        [_tandemSwitch addTarget:self action:@selector(tandemChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _tandemSwitch;
}
        
- (CTRLColorPicker *)colorPicker
{
    if (!_colorPicker) {
        _colorPicker = [[CTRLColorPicker alloc] initWithFrame:CGRectZero];
        [_colorPicker addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventValueChanged];
        _colorPicker.selectedColorIndex = [_colorPicker.colors indexOfObject:self.breaker.color];
    }
    
    return _colorPicker;
}

#pragma mark - Control Events

- (void)colorPicked:(CTRLColorPicker *)colorPicker
{
    self.breaker.color = self.colorPicker.colors[self.colorPicker.selectedColorIndex];
}

- (void)punchoutChanged:(UISwitch *)punchoutSwitch
{
    self.breaker.punchout = @(punchoutSwitch.isOn);
    
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)];

    if (self.breaker.isPunchout) {
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)gfciChanged:(UISwitch *)gfciSwitch
{
    self.breaker.gfci = @(gfciSwitch.isOn);
}

- (void)tandemChanged:(UISwitch *)tandemSwitch
{
    self.breaker.tandem = @(tandemSwitch.isOn);
}

#pragma mark - Property Editor Delegate

- (void)propertyEditor:(CTRLPropertyEditorViewController *)propertyEditor didRegisterChangeForPropertyKey:(NSString *)propertyKey withValue:(NSString *)value
{
    [self.breaker setValue:value forKey:propertyKey];
    [self.tableView reloadData];
}

#pragma mark - Amperage Editor Delegate

- (void)amperageEditor:(CTRLEditAmperageViewController *)editor didSelectAmperage:(NSNumber *)amperage isDoublePole:(BOOL)isDoublePole
{
    self.breaker.amperage = amperage;
    self.breaker.doublePole = @(isDoublePole);
    
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
    });
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
// This should never be called as we only have one section managed by NSFetchedResults
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:4];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:4];
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
                [self configureControlledFixtureCell:[tableView cellForRowAtIndexPath:indexPath]
                        forIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    });
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView endUpdates];
    });
}

#pragma mark - Key-Value Observing 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *cleanedName = [self.breaker.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (cleanedName.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
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
