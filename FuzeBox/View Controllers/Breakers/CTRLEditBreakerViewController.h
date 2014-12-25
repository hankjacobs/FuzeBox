//
//  CTRLEditBreakerViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Breaker.h"

@protocol CTRLEditBreakerDelegate;
@interface CTRLEditBreakerViewController : UITableViewController

@property (nonatomic, strong) Breaker *breaker;
@property (nonatomic, weak) id<CTRLEditBreakerDelegate> delegate;

@end

@protocol CTRLEditBreakerDelegate <NSObject>

- (void)editBreakerController:(CTRLEditBreakerViewController *)controller didSaveBreaker:(Breaker *)breaker;

@end