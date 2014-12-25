//
//  CTRLBreakerViewCell.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FuzeBoxConstants.h"
#import "CTRLSwitch.h"

typedef NS_ENUM(NSInteger, CTRLBreakerCellStyle) {
        CTRLBreakerCellStyleVertical,
        CTRLBreakerCellStyleHorizontal
};

@class CTRLSwitch;
@protocol CTRLBreakerViewCellDelegate;
@interface CTRLBreakerViewCell : UITableViewCell
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) UILabel *amperageLabel;
@property (nonatomic, readonly) UILabel *fixtureBadge;
@property (nonatomic, strong) CTRLSwitch *flipSwitch;
@property (nonatomic, assign, getter = isDoublePole) BOOL doublePole;
@property (nonatomic, assign, getter = isTandem) BOOL tandem;
@property (nonatomic, assign, getter = isGFCI) BOOL gfci;
@property (nonatomic, assign) SwitchOrientation switchOrientation;
@property (nonatomic, assign) CTRLBreakerCellStyle cellStyle;
@property (nonatomic, weak) id<CTRLBreakerViewCellDelegate> delegate;
@property (nonatomic, assign, getter = isDoubleCell) BOOL doubleCell;


@end


@protocol CTRLBreakerViewCellDelegate <NSObject>

- (void)breakerViewCell:(CTRLBreakerViewCell *)cell didDetectSwitchChangeButtonTap:(CTRLSwitch *)flipSwitch;
- (void)breakerViewCellDeleteButtonWasTapped:(CTRLBreakerViewCell *)cell;

@end