//
//  CTRLEditAmperageViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTRLEditAmperageDelegate;
@interface CTRLEditAmperageViewController : UITableViewController

@property (nonatomic, strong) NSNumber *amperage;
@property (nonatomic, assign) BOOL isDoublePole;
@property (nonatomic, weak) id<CTRLEditAmperageDelegate> delegate;

@end

@protocol CTRLEditAmperageDelegate <NSObject>

- (void)amperageEditor:(CTRLEditAmperageViewController *)editor didSelectAmperage:(NSNumber *)amperage isDoublePole:(BOOL)isDoublePole;

@end
