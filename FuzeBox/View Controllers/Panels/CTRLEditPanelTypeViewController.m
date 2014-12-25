//
//  CTRLEditServicePanelTypeViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLEditPanelTypeViewController.h"
#import "FuzeBoxConstants.h"
#import "CTRLDataStack.h"
#import "Panel.h"
#import "Panel+Helpers.h"
#import "House.h"

@implementation CTRLEditPanelTypeViewController

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
    
    if (IS_FOUR_INCH_SCREEN) {
        self.tableView.scrollEnabled = NO;
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!IS_FOUR_INCH_SCREEN) {
        return [super tableView:tableView heightForHeaderInSection:section]/2;
    }
    else {
        return 12.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate conformsToProtocol:@protocol(CTRLEditServicePanelDelegate)]) {
        [self.delegate editServicePanelController:self didSelectPanelType:(PanelType)indexPath.row];
    }
}

@end
