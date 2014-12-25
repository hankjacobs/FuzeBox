//
//  CTRLAppDelegate.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/12/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//
#import "CTRLAppDelegate.h"
#import "CTRLDataStack.h"
#import "FuzeBoxConstants.h"
#import "UIColor+UIColorFromRGB.h"
#import "SWRevealViewController.h"
#import "CTRLPanelsViewController.h"
#import "CTRLMenuDrawerViewController.h"
#import "CTRLDrawerNavigationBar.h"
#import "CTRLWelcomeViewController.h"
#import "CTRLSettingsViewController.h"
#import "UbiquityStoreManager.h"

@interface CTRLAppDelegate ()

@property (nonatomic, strong) UIViewController *loadingViewController;

@end

@implementation CTRLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = [UIColor colorWithR:76 g:217 b:100];
    
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] init];
    revealViewController.rearViewRevealOverdraw = 0.0;
    revealViewController.frontViewShadowRadius = 10.0f;
    
    self.window.rootViewController = revealViewController;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:InitialLaunchOccurredKey]) {
        [self configureViewControllersForDrawerViewController:revealViewController];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:InitialLaunchOccurredKey])
    {
        [self showFirstTimeFlow];
    }
    else {
//        [[CTRLDataStack sharedDataStack] destroyEverything];
//        [self showFirstTimeFlow];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - First Time Flow

- (void)showFirstTimeFlow
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *firstTimeLaunchController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"firsTimeLaunchFlow"];
    CTRLWelcomeViewController *welcomeVC = (CTRLWelcomeViewController *)firstTimeLaunchController.viewControllers.firstObject;
    
    welcomeVC.setupCompletionBlock = ^(){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:InitialLaunchOccurredKey];
        [[NSUserDefaults standardUserDefaults]  synchronize];
        [self configureViewControllersForDrawerViewController:(SWRevealViewController *)self.window.rootViewController];
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self.window.rootViewController presentViewController:firstTimeLaunchController animated:NO completion:nil];
}

#pragma mark - Existing Flow

- (void)configureViewControllersForDrawerViewController:(SWRevealViewController *)viewController
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeWillChange) name:USMStoreWillChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange) name:USMStoreDidChangeNotification object:nil];
    
    if (![[CTRLDataStack sharedDataStack] mainContext]) {
        [self showLoadingViewControllerIfNecessary];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLPanelsViewController *panelsVC = (CTRLPanelsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"panelsViewController"];
    UINavigationController *panelsNav = [[UINavigationController alloc] initWithRootViewController:panelsVC];
    
    CTRLMenuDrawerViewController *menuDrawerViewController = [[CTRLMenuDrawerViewController alloc] initWithStyle:UITableViewStyleGrouped];

    UINavigationController *menuNav = [[UINavigationController alloc] initWithNavigationBarClass:[CTRLDrawerNavigationBar class] toolbarClass:nil];
    menuNav.viewControllers = @[menuDrawerViewController];

    viewController.frontViewStatusBarBackgroundColor = [UIColor whiteColor];
    viewController.frontViewController = panelsNav;
    viewController.rearViewController = menuNav;
    
    NSManagedObjectContext *moc = [CTRLDataStack sharedDataStack].mainContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"House"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error;
    House *activeHouse = [[moc executeFetchRequest:fetchRequest error:&error] firstObject];
    
    panelsVC.house = activeHouse;
    menuDrawerViewController.activeHouse = activeHouse;
    [menuDrawerViewController expandHouse:activeHouse animated:NO];
    
}

#pragma Core Data Store Loading

- (void)showLoadingViewControllerIfNecessary
{
    
    SWRevealViewController *activeContainerController = (SWRevealViewController *)self.window.rootViewController;
    UIViewController *activeFrontViewController = [[(UINavigationController *)activeContainerController.frontViewController childViewControllers] firstObject];
    
    if (activeFrontViewController != self.loadingViewController && ![activeFrontViewController isKindOfClass:[CTRLSettingsViewController class]]) {
        UINavigationController *loadingNav = [[UINavigationController alloc] initWithRootViewController:self.loadingViewController];
        loadingNav.navigationBar.translucent = NO;
        activeContainerController.frontViewController = loadingNav;
        activeContainerController.frontViewStatusBarBackgroundColor = [UIColor whiteColor];
    }
}

- (UIViewController *)loadingViewController
{
    if (!_loadingViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.loadingViewController = [storyboard instantiateViewControllerWithIdentifier:@"loadingViewController"];
    }
    
    return _loadingViewController;
}

- (void)storeWillChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadingViewControllerIfNecessary];
    });
}

- (void)storeDidChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SWRevealViewController *activeContainerController = (SWRevealViewController *)self.window.rootViewController;
        UIViewController *activeFrontViewController = [[(UINavigationController *)activeContainerController.frontViewController childViewControllers] firstObject];
        
        if (![activeFrontViewController isKindOfClass:[CTRLSettingsViewController class]]) {
            [self configureViewControllersForDrawerViewController:(SWRevealViewController *)self.window.rootViewController];
        }
    });
    
}

@end
