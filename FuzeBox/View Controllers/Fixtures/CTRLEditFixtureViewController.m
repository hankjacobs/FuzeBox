//
//  CTRLEditFixtureViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/17/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLEditFixtureViewController.h"
#import "CTRLPropertyEditorViewController.h"
#import "Room.h"
#import "Fixture.h"
#import "Panel.h"
#import "Breaker.h"
#import "House.h"
#import "CTRLGridImagePicker.h"
#import "Fixture+Helpers.h"
#import "CTRLGenericSelectionListViewController.h"
#import "CTRLSeededRoomSelectionListViewController.h"

@interface CTRLEditFixtureViewController ()<CTRLEditPropertyDelegate, CTRLGenericSelectionDelegate>

@property (nonatomic, strong) NSArray *fixtureIcons;
@property (nonatomic, strong) NSArray *selectedFixtureIcons;
@property (nonatomic, strong) UISegmentedControl *iconTypeControl;

@end

@implementation CTRLEditFixtureViewController

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
    
    if (self.fixture.iconIndex.integerValue & CTRLElectricalIconOffset)
        self.useElectricalIcons = YES;

    [self loadIcons];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    [self.fixture addObserver:self
                   forKeyPath:@"breaker"
                      options:NSKeyValueObservingOptionInitial
                      context:NULL];
    
    [self.fixture addObserver:self forKeyPath:@"name"
                      options:NSKeyValueObservingOptionInitial
                      context:NULL];
}

- (void)dealloc
{
    [self.fixture removeObserver:self forKeyPath:@"breaker"];
    [self.fixture removeObserver:self forKeyPath:@"name"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationItem Bar Buttons

- (void)cancelTapped:(UIBarButtonItem *)barButton
{
    [self.fixture.managedObjectContext reset];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneTapped:(UIBarButtonItem *)barButton
{
    NSSet *updatedObjects = [self.fixture.managedObjectContext insertedObjects];
    NSPredicate *emptyRoomsPredicate = [NSPredicate predicateWithFormat:@"class == %@ AND fixtures.@count == 0", [Room class]];
    NSSet *emptyRooms = [updatedObjects filteredSetUsingPredicate:emptyRoomsPredicate];

    for (Room *emptyRoom in emptyRooms) {
        [self.fixture.managedObjectContext deleteObject:emptyRoom];
    }
    
    [self.fixture.managedObjectContext performBlock:^{
        NSError *error;
        [self.fixture.managedObjectContext save:&error];
    }];
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return @"Fixture Type";
    else
        return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return ceil((CGFloat)self.fixtureIcons.count/4.0) * 80.0;
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const rightDetailCellIdentifier = @"detailTableViewCell";
    static NSString *const blankCellIdentifier = @"blankTableViewCell";
    static NSString *const fixtureIconTypeCellIdentifier = @"fixtureIconTypeCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:rightDetailCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        switch (indexPath.row) {
            case 0: {
                NSString *name = self.fixture.name;
                cell.detailTextLabel.text = name;
                cell.textLabel.text = @"Name";
                
                break;
            }
            case 1:
                cell.detailTextLabel.text = self.fixture.room.name;
                cell.textLabel.text = @"Room";
                break;
            case 2:
                if (!self.allowsBreakerChange) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                if (self.fixture.breaker.name) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", self.fixture.breaker.panel.name, self.fixture.breaker.name];
                }
                else {
                    cell.detailTextLabel.text = @"";
                }
                cell.textLabel.text = @"Breaker";
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:fixtureIconTypeCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;
        
        self.iconTypeControl = (UISegmentedControl *)[cell.contentView viewWithTag:100];
        self.iconTypeControl.selectedSegmentIndex = (self.useElectricalIcons ? 1 : 0);
        [self.iconTypeControl addTarget:self action:@selector(iconTypeChanged:) forControlEvents:UIControlEventValueChanged];
        

    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:blankCellIdentifier];
        
        //Lazy man avoiding subclassing cell
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        CTRLGridImagePicker *imagePicker = [[CTRLGridImagePicker alloc] initWithFrame:cell.contentView.bounds
                                                                               images:self.fixtureIcons
                                                                       selectedImages:self.selectedFixtureIcons];
        
        NSInteger selectedIndex = self.fixture.iconIndex.intValue^(self.useElectricalIcons ? CTRLElectricalIconOffset : 0);
        imagePicker.selectedIndex = selectedIndex;
        
        [imagePicker addTarget:self action:@selector(iconChanged:) forControlEvents:UIControlEventValueChanged];
        imagePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:imagePicker];

    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CTRLPropertyEditorViewController *propertyEditorViewController = (CTRLPropertyEditorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"propertyEditor"];
        propertyEditorViewController.delegate = self;
        
        propertyEditorViewController.propertyKey = @"name";
        propertyEditorViewController.value = self.fixture.name;
        propertyEditorViewController.keyboardType = UIKeyboardTypeDefault;
        
        [self.navigationController pushViewController:propertyEditorViewController animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Room"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"house = %@ AND name != %@", self.house, @"Unassigned"];
        
        CTRLSeededRoomSelectionListViewController *selectionListController =
                                                                [[CTRLSeededRoomSelectionListViewController alloc]
                                                                           initWithStyle:UITableViewStylePlain
                                                                           fetchRequest:fetchRequest
                                                                           sectionNameKeyPath:nil
                                                                           managedObjectContext:[self.fixture managedObjectContext]];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSArray *roomNameSeeds = [infoDict objectForKey:@"CTRLRoomNameSeeds"];
        selectionListController.displayKeyPath = @"name";
        selectionListController.seededCellTitles = roomNameSeeds;
        selectionListController.title = @"Room";
        selectionListController.delegate = self;
        selectionListController.selectedCellTitle = self.fixture.room.name;
        selectionListController.house = self.house;
        
        [self.navigationController pushViewController:selectionListController animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2 && self.allowsBreakerChange) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Breaker"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"panel.house = %@", self.house];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"panel.name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        CTRLGenericSelectionListViewController *selectionListController = [[CTRLGenericSelectionListViewController alloc]
                                                                 initWithStyle:UITableViewStylePlain
                                                                 fetchRequest:fetchRequest
                                                                 sectionNameKeyPath:@"panel.name"
                                                                 managedObjectContext:[self.fixture managedObjectContext]];
        selectionListController.title = @"Assigned Breaker";
        selectionListController.delegate = self;
        selectionListController.selectedObject = self.fixture.breaker;
        
        [self.navigationController pushViewController:selectionListController animated:YES];
    }
}


#pragma mark - CTRLPropertyEditorDelegate

- (void)propertyEditor:(CTRLPropertyEditorViewController *)propertyEditor didRegisterChangeForPropertyKey:(NSString *)propertyKey withValue:(NSString *)value
{
    [self.fixture setValue:value forKey:propertyKey];
    [self.tableView reloadData];
}

#pragma mark - Icons

- (void)loadIcons
{
    
    NSString *iconType = @"CTRLLaymenIcons";
    
    if (self.useElectricalIcons)
        iconType = @"CTRLElectricalIcons";
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *laymenIconFileNames = [infoDict objectForKey:iconType];
    
    NSMutableArray *icons = [NSMutableArray array];
    NSMutableArray *selectedIcons = [NSMutableArray array];
    
    for (NSString *fileName in laymenIconFileNames) {
        UIImage *image = [UIImage imageNamed:fileName];
        UIImage *selectedImage = [UIImage imageNamed:[fileName stringByAppendingString:@"Selected"]];
        
        if (image && selectedImage) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            [icons addObject:image];
            [selectedIcons addObject:selectedImage];
        }
    }
    
    self.fixtureIcons = icons;
    self.selectedFixtureIcons = selectedIcons;
}

- (void)iconChanged:(CTRLGridImagePicker *)imagePicker
{
    self.fixture.iconIndex = @(imagePicker.selectedIndex | (self.useElectricalIcons ? CTRLElectricalIconOffset : 0));
}

- (void)iconTypeChanged:(UISegmentedControl *)segmentedControl
{
    self.useElectricalIcons = (segmentedControl.selectedSegmentIndex == 1 ? YES : NO);
    [self loadIcons];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - CTRLGenericSelectionDelegate

- (void)genericSelectionController:(CTRLGenericSelectionListViewController *)controller didSelectObject:(id)object
{
    if ([object isMemberOfClass:[Breaker class]]) {
        Breaker *breaker = (Breaker *)object;
        self.fixture.breaker = breaker;
    }
    else if ([object isMemberOfClass:[Room class]]) {
        Room *room = (Room *)object;
        room.house = self.house;
        [self.house addRoomsObject:room];
        self.fixture.room = room;
    }
    
    [self.tableView reloadData];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *cleanedName = [self.fixture.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (self.fixture.breaker != nil && cleanedName.length != 0)
    {
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
