//
//  CTRLWelcomeViewController.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/22/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLWelcomeViewController : UIViewController

@property (nonatomic, strong) void(^setupCompletionBlock)();

@end
