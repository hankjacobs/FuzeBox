//
//  CTRLHouseInitialSetupViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLEditHouseViewController.h"
#import "CTRLEditPanelTypeViewController.h"
#import "MBProgressHUD.h"
#import "FuzeBoxConstants.h"
#import "CTRLDataStack.h"
#import "House.h"

@interface CTRLEditHouseViewController ()<CTRLEditServicePanelDelegate, UITextFieldDelegate>
@property (weak, nonatomic) UITextField *houseNameTextField;
@property (nonatomic, strong) MBProgressHUD *tyingLooseEndsHUD;
@end

@implementation CTRLEditHouseViewController

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
    
    if ([[self.house.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.houseNameTextField.text = self.house.name;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeWillLoad) name:USMStoreWillChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidLoad) name:USMStoreDidChangeNotification object:nil];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.houseNameTextField resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showMyHouseAlreadyExists) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 44.0;
    }
    else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CTRLHouseNameCell = @"HouseNameCell";
    static NSString *const CTRLHouseAlreadyExistsCell = @"AlreadyExistsCell";
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CTRLHouseNameCell forIndexPath:indexPath];
        self.houseNameTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.houseNameTextField.text = self.house.name;
        self.houseNameTextField.delegate = self;
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CTRLHouseAlreadyExistsCell forIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        self.houseNameTextField.text = self.house.name;
        [self.houseNameTextField becomeFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (self.rightButtonTappedBlock) {
            self.rightButtonTappedBlock();
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    newText = [newText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (newText.length > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
       self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return YES;
}

#pragma mark - Navigation

- (IBAction)rightButtonTapped
{
    
    self.house.name = self.houseNameTextField.text;
    
    if (self.allowPanelCreation)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CTRLEditPanelTypeViewController *panelTypeVC = (CTRLEditPanelTypeViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editPanelTypeViewController"];
        panelTypeVC.delegate = self;
        
        [self.navigationController pushViewController:panelTypeVC animated:YES];
    }
    else {
        
        [self.house.managedObjectContext performBlockAndWait:^{
            NSError *error;
            [self.house.managedObjectContext save:&error];
        }];
        
        if (self.rightButtonTappedBlock) {
            self.rightButtonTappedBlock();
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)resetAndDismiss
{
    [self.house.managedObjectContext reset];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)editServicePanelController:(CTRLEditPanelTypeViewController *)editServicePanelController
                didSelectPanelType:(PanelType)panelType
{
    Panel *mainPanel = [NSEntityDescription insertNewObjectForEntityForName:@"Panel" inManagedObjectContext:self.house.managedObjectContext];
    
    mainPanel.name = @"Main Panel";
    mainPanel.panelType = panelType;
    mainPanel.house = self.house;
    mainPanel.index = 0;

    [mainPanel.managedObjectContext performBlockAndWait:^{
        NSError *error;
        [mainPanel.managedObjectContext save:&error];
    }];
    
    if (self.rightButtonTappedBlock) {
        self.rightButtonTappedBlock();
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UbiquityStoreManager notifications

- (void)storeWillLoad
{
    
    [self.house.managedObjectContext performBlockAndWait:^{
        [self.house.managedObjectContext reset];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Tying up some loose ends...";

        self.navigationController.view.userInteractionEnabled = NO;
        [self.houseNameTextField resignFirstResponder];
    });
    
}

- (void)storeDidLoad
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationController.view.userInteractionEnabled = YES;
        
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        [self.houseNameTextField becomeFirstResponder];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.house = [NSEntityDescription insertNewObjectForEntityForName:@"House" inManagedObjectContext:[CTRLDataStack sharedDataStack].scratchContext];
        self.house.name = self.houseNameTextField.text;
    });

}

@end
