//
//  CTRLCloudOptionsSetupViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLSetupCloudOptionViewController.h"
#import "CTRLEditHouseViewController.h"
#import "CTRLDataStack.h"
#import "FuzeBoxConstants.h"
#import <MediaPlayer/MediaPlayer.h>
#import "House.h"
#import "UbiquityStoreManager.h"
#import "MBProgressHUD.h"

static NSString *const UseCloudSegue = @"UseiCloudSegue";
static NSString *const DontUseCloudSegue = @"DontUseiCloudSegue";

@interface CTRLSetupCloudOptionViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (nonatomic, strong) MPMoviePlayerController *movieController;
@property (nonatomic, strong) UIImageView *icloudFirstFrame;
@property (nonatomic, assign) BOOL awaitingStoreLoad;
@property (nonatomic, assign) BOOL useiCloud;
@property (nonatomic, assign) UITableViewCell *selectedCell;

@end

@implementation CTRLSetupCloudOptionViewController

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
    NSURL * resourcePath = [[NSBundle mainBundle] resourceURL];
    resourcePath = [NSURL URLWithString:@"icloudAnimation@2x.mov" relativeToURL:resourcePath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidLoad) name:USMStoreDidChangeNotification object:nil];

    
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:resourcePath];
    self.movieController.controlStyle = MPMovieControlStyleNone;
    self.movieController.shouldAutoplay = NO;
    [self.movieController prepareToPlay];
    self.movieController.view.frame = self.movieView.bounds;
    self.movieController.view.backgroundColor = [UIColor clearColor];
    self.movieController.backgroundView.frame = self.movieView.bounds;
    [self.movieController.backgroundView addSubview:[[UIImageView alloc] initWithImage:
                                                     [UIImage imageNamed:@"icloudAnimationFirstFrame"]]];
    self.movieController.backgroundView.backgroundColor = self.tableView.backgroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstFrameReady:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:self.movieController];
    
    self.icloudFirstFrame = [[UIImageView alloc] initWithImage:
                              [UIImage imageNamed:@"icloudAnimationFirstFrame"]];
    self.icloudFirstFrame.frame = self.movieController.backgroundView.bounds;
    
    [self.movieView addSubview:self.icloudFirstFrame];
    
    if (IS_FOUR_INCH_SCREEN) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.movieController play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.movieController setCurrentPlaybackTime:0.0];
    [self.movieController pause];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !self.awaitingStoreLoad;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    
    cell.accessoryView = activityIndicator;
    self.selectedCell = cell;
    
    BOOL shouldWait = NO;
    
    if (indexPath.row == 0) {
        
        if ([CTRLDataStack sharedDataStack].useiCloud == NO) {
            shouldWait = YES;
        }
        [CTRLDataStack sharedDataStack].useiCloud = YES;
    }
    else if (indexPath.row == 1) {
        if ([CTRLDataStack sharedDataStack].useiCloud == YES) {
            shouldWait = YES;
        }
        [CTRLDataStack sharedDataStack].useiCloud = NO;
    }

    if (shouldWait) {
        [self waitForiCloudTransition];
    }
    else {
        [self attemptPushEditHouse];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryView = nil;
}

#pragma mark - Navigation

- (IBAction)nextTapped:(UIBarButtonItem *)sender
{
    UIActionSheet *cloudActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:@"Don't Use iCloud"
                                                         otherButtonTitles: @"Use iCloud", nil];
    [cloudActionSheet showInView:self.view];
}

- (void)waitForiCloudTransition
{
    self.awaitingStoreLoad = YES;
}

- (void)attemptPushEditHouse
{
    if (![CTRLDataStack sharedDataStack].scratchContext) {
        
        if (!IS_FOUR_INCH_SCREEN) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Configuring...";
            
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        
        [self waitForiCloudTransition];
        return;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.selectedCell.accessoryView = nil;
    self.awaitingStoreLoad = NO;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLEditHouseViewController *destinationVC = (CTRLEditHouseViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editHouseViewController"];
    destinationVC.rightButtonTappedBlock = self.setupCompletionBlock;
    destinationVC.allowPanelCreation = YES;
    destinationVC.showMyHouseAlreadyExists = [CTRLDataStack sharedDataStack].useiCloud;
    
    NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
    [moc reset]; //clear out any previous houses that were created in the next vc and then user comes back to this vc
    
    destinationVC.house = [NSEntityDescription insertNewObjectForEntityForName:@"House" inManagedObjectContext:moc];
    destinationVC.house.name = @"My House";
    
    [self.navigationController pushViewController:destinationVC animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [CTRLDataStack sharedDataStack].useiCloud = NO;
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        if ([CTRLDataStack sharedDataStack].cloudAvailable) {
            [CTRLDataStack sharedDataStack].useiCloud = YES;
        }
        else {
            [CTRLDataStack sharedDataStack].useiCloud = NO;
            UIAlertView *iCloudAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Please set up an iCloud account in the Settings App to use this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [iCloudAlert show];
        }
    }
    else if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [self attemptPushEditHouse];
}

#pragma mark - MPMoviePlayerController

- (void)firstFrameReady:(NSNotification *)note
{
    if (self.movieController.readyForDisplay) {
        [self.movieView addSubview:self.movieController.view];
    }

}

#pragma mark - UbiquityStoreManager

- (void)storeDidLoad
{
    if (self.awaitingStoreLoad) {
        self.awaitingStoreLoad = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self attemptPushEditHouse];
        });
    }
}

@end
