//
//  CTRLMenuTableViewCell.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/26/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTRLMenuTableViewCell : UITableViewCell

@property (strong, readonly)  UILabel *menuTextLabel;
@property (strong, readonly) UIImageView *menuImageView;
@property (nonatomic, assign) CGFloat indentationWidth;
@property (nonatomic, assign) NSInteger indentationLevel;

@end
