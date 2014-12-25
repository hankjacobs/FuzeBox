//
//  CTRLSwitch.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLSwitch : UIControl

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, assign, getter = isOn) BOOL on;

@end
