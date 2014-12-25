//
//  CTRLEditPanelViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLEditPanelViewController.h"
#import "CTRLEditPanelTypeViewController.h"
#import "CTRLPropertyEditorViewController.h"
#import "Panel.h"
#import "Panel+Helpers.h"

@interface CTRLEditPanelViewController ()<CTRLEditPropertyDelegate, CTRLEditServicePanelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *panelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *panelTypeLabel;

@end

@implementation CTRLEditPanelViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.panelNameLabel.text = self.panel.name;
    self.panelTypeLabel.text = [self.panel friendlyNameForPanelType];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

- (void)cancelTapped:(UIBarButtonItem *)barButtonItem
{
    [self.panel.managedObjectContext reset];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneTapped:(UIBarButtonItem *)barButtonItem
{
    [self.panel.managedObjectContext performBlock:^{
        NSError *error;
        [self.panel.managedObjectContext save:&error];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"panelNameSegue"])
    {
        CTRLPropertyEditorViewController *propertyEditorViewController = segue.destinationViewController;
        propertyEditorViewController.delegate = self;
        propertyEditorViewController.propertyKey = @"name";
        propertyEditorViewController.value = self.panel.name;
        propertyEditorViewController.keyboardType = UIKeyboardTypeDefault;
    }
    else if ([segue.identifier isEqualToString:@"panelTypeSegue"]) {
        CTRLEditPanelTypeViewController *editPanelTypeViewController = segue.destinationViewController;
        editPanelTypeViewController.delegate = self;
    }
}

#pragma mark - CTRLEditPropertyDelegate

- (void)propertyEditor:(CTRLPropertyEditorViewController *)propertyEditor didRegisterChangeForPropertyKey:(NSString *)propertyKey withValue:(NSString *)value
{
    [self.panel setValue:value forKey:propertyKey];
    self.panelNameLabel.text = value;
    
    if (![[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - CTRLEditPanelTypeDelegate

- (void)editServicePanelController:(CTRLEditPanelTypeViewController *)editServicePanelController didSelectPanelType:(PanelType)panelType
{
    self.panel.panelType = panelType;
    self.panelTypeLabel.text = [self.panel friendlyNameForPanelType];
    
    [self.navigationController popToViewController:self animated:YES];
}


@end
