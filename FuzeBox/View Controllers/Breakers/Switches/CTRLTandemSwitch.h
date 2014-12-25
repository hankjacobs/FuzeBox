//
//  CTRLDoublePoleSwitch.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/30/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLTandemSwitch : UIControl

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, assign, getter = isOn) BOOL on;

@end
