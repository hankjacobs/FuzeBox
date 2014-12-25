//
//  CTRLBreakerCell.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/31/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLBreakerCell.h"
#import "CTRLSwitch.h"
#import "CTRLDoublePoleSwitch.h"
#import "UIColor+UIColorFromRGB.h"

@interface CTRLBreakerCell ()

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UIView *switchContainer;
@property (weak, nonatomic) IBOutlet UIView *onOffSwitchContainer;
@property (weak, nonatomic) IBOutlet UIView *amperageContainer;
@property (weak, nonatomic) IBOutlet UIImageView *gfciImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

#pragma mark Configuration
@property (nonatomic, assign) BOOL usesDoublePoleSwitch;
@property (nonatomic, assign, getter = isRightSidedCell) BOOL rightSidedCell;
@property (nonatomic, assign) BOOL previousShowGFCI;

#pragma mark Custom Views
@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UILabel *offLabel;
@property (nonatomic, readwrite) UILabel *amperageLabel;
@property (nonatomic, readwrite) UILabel *badgeLabel;
@property (nonatomic, readwrite) CTRLSwitch *breakerSwitch;

@end

@implementation CTRLBreakerCell

- (void)awakeFromNib
{
    [self setupCustomViews];
}

- (void)setupCustomViews
{
    self.onLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
    self.offLabel = [[UILabel alloc] initWithFrame:self.onLabel.frame];
    self.amperageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 31, 18)];
    self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];

    self.offLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.onLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.amperageLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    self.offLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.offLabel.frame), CGRectGetHeight(self.offLabel.frame));
    self.onLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.onLabel.frame), CGRectGetHeight(self.onLabel.frame));
    self.amperageLabel.frame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(self.amperageLabel.frame),
                                          CGRectGetHeight(self.amperageLabel.frame));
    
    self.offLabel.center = CGPointMake(self.offLabel.center.x, self.onOffSwitchContainer.center.y);
    self.onLabel.center = CGPointMake(self.onLabel.center.x, self.onOffSwitchContainer.center.y);
    
    if (self.usesDoublePoleSwitch) {
        self.breakerSwitch = (CTRLSwitch *)[[CTRLDoublePoleSwitch alloc] initWithFrame:self.switchContainer.bounds];
    }
    else {
        self.breakerSwitch = [[CTRLSwitch alloc] initWithFrame:self.switchContainer.bounds];
    }
    
    CGRect rightOnOffLabelFrame = CGRectOffset(self.onLabel.frame,
                                              CGRectGetMaxX(self.switchContainer.frame)+3,
                                              0);
    CGRect leftOnOffLabelFrame = CGRectOffset(self.offLabel.frame,
                                              CGRectGetMinX(self.switchContainer.frame)-CGRectGetWidth(self.offLabel.frame)-3,
                                              0);
    if (self.rightSidedCell) {
        self.onLabel.frame = rightOnOffLabelFrame;
        self.offLabel.frame = leftOnOffLabelFrame;
        self.badgeLabel.frame = CGRectOffset(self.badgeLabel.frame, 2, CGRectGetHeight(self.nameLabel.bounds)/2-CGRectGetHeight(self.badgeLabel.frame)/2);
    }
    else {
        self.onLabel.frame = leftOnOffLabelFrame;
        self.offLabel.frame = rightOnOffLabelFrame;
        self.badgeLabel.frame = CGRectOffset(self.badgeLabel.frame,
                                             CGRectGetMaxX(self.nameLabel.bounds)-CGRectGetWidth(self.badgeLabel.frame)-2,
                                             CGRectGetHeight(self.nameLabel.bounds)/2-CGRectGetHeight(self.badgeLabel.frame)/2);
        self.breakerSwitch.transform = CGAffineTransformMakeScale(-1, 1);
    }

    self.breakerSwitch.frame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(self.breakerSwitch.frame),
                                          CGRectGetHeight(self.breakerSwitch.frame));
    
    self.offLabel.font = [UIFont boldSystemFontOfSize:8];
    self.onLabel.font = [UIFont boldSystemFontOfSize:8];
    self.amperageLabel.font = [UIFont boldSystemFontOfSize:10];
    
    self.nameLabel.backgroundColor = [UIColor whiteColor];
    self.amperageLabel.backgroundColor = [UIColor colorWithR:235 g:235 b:235];
    
    UIColor *textColor = [UIColor colorWithR:169 g:169 b:169];
    self.onLabel.textColor = textColor;
    self.offLabel.textColor = textColor;
    self.nameLabel.textColor = textColor;
    self.badgeLabel.textColor = [UIColor whiteColor];

    CGColorRef borderColor = [textColor CGColor];
    CGFloat borderWidth = 1.0;
    CGFloat borderRadius = 2.5;
    
    self.nameLabel.layer.borderColor = borderColor;
    self.nameLabel.layer.borderWidth = borderWidth;
    self.nameLabel.layer.cornerRadius = borderRadius;
    
    self.amperageLabel.layer.borderColor = borderColor;
    self.amperageLabel.layer.borderWidth = borderWidth;
    self.amperageLabel.layer.cornerRadius = borderRadius;
    
    self.badgeLabel.layer.cornerRadius = CGRectGetWidth(self.badgeLabel.frame)/2;
    
    self.offLabel.textAlignment = NSTextAlignmentCenter;
    self.onLabel.textAlignment = NSTextAlignmentCenter;
    self.amperageLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.badgeLabel.hidden = YES;
    self.gfciImageView.hidden = self.showGFCI;
    
    self.onLabel.text = @"ON";
    self.offLabel.text = @"OFF";
    
    [self.breakerSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.onOffSwitchContainer addSubview:self.onLabel];
    [self.onOffSwitchContainer addSubview:self.offLabel];
    [self.switchContainer addSubview:self.breakerSwitch];
    [self.amperageContainer addSubview:self.amperageLabel];
    [self.nameLabel addSubview:self.badgeLabel];
}

#pragma mark - Setters

- (void)setPunchout:(BOOL)punchout
{
    if (punchout) {
        self.onOffSwitchContainer.hidden = YES;
        self.amperageContainer.hidden = YES;
        self.nameLabel.hidden = YES;
        self.previousShowGFCI = self.showGFCI;
        self.gfciImageView.hidden = YES;
    }
    else {
        self.onOffSwitchContainer.hidden = NO;
        self.amperageContainer.hidden = NO;
        self.nameLabel.hidden = NO;
        self.gfciImageView.hidden = !self.previousShowGFCI;
    }
}

- (void)setBreakerAccentColor:(UIColor *)breakerAccentColor
{
    [self willChangeValueForKey:@"breakerAccentColor"];
    _breakerAccentColor = breakerAccentColor;
    [self didChangeValueForKey:@"breakerAccentColor"];
    
    self.amperageLabel.textColor = breakerAccentColor;
    self.breakerSwitch.onTintColor = breakerAccentColor;
    self.breakerSwitch.tintColor = breakerAccentColor;
    self.badgeLabel.backgroundColor = breakerAccentColor;
}

- (void)setNameText:(NSString *)nameText
{
    [self willChangeValueForKey:@"nameText"];
    _nameText = nameText;
    [self didChangeValueForKey:@"nameText"];
    
    self.nameLabel.text = nameText;
}

- (void)setBadgeText:(NSString *)badgeText
{
    [self willChangeValueForKey:@"badgeText"];
    _badgeText = badgeText;
    [self didChangeValueForKey:@"badgeText"];
    
    self.badgeLabel.text = badgeText;
}

- (void)setAmperageText:(NSString *)amperageText
{
    [self willChangeValueForKey:@"amperageText"];
    _amperageText = amperageText;
    [self didChangeValueForKey:@"amperageText"];
    
    self.amperageLabel.text = amperageText;
}

- (void)setShowGFCI:(BOOL)showGFCI
{
    [self willChangeValueForKey:@"showGFCI"];
    _showGFCI = showGFCI;
    [self didChangeValueForKey:@"showGFCI"];
    
    self.gfciImageView.hidden = !showGFCI;
    
    self.previousShowGFCI = showGFCI;

}

- (void)showBadge:(BOOL)animated
{
    if (!self.badgeLabel.hidden)
        return;
    
    CGRect finishFrame = self.badgeLabel.frame;
    CGRect startFrame = CGRectOffset(self.badgeLabel.frame, 0-CGRectGetMaxX(self.badgeLabel.frame),0);
    
    if (!self.rightSidedCell) {
        startFrame = CGRectOffset(self.badgeLabel.frame, CGRectGetMaxX(self.nameLabel.bounds),0);
    }
    
    self.badgeLabel.frame = startFrame;
    self.badgeLabel.hidden = NO;
    
    void (^animationBlock)() = ^{
        self.badgeLabel.frame = finishFrame;
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
    if (self.badgeLabel.hidden)
        return;
    
    CGRect oldFrame = self.badgeLabel.frame;
    CGRect newFrame = CGRectOffset(self.badgeLabel.frame, 0-CGRectGetMaxX(self.badgeLabel.frame),0);
    
    if (!self.rightSidedCell) {
        newFrame = CGRectOffset(self.badgeLabel.frame, CGRectGetWidth(self.nameLabel.frame)-CGRectGetMinX(self.badgeLabel.frame),0);
    }
    
    void (^animationBlock)() = ^{
        self.badgeLabel.frame = newFrame;
    };
    void (^completionBlock)(BOOL) = ^(BOOL completed){
        self.badgeLabel.hidden = YES;
        self.badgeLabel.frame = oldFrame;
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
        [self.delegate breakerCell:self didDetectSwitchChangeButtonTap:self.breakerSwitch];
    }
}


@end
