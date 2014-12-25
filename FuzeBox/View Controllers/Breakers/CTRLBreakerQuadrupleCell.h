//
//  CTRLBreakerQuadrupleCell.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/31/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTRLSwitch;
@protocol CTRLBreakerCellDelegate;
@interface CTRLBreakerQuadrupleCell : UITableViewCell

@property (nonatomic, strong) UIColor *breakerAccentColor;
@property (nonatomic, strong) NSString *nameText;
@property (nonatomic, strong) NSString *badgeText;
@property (nonatomic, strong) NSString *amperageText;
@property (nonatomic, assign) BOOL isPunchout;
@property (nonatomic, assign) BOOL showGFCI;
@property (nonatomic, readonly) CTRLSwitch *breakerSwitch;
@property (nonatomic, weak) id<CTRLBreakerCellDelegate> delegate;

- (void)showBadge:(BOOL)animated;
- (void)hideBadge:(BOOL)animated;


@end
