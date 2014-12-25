//
//  UITableViewController+CoreDataiCloud.h
//  FuzeBox
//
//  Created by Hank Jacobs on 1/4/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (CoreDataiCloud)

- (void)enableDefaultiCloudStoreChangeHandling;
- (void)disableDefaultiCloudStoreChangeHandling;
- (void)showLoadingSpinner;

@end
