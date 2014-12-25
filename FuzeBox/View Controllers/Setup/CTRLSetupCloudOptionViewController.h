//
//  CTRLCloudOptionsSetupViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLSetupCloudOptionViewController : UITableViewController

@property (nonatomic, strong) void(^setupCompletionBlock)();

@end
