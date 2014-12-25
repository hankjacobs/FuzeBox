//
//  UITableViewController+CoreDataiCloud.m
//  FuzeBox
//
//  Created by Hank Jacobs on 1/4/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import "UITableViewController+CoreDataiCloud.h"

@implementation UITableViewController (CoreDataiCloud)

- (void)enableDefaultiCloudStoreChangeHandling
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFetchResults:) name:USMStoreWillChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchResults:) name:USMStoreDidChangeNotification object:nil];
}

- (void)disableDefaultiCloudStoreChangeHandling
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:USMStoreWillChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:USMStoreDidChangeNotification
                                                  object:nil];
}

- (void)resetFetchResults:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self showLoadingSpinner];
        [self.tableView reloadData];
    });
}

- (void)reloadFetchResults:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        self.tableView.backgroundView = nil;
        [self.tableView reloadData];
    });
}

- (void)showLoadingSpinner
{
    UIView *loadingView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = loadingView.center;
    [activityIndicatorView startAnimating];
    
    [loadingView addSubview:activityIndicatorView];
    self.tableView.backgroundView = loadingView;
}

@end
