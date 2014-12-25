//
//  CTRLBreakersViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/30/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLBreakersViewController.h"
#import "CTRLBreakerColumnViewController.h"
#import "UIColor+UIColorFromRGB.h"
#import "Panel.h"
#import "Panel+Helpers.h"

@interface CTRLBreakersViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *panelSideControl;
@property (weak, nonatomic) IBOutlet UIView *panelSideControlBackground;

@end

@implementation CTRLBreakersViewController

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
    self.title = self.panel.name;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.panelSideControl.tintColor = [UIColor colorWithR:76 g:217 b:100]; 
    self.panelSideControlBackground.layer.cornerRadius = 5.0;

    if (!self.panel.isDoubleRowPanel) {
        self.containerTopSpacingConstraint.constant = 0;
        self.panelSideControl.hidden = YES;
        self.panelSideControlBackground.hidden = YES;

    }
    else if (self.panel.panelType == PanelHorizontalDoubleRow) {
        [self.panelSideControl setTitle:@"Top" forSegmentAtIndex:0];
        [self.panelSideControl setTitle:@"Bottom" forSegmentAtIndex:1];
    }
    
    CTRLBreakerColumnViewController *breakerColumnViewController = [[CTRLBreakerColumnViewController alloc] initWithStyle:UITableViewStyleGrouped];
    breakerColumnViewController.panel = self.panel;
    
    if (self.panel.isDoubleRowPanel) {
        breakerColumnViewController.panelColumn = @(0);
    }
    
    breakerColumnViewController.view.frame = self.containerView.bounds;
    breakerColumnViewController.tableView.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
    
    [self addChildViewController:breakerColumnViewController];
    [self.containerView addSubview:breakerColumnViewController.view];
    [breakerColumnViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.childViewControllers.firstObject beginAppearanceTransition:YES animated:animated];
    
    if (self.isEditing) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.childViewControllers.firstObject endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.childViewControllers.firstObject beginAppearanceTransition:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.childViewControllers.firstObject endAppearanceTransition];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    CTRLBreakerColumnViewController *childViewController = [self.childViewControllers firstObject];
    [childViewController setEditing:editing animated:animated];
    [self.navigationItem setHidesBackButton:editing animated:(!editing && animated)];
    
    if (editing) {

        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped:)];
        [self.navigationItem setLeftBarButtonItem:addButtonItem animated:animated];
        
        [UIView animateWithDuration:(animated ? .3 : 0) animations:^{
            self.view.backgroundColor = [UIColor defaultEditingCollectionViewColor];
            self.navigationController.navigationBar.barTintColor = [UIColor defaultEditingNavigationBarColor];
            self.revealViewController.frontViewStatusBarBackgroundColor = self.navigationController.navigationBar.barTintColor;
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
        
    }
    else {
  
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
        
        [UIView animateWithDuration:(animated ? .3 : 0) animations:^{
            self.view.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
            self.navigationController.navigationBar.barTintColor = [UIColor defaultNavigationBarColor];
            self.revealViewController.frontViewStatusBarBackgroundColor = self.navigationController.navigationBar.barTintColor;
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction

- (IBAction)panelSideControlChanged:(UISegmentedControl *)sender
{
    CGRect toViewControllerOriginFrame = self.containerView.bounds;
    CGRect toViewControllerDestinationFrame = self.containerView.bounds;
    CGRect fromViewControllerDestinationFrame = self.containerView.bounds;
    
    if (sender.selectedSegmentIndex == 0) {
        toViewControllerOriginFrame = CGRectOffset(toViewControllerOriginFrame,
                                                   0-CGRectGetWidth(toViewControllerOriginFrame),
                                                   0);
        fromViewControllerDestinationFrame = CGRectOffset(fromViewControllerDestinationFrame,
                                                          CGRectGetWidth(fromViewControllerDestinationFrame),
                                                          0);
    }
    else {
        toViewControllerOriginFrame = CGRectOffset(toViewControllerOriginFrame,
                                                   CGRectGetWidth(toViewControllerOriginFrame),
                                                   0);
        fromViewControllerDestinationFrame = CGRectOffset(fromViewControllerDestinationFrame,
                                                          0-CGRectGetWidth(fromViewControllerDestinationFrame),
                                                          0);
    }

    
    CTRLBreakerColumnViewController *toViewController = [[CTRLBreakerColumnViewController alloc] initWithStyle:UITableViewStyleGrouped];
    toViewController.panel = self.panel;
    toViewController.panelColumn = @(sender.selectedSegmentIndex);
    toViewController.view.frame = toViewControllerOriginFrame;
    toViewController.tableView.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];

    CTRLBreakerColumnViewController *fromViewController = self.childViewControllers.firstObject;
    
    toViewController.editing = fromViewController.isEditing;
    
    [self addChildViewController:toViewController];
    [toViewController beginAppearanceTransition:YES animated:YES];
    [fromViewController beginAppearanceTransition:NO animated:YES];
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:.3
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                
                                toViewController.view.frame = toViewControllerDestinationFrame;
                                fromViewController.view.frame = fromViewControllerDestinationFrame;
                                
                            } completion:^(BOOL finished) {
                                [toViewController endAppearanceTransition];
                                [fromViewController endAppearanceTransition];
                                [fromViewController removeFromParentViewController];
                                
                            }];
    
}

#pragma mark - UIBarButtonItem Actions

- (void)addTapped:(UIBarButtonItem *)barButton
{
    CTRLBreakerColumnViewController *childViewController = self.childViewControllers.firstObject;
    if ([self.childViewControllers.firstObject respondsToSelector:@selector(addTapped:)]) {
        [childViewController addTapped:barButton];
    }
}


@end
