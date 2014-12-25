//
//  CTRLBreakerQuadrupleCell.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/31/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLBreakerQuadrupleCell.h"
#import "CTRLDoublePoleSwitch.h"
#import "CTRLSwitch.h"
#import "UIColor+UIColorFromRGB.h"
#import "CTRLBreakerCell.h"

@interface CTRLBreakerQuadrupleCell ()

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UIView *switchContainer;
@property (weak, nonatomic) IBOutlet UIView *onOffSwitchContainer;
@property (weak, nonatomic) IBOutlet UIImageView *gfciTopImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameTopLabel;
@property (weak, nonatomic) IBOutlet UIView *amperageTopContainer;
@property (weak, nonatomic) IBOutlet UIImageView *gfciBottomImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameBottomLabel;
@property (weak, nonatomic) IBOutlet UIView *amperageBottomContainer;


#pragma mark Configuration
@property (nonatomic, assign, getter = isRightSidedCell) BOOL rightSidedCell;
@property (nonatomic, assign) BOOL previousShowGFCI;

#pragma mark Custom Views
@property (nonatomic, strong) UILabel *onLabelTop;
@property (nonatomic, strong) UILabel *offLabelTop;
@property (nonatomic, strong) UILabel *onLabelBottom;
@property (nonatomic, strong) UILabel *offLabelBottom;
@property (nonatomic, strong) UILabel *amperageLabelTop;
@property (nonatomic, strong) UILabel *amperageLabelBottom;
@property (nonatomic, strong) UILabel *badgeLabelTop;
@property (nonatomic, strong) UILabel *badgeLabelBottom;
@property (nonatomic, readwrite) CTRLSwitch *breakerSwitch;

@end

@implementation CTRLBreakerQuadrupleCell

- (void)awakeFromNib
{
    [self setupCustomViews];
}

- (void)setupCustomViews
{
    self.onLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 34, 10)];
    self.offLabelTop = [[UILabel alloc] initWithFrame:self.onLabelTop.frame];
    self.onLabelBottom = [[UILabel alloc] initWithFrame:self.onLabelTop.frame];
    self.offLabelBottom = [[UILabel alloc] initWithFrame:self.onLabelTop.frame];
    self.amperageLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 31, 18)];
    self.amperageLabelBottom = [[UILabel alloc] initWithFrame:self.amperageLabelTop.frame];
    self.badgeLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.badgeLabelBottom = [[UILabel alloc] initWithFrame:self.badgeLabelTop.frame];
    
    self.offLabelTop.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.onLabelTop.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.onLabelBottom.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.offLabelBottom.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    self.amperageLabelTop.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.amperageLabelBottom.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    CGRect zerodOriginOnOffFrame = CGRectMake(0,
                                              0,
                                              CGRectGetWidth(self.onLabelTop.frame),
                                              CGRectGetHeight(self.onLabelTop.frame));
    self.offLabelTop.frame = zerodOriginOnOffFrame;
    self.onLabelTop.frame = zerodOriginOnOffFrame;
    self.offLabelBottom.frame = zerodOriginOnOffFrame;
    self.onLabelBottom.frame = zerodOriginOnOffFrame;
    
    CGRect zerodOriginAmperageFrame = CGRectMake(0,
                                                 0,
                                                 CGRectGetWidth(self.amperageLabelTop.frame),
                                                 CGRectGetHeight(self.amperageLabelTop.frame));
    self.amperageLabelTop.frame = zerodOriginAmperageFrame;
    self.amperageLabelBottom.frame = zerodOriginAmperageFrame;
    
    self.breakerSwitch = (CTRLSwitch *)[[CTRLDoublePoleSwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 120)];

    
    CGRect rightOnOffLabelTopFrame = CGRectOffset(self.onLabelTop.frame,
                                               CGRectGetMaxX(self.switchContainer.frame)+3,
                                               CGRectGetMinY(self.switchContainer.frame));
    CGRect leftOnOffLabelTopFrame = CGRectOffset(self.onLabelTop.frame,
                                              CGRectGetMinX(self.switchContainer.frame)-CGRectGetWidth(self.onLabelTop.frame)-3,
                                              CGRectGetMinY(self.switchContainer.frame));
    CGRect rightOnOffLabelBottomFrame = CGRectOffset(self.onLabelBottom.frame,
                                                  CGRectGetMaxX(self.switchContainer.frame)+3,
                                                  CGRectGetMaxY(self.switchContainer.frame)-CGRectGetHeight(self.onLabelBottom.frame)-2);
    CGRect leftOnOffLabelBottomFrame = CGRectOffset(self.onLabelBottom.frame,
                                                 CGRectGetMinX(self.switchContainer.frame)-CGRectGetWidth(self.onLabelBottom.frame)-3,
                                                 CGRectGetMaxY(self.switchContainer.frame)-CGRectGetHeight(self.onLabelBottom.frame)-2);
    if (self.rightSidedCell) {
        self.onLabelTop.frame = rightOnOffLabelTopFrame;
        self.offLabelTop.frame = leftOnOffLabelTopFrame;
        self.onLabelBottom.frame = rightOnOffLabelBottomFrame;
        self.offLabelBottom.frame = leftOnOffLabelBottomFrame;
        self.badgeLabelTop.frame = CGRectOffset(self.badgeLabelTop.frame, 2, CGRectGetHeight(self.nameTopLabel.bounds)/2-CGRectGetHeight(self.badgeLabelTop.frame)/2);
        self.badgeLabelBottom.frame = CGRectOffset(self.badgeLabelBottom.frame, 2, CGRectGetHeight(self.nameBottomLabel.bounds)/2-CGRectGetHeight(self.badgeLabelBottom.frame)/2);
    }
    else {
        self.onLabelTop.frame = leftOnOffLabelTopFrame;
        self.offLabelTop.frame = rightOnOffLabelTopFrame;
        self.onLabelBottom.frame = leftOnOffLabelBottomFrame;
        self.offLabelBottom.frame = rightOnOffLabelBottomFrame;
        
        self.badgeLabelTop.frame = CGRectOffset(self.badgeLabelTop.frame,
                                             CGRectGetMaxX(self.nameTopLabel.bounds)-CGRectGetWidth(self.badgeLabelTop.frame)-2,
                                             CGRectGetHeight(self.nameTopLabel.bounds)/2-CGRectGetHeight(self.badgeLabelTop.frame)/2);
        self.badgeLabelBottom.frame = CGRectOffset(self.badgeLabelBottom.frame,
                                                CGRectGetMaxX(self.nameBottomLabel.bounds)-CGRectGetWidth(self.badgeLabelBottom.frame)-2,
                                                CGRectGetHeight(self.nameBottomLabel.bounds)/2-CGRectGetHeight(self.badgeLabelBottom.frame)/2);
        
        self.breakerSwitch.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    self.breakerSwitch.frame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(self.breakerSwitch.frame),
                                          CGRectGetHeight(self.breakerSwitch.frame));
    
    self.offLabelTop.font = [UIFont boldSystemFontOfSize:8];
    self.onLabelTop.font = [UIFont boldSystemFontOfSize:8];
    self.amperageLabelTop.font = [UIFont boldSystemFontOfSize:10];
    self.offLabelBottom.font = [UIFont boldSystemFontOfSize:8];
    self.onLabelBottom.font = [UIFont boldSystemFontOfSize:8];
    self.amperageLabelBottom.font = [UIFont boldSystemFontOfSize:10];
    
    self.nameTopLabel.backgroundColor = [UIColor whiteColor];
    self.amperageLabelTop.backgroundColor = [UIColor colorWithR:235 g:235 b:235];
    self.nameBottomLabel.backgroundColor = [UIColor whiteColor];
    self.amperageLabelBottom.backgroundColor = [UIColor colorWithR:235 g:235 b:235];
    
    UIColor *textColor = [UIColor colorWithR:169 g:169 b:169];
    self.onLabelTop.textColor = textColor;
    self.offLabelTop.textColor = textColor;
    self.nameTopLabel.textColor = textColor;
    self.badgeLabelTop.textColor = [UIColor whiteColor];
    self.onLabelBottom.textColor = textColor;
    self.offLabelBottom.textColor = textColor;
    self.nameBottomLabel.textColor = textColor;
    self.badgeLabelBottom.textColor = [UIColor whiteColor];
    
    CGColorRef borderColor = [textColor CGColor];
    CGFloat borderWidth = 1.0;
    CGFloat borderRadius = 2.5;
    
    self.nameTopLabel.layer.borderColor = borderColor;
    self.nameTopLabel.layer.borderWidth = borderWidth;
    self.nameTopLabel.layer.cornerRadius = borderRadius;
    self.nameBottomLabel.layer.borderColor = borderColor;
    self.nameBottomLabel.layer.borderWidth = borderWidth;
    self.nameBottomLabel.layer.cornerRadius = borderRadius;
    
    self.amperageLabelTop.layer.borderColor = borderColor;
    self.amperageLabelTop.layer.borderWidth = borderWidth;
    self.amperageLabelTop.layer.cornerRadius = borderRadius;
    self.amperageLabelBottom.layer.borderColor = borderColor;
    self.amperageLabelBottom.layer.borderWidth = borderWidth;
    self.amperageLabelBottom.layer.cornerRadius = borderRadius;
    
    self.badgeLabelTop.layer.cornerRadius = CGRectGetWidth(self.badgeLabelTop.frame)/2;
    self.badgeLabelBottom.layer.cornerRadius = CGRectGetWidth(self.badgeLabelTop.frame)/2;
    
    self.offLabelTop.textAlignment = NSTextAlignmentCenter;
    self.onLabelTop.textAlignment = NSTextAlignmentCenter;
    self.amperageLabelTop.textAlignment = NSTextAlignmentCenter;
    self.badgeLabelTop.textAlignment = NSTextAlignmentCenter;
    self.offLabelBottom.textAlignment = NSTextAlignmentCenter;
    self.onLabelBottom.textAlignment = NSTextAlignmentCenter;
    self.amperageLabelBottom.textAlignment = NSTextAlignmentCenter;
    self.badgeLabelBottom.textAlignment = NSTextAlignmentCenter;
    
    self.badgeLabelTop.hidden = YES;
    self.badgeLabelBottom.hidden = YES;
    self.gfciTopImageView.hidden = self.showGFCI;
    self.gfciBottomImageView.hidden = self.showGFCI;
    
    self.onLabelTop.text = @"ON";
    self.offLabelTop.text = @"OFF";
    self.onLabelBottom.text = @"ON";
    self.offLabelBottom.text = @"OFF";
    
    [self.breakerSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.onOffSwitchContainer addSubview:self.onLabelTop];
    [self.onOffSwitchContainer addSubview:self.offLabelTop];
    [self.switchContainer addSubview:self.breakerSwitch];
    [self.onOffSwitchContainer addSubview:self.onLabelBottom];
    [self.onOffSwitchContainer addSubview:self.offLabelBottom];
    [self.amperageTopContainer addSubview:self.amperageLabelTop];
    [self.amperageBottomContainer addSubview:self.amperageLabelBottom];
    [self.nameTopLabel addSubview:self.badgeLabelTop];
    [self.nameBottomLabel addSubview:self.badgeLabelBottom];
}

#pragma mark - Setters

- (void)setBreakerAccentColor:(UIColor *)breakerAccentColor
{
    [self willChangeValueForKey:@"breakerAccentColor"];
    _breakerAccentColor = breakerAccentColor;
    [self didChangeValueForKey:@"breakerAccentColor"];
    
    self.amperageLabelTop.textColor = breakerAccentColor;
    self.amperageLabelBottom.textColor = breakerAccentColor;
    self.breakerSwitch.onTintColor = breakerAccentColor;
    self.breakerSwitch.tintColor = breakerAccentColor;
    self.badgeLabelTop.backgroundColor = breakerAccentColor;
    self.badgeLabelBottom.backgroundColor = breakerAccentColor;
}

- (void)setPunchout:(BOOL)punchout
{
    if (punchout) {
        self.onOffSwitchContainer.hidden = YES;
        self.amperageTopContainer.hidden = YES;
        self.nameTopLabel.hidden = YES;
        self.amperageBottomContainer.hidden = YES;
        self.nameBottomLabel.hidden = YES;
        
        self.previousShowGFCI = self.showGFCI;
        self.gfciTopImageView.hidden = YES;
        self.gfciBottomImageView.hidden = YES;
    }
    else {
        self.onOffSwitchContainer.hidden = NO;
        self.amperageTopContainer.hidden = NO;
        self.nameTopLabel.hidden = NO;
        self.amperageBottomContainer.hidden = NO;
        self.nameBottomLabel.hidden = NO;
        self.gfciTopImageView.hidden = !self.previousShowGFCI;
        self.gfciBottomImageView.hidden = !self.previousShowGFCI;
    }
}

- (void)setNameText:(NSString *)nameText
{
    [self willChangeValueForKey:@"nameText"];
    _nameText = nameText;
    [self didChangeValueForKey:@"nameText"];
    
    self.nameTopLabel.text = nameText;
    self.nameBottomLabel.text = nameText;
}

- (void)setBadgeText:(NSString *)badgeText
{
    [self willChangeValueForKey:@"badgeText"];
    _badgeText = badgeText;
    [self didChangeValueForKey:@"badgeText"];
    
    self.badgeLabelTop.text = badgeText;
    self.badgeLabelBottom.text = badgeText;
}

- (void)setAmperageText:(NSString *)amperageText
{
    [self willChangeValueForKey:@"amperageText"];
    _amperageText = amperageText;
    [self didChangeValueForKey:@"amperageText"];
    
    self.amperageLabelTop.text = amperageText;
    self.amperageLabelBottom.text = amperageText;
}

- (void)setShowGFCI:(BOOL)showGFCI
{
    [self willChangeValueForKey:@"showGFCI"];
    _showGFCI = showGFCI;
    [self didChangeValueForKey:@"showGFCI"];
    
    self.gfciTopImageView.hidden = !showGFCI;
    self.gfciBottomImageView.hidden = !showGFCI;
    
    self.previousShowGFCI = showGFCI;

}

- (void)showBadge:(BOOL)animated
{
    if (!self.badgeLabelTop.hidden && !self.badgeLabelBottom.hidden)
        return;
    
    CGRect finishTopFrame = self.badgeLabelTop.frame;
    CGRect startTopFrame = CGRectOffset(self.badgeLabelTop.frame, 0-CGRectGetMaxX(self.badgeLabelTop.frame),0);
    CGRect finishBottomFrame = self.badgeLabelBottom.frame;
    CGRect startBottomFrame = CGRectOffset(self.badgeLabelBottom.frame,
                                           0-CGRectGetMaxX(self.badgeLabelBottom.frame),
                                           0);
    
    if (!self.rightSidedCell) {
        startTopFrame = CGRectOffset(self.badgeLabelTop.frame, CGRectGetMaxX(self.nameTopLabel.bounds),0);
        startBottomFrame = CGRectOffset(self.badgeLabelBottom.frame, CGRectGetMaxX(self.nameBottomLabel.bounds),0);
    }
    
    self.badgeLabelTop.frame = startTopFrame;
    self.badgeLabelBottom.frame = startBottomFrame;
    self.badgeLabelTop.hidden = NO;
    self.badgeLabelBottom.hidden = NO;
    
    void (^animationBlock)() = ^{
        self.badgeLabelTop.frame = finishTopFrame;
        self.badgeLabelBottom.frame = finishBottomFrame;
    };
    void (^completionBlock)(BOOL) = ^(BOOL completed){};
    
    if (animated) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:animationBlock completion:completionBlock];
    }
    else {
        animationBlock();
        completionBlock(YES);
    }
    
}

- (void)hideBadge:(BOOL)animated
{
    if (self.badgeLabelTop.hidden && self.badgeLabelBottom.hidden)
        return;
    
    CGRect oldTopFrame = self.badgeLabelTop.frame;
    CGRect newTopFrame = CGRectOffset(self.badgeLabelTop.frame, 0-CGRectGetMaxX(self.badgeLabelTop.frame),0);
    CGRect oldBottomFrame = self.badgeLabelBottom.frame;
    CGRect newBottomFrame = CGRectOffset(self.badgeLabelBottom.frame,
                                         0-CGRectGetMaxX(self.badgeLabelBottom.frame),
                                         0);
    
    if (!self.rightSidedCell) {
        newTopFrame = CGRectOffset(self.badgeLabelTop.frame, CGRectGetWidth(self.nameTopLabel.frame)-CGRectGetMinX(self.badgeLabelTop.frame),0);
        newBottomFrame = CGRectOffset(self.badgeLabelBottom.frame, CGRectGetWidth(self.nameBottomLabel.frame)-CGRectGetMinX(self.badgeLabelBottom.frame),0);
    }
    
    void (^animationBlock)() = ^{
        self.badgeLabelTop.frame = newTopFrame;
        self.badgeLabelBottom.frame = newBottomFrame;
    };
    void (^completionBlock)(BOOL) = ^(BOOL completed){
        self.badgeLabelTop.hidden = YES;
        self.badgeLabelBottom.hidden = YES;
        self.badgeLabelTop.frame = oldTopFrame;
        self.badgeLabelBottom.frame = oldBottomFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:animationBlock completion:completionBlock];
    }
    else {
        animationBlock();
        completionBlock(YES);
    }
}


#pragma mark - Actions

- (void)switchChanged
{
    if ([self.delegate respondsToSelector:@selector(breakerCell:didDetectSwitchChangeButtonTap:)])
    {
        [self.delegate breakerCell:(CTRLBreakerCell *)self didDetectSwitchChangeButtonTap:self.breakerSwitch];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
