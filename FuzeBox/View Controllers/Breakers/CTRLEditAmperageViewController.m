//
//  CTRLEditAmperageViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLEditAmperageViewController.h"

@interface CTRLEditAmperageViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation CTRLEditAmperageViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.amperage = [self amperageForIndexPath:indexPath];
    self.isDoublePole = [self isDoublePoleAtIndexPath:indexPath];
    
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CTRLEditAmperageDelegate)]) {
        [self.delegate amperageEditor:self didSelectAmperage:self.amperage isDoublePole:self.isDoublePole];
    }
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = [self rowIndexPathForAmperage:self.amperage isDoublePole:self.isDoublePole];
    
    if ([selectedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Table Data

- (NSNumber *)amperageForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    switch (row) {
        case 0:
            return @(15);
            break;
        case 1:
            return @(20);
            break;
        case 2:
            return @(30);
            break;
        case 3:
            return @(30);
            break;
        case 4:
            return @(40);
            break;
        case 5:
            return @(40);
            break;
        case 6:
            return @(50);
            break;
        case 7:
            return @(60);
            break;
        case 8:
            return @(70);
            break;
        case 9:
            return @(80);
            break;
        case 10:
            return @(100);
            break;
        case 11:
            return @(120);
            break;
        case 12:
            return @(140);
            break;
        case 13:
            return @(160);
            break;
        case 14:
            return @(180);
            break;
        case 15:
            return @(200);
            break;
        default:
            return @(15);
            break;
    }
    
}

- (BOOL)isDoublePoleAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == 3 || row == 5 || row >= 7) return YES;
    else return NO;
}

- (NSIndexPath *)rowIndexPathForAmperage:(NSNumber *)amperage isDoublePole:(BOOL)isDoublePole
{
    NSInteger row = 0;
    NSInteger amp = amperage.integerValue;
    
    switch (amp) {
        case 15:
            row = 0;
            break;
        case 20:
            row = 1;
            break;
        case 30:
            row = 2;
            break;
        case 40:
            row = 4;
            break;
        case 50:
            row = 6;
            break;
        case 60:
            row = 7;
            break;
        case 70:
            row = 8;
            break;
        case 80:
            row = 9;
            break;
        case 100:
            row = 10;
            break;
        case 120:
            row = 11;
            break;
        case 140:
            row = 12;
            break;
        case 160:
            row = 13;
            break;
        case 180:
            row = 14;
            break;
        case 200:
            row = 15;
            break;
        default:
            row = 0;
            break;
    }
    
    if (isDoublePole && (row == 2 || row == 4))
        row++;
    
    return [NSIndexPath indexPathForRow:row inSection:0];
}


@end
