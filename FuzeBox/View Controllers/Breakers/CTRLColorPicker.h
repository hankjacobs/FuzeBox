//
//  CTRLColorPicker.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLColorPicker : UIControl

@property (nonatomic, readonly) NSArray *colors;
@property (nonatomic, assign) NSInteger selectedColorIndex;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors;

@end
