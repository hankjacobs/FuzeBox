//
//  CTRLSeededGenericSelectionListViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLSeededRoomSelectionListViewController.h"
#import "CTRLPropertyEditorViewController.h"

@interface CTRLSeededRoomSelectionListViewController ()

@property (nonatomic, readwrite) NSString *sectionNameKeypath;
@property (nonatomic, strong) CTRLPropertyEditorViewController *propertyEditorViewController;

@end

@implementation CTRLSeededRoomSelectionListViewController

- (void)viewDidLoad
{
    self.seededCellTitles = [self.seededCellTitles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    self.sectionNameKeypath = nil;
    
    if (!self.displayKeyPath)
        self.displayKeyPath = @"name";
    
    //Prune duplicates
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:self.fetchRequest.entityName
                                              inManagedObjectContext:self.moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entityDescription;
    
    NSMutableString *predicateFormat = [NSMutableString string];
    
    for (NSString *seededString in self.seededCellTitles) {
        [predicateFormat appendFormat:@"(%@ LIKE[c] '%@')", self.displayKeyPath, seededString];
        
        if (seededString != [self.seededCellTitles lastObject]) {
            [predicateFormat appendFormat:@" OR "];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *duplicates = [self.moc executeFetchRequest:request error:&error];
    duplicates = [duplicates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"house = %@", self.house]];
    
    NSMutableArray *prunedSeeds = [self.seededCellTitles mutableCopy];
    
    for (id obj in duplicates) {
        NSString *existingSeedTitle = [obj valueForKey:self.displayKeyPath];
        
        NSInteger existingIndex = NSNotFound;
        for (NSString *seedString in prunedSeeds) {
            if ([existingSeedTitle isEqualToString:seedString]) {
                existingIndex = [prunedSeeds indexOfObject:seedString];
            }
        }
        
        if (existingIndex != NSNotFound) {
            [prunedSeeds removeObjectAtIndex:existingIndex];
        }
    }
    
    self.seededCellTitles = [prunedSeeds copy];
    
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [super tableView:tableView numberOfRowsInSection:section] + self.seededCellTitles.count + 1;
    }
    else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row >= [self.fetchedResultsController.sections[indexPath.section] numberOfObjects]) {
        NSInteger existingCount = [self.fetchedResultsController.sections[indexPath.section] numberOfObjects];
        NSInteger seededIndex = indexPath.row - existingCount;
        
        if (seededIndex == self.seededCellTitles.count) {
            cell.textLabel.text = @"Custom";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            
            cell.textLabel.text = self.seededCellTitles[seededIndex];
            
            if ([cell.textLabel.text isEqualToString:self.selectedCellTitle]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    else {
        [super configureCell:cell atIndexPath:indexPath];
        
        if ([cell.textLabel.text isEqualToString:self.selectedCellTitle]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.fetchedResultsController.sections[indexPath.section] numberOfObjects]) {
        NSInteger existingCount = [self.fetchedResultsController.sections[indexPath.section] numberOfObjects];
        NSInteger seededIndex = indexPath.row - existingCount;
        
        if (seededIndex == self.seededCellTitles.count) {
            self.propertyEditorViewController = [CTRLPropertyEditorViewController propertyEditorFromStoryboard];
            self.propertyEditorViewController.propertyKey = self.displayKeyPath;
            self.propertyEditorViewController.value = @"";
            self.propertyEditorViewController.keyboardType = UIKeyboardTypeDefault;
            self.propertyEditorViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(customTitleCreated:)];
            self.propertyEditorViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(customTitleCancelled:)];
            self.propertyEditorViewController.title = @"Room Name";
            [self.navigationController pushViewController:self.propertyEditorViewController animated:YES];
        }
        else {
            id object = [NSEntityDescription insertNewObjectForEntityForName:self.fetchRequest.entityName
                                                             inManagedObjectContext:self.moc];
            [object setValue:self.seededCellTitles[seededIndex] forKey:self.displayKeyPath];
            self.selectedCellTitle = self.seededCellTitles[seededIndex];
            [self.tableView reloadData];
            
            if ([self.delegate conformsToProtocol:@protocol(CTRLGenericSelectionDelegate)]) {
                [self.delegate genericSelectionController:self
                                          didSelectObject:object];
            }
        }
    }
    else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Actions

- (void)customTitleCreated:(UIBarButtonItem *)barButtonItem;
{
    NSString *value = self.propertyEditorViewController.valueTextField.text;
    if (![[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        id object = [NSEntityDescription insertNewObjectForEntityForName:self.fetchRequest.entityName
                                                  inManagedObjectContext:self.moc];
        [object setValue:value forKey:self.displayKeyPath];
        
        if ([self.delegate conformsToProtocol:@protocol(CTRLGenericSelectionDelegate)]) {
            [self.delegate genericSelectionController:self
                                      didSelectObject:object];
        }
    }
}

- (void)customTitleCancelled:(UIBarButtonItem *)barButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
