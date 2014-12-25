//
//  CTRLSettingsViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/28/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLSettingsViewController.h"
#import "CTRLDataStack.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface CTRLSettingsViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *useiCloudSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation CTRLSettingsViewController

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
    self.useiCloudSwitch.on = [CTRLDataStack sharedDataStack].useiCloud;

    [self.revealButtonItem setTarget:self.revealViewController];
    [self.revealButtonItem setAction:@selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self displayComposerSheetWithSubject:@"The Best App Ever"
                                             body:@"I've been cataloging all of the circuit breakers in my home with FuzeBox and I think it's just great. \n\n You should try it, too.\n\nDownload FuzeBox from the Apple App Store \n\nhttp://get.fuzeboxapp.com"
                                     toRecepients:nil];
        }
        else if (indexPath.row == 1) {
            [self displayComposerSheetWithSubject:@"Feedback"
                                             body:nil
                                     toRecepients:@[@"feedback@fuzeboxapp.com"]];
        }
    }
}

#pragma mark - IBActions

- (IBAction)iCloudSwitchChanged:(UISwitch *)sender {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidLoad:) name:USMStoreDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeWillLoad:) name:USMStoreWillChangeNotification object:nil];
    
    if ([CTRLDataStack sharedDataStack].cloudAvailable) {
        [[CTRLDataStack sharedDataStack] setUseiCloudAndReplace:sender.on];
    }
    else {
        UIAlertView *iCloudAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Please set up an iCloud account in the Settings App to use this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [iCloudAlert show];
        
        [sender setOn:NO animated:YES];
    }
}

#pragma mark - Notifications

- (void)storeWillLoad:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *progressHudText = nil;
        if ([CTRLDataStack sharedDataStack].useiCloud) {
            progressHudText = @"Turning On iCloud Sync...";
        }
        else {
            progressHudText = @"Turning Off iCloud Sync...";
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = progressHudText;
        self.navigationController.view.userInteractionEnabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    });
}

- (void)storeDidLoad:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.useiCloudSwitch.on = [[CTRLDataStack sharedDataStack] useiCloud];
    });
    
    //This prevents "flashing" of the alert if the store loads quickly
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationController.view.userInteractionEnabled = YES;
    });
}
#pragma mark - Mail

-(void)displayComposerSheetWithSubject:(NSString *)subject body:(NSString *)body toRecepients:(NSArray *)toRecipents
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composerVC = [[MFMailComposeViewController alloc] init];
        composerVC.mailComposeDelegate = self;
        composerVC.view.tintColor = self.view.tintColor;
        composerVC.subject = subject;
        [composerVC setToRecipients:toRecipents];
        [composerVC setMessageBody:body isHTML:NO];
        [self presentViewController:composerVC animated:YES completion:^{
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        }];
    }
    else {
        UIAlertView *mailAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Please set up an email account in the Settings App to use this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mailAlert show];
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }

}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
