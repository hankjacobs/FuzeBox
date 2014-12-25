//
//  CTRLBreakerViewCell.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLBreakerViewCell.h"
#import "UIColor+UIColorFromRGB.h"
#import "CTRLTandemSwitch.h"
#import "CTRLDoublePoleSwitch.h"

@interface CTRLBreakerViewCell ()

@property (nonatomic, strong) UIView *breakerView;
@property (nonatomic, readwrite) UILabel *nameLabel;
@property (nonatomic, readwrite) UILabel *amperageLabel;
@property (nonatomic, strong) UILabel *fixtureBadge;
@property (nonatomic, strong) UIView *onOffView;
@property (nonatomic, strong) UIView *flipSwitchView;
@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UILabel *offLabel;
@property (nonatomic, strong) UIImageView *gfciImage;
@property (nonatomic, strong) UIView *breakerView2;
@property (nonatomic, readwrite) UILabel *nameLabel2;
@property (nonatomic, readwrite) UILabel *amperageLabel2;
@property (nonatomic, strong) UILabel *fixtureBadge2;
@property (nonatomic, strong) UIView *onOffView2;
@property (nonatomic, strong) UILabel *onLabel2;
@property (nonatomic, strong) UILabel *offLabel2;
@property (nonatomic, strong) UIImageView *gfciImage2;
@property (nonatomic, strong) UIView *seperatorLine2;

@end

@implementation CTRLBreakerViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeCell];
        [self setupCell];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializeCell];
        [self setupCell];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}

- (void)initializeCell
{
    self.backgroundColor = [UIColor colorWithR:240 g:240 b:240];
    self.seperatorLine2 = [[UIView alloc] init];
    self.breakerView = [[UIView alloc] init];
    self.nameLabel = [[UILabel alloc] init];
    self.amperageLabel = [[UILabel alloc] init];
    self.fixtureBadge = [[UILabel alloc] init];
    self.flipSwitch = [[CTRLSwitch alloc] initWithFrame:CGRectZero];
    [self.flipSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    self.flipSwitchView = [[UIView alloc] init];
    self.onOffView = [[UIView alloc] init];
    self.onLabel = [[UILabel alloc] init];
    self.offLabel = [[UILabel alloc] init];
    self.gfciImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breakerGFCI"]];
}

- (void)setupCell
{
    self.breakerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.fixtureBadge.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.amperageLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.flipSwitchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleRightMargin;
    self.onOffView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleLeftMargin;
    self.gfciImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.offLabel.font = [UIFont boldSystemFontOfSize:8];
    self.onLabel.font = [UIFont boldSystemFontOfSize:8];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:12];
    self.amperageLabel.font = [UIFont boldSystemFontOfSize:10];
    
    UIColor *textColor = [UIColor colorWithR:169 g:169 b:169];
    self.onLabel.textColor = textColor;
    self.offLabel.textColor = textColor;
    self.nameLabel.textColor = textColor;
    
    self.fixtureBadge.textColor = [UIColor whiteColor];
    self.fixtureBadge.layer.cornerRadius = 25.0/2.0;
    
    self.onOffView.backgroundColor = [UIColor clearColor];
    self.breakerView.backgroundColor = self.backgroundColor;
    self.seperatorLine2.backgroundColor = textColor;
    self.nameLabel.backgroundColor = [UIColor whiteColor];
    self.amperageLabel.backgroundColor = [UIColor colorWithR:235 g:235 b:235];
    self.fixtureBadge.backgroundColor = [UIColor darkGrayColor];
    
    self.offLabel.textAlignment = NSTextAlignmentCenter;
    self.onLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.amperageLabel.textAlignment = NSTextAlignmentCenter;
    self.fixtureBadge.textAlignment = NSTextAlignmentCenter;
    
    CGColorRef borderColor = [textColor CGColor];
    CGFloat borderWidth = 1.0;
    CGFloat borderRadius = 2.5;
    
    self.nameLabel.layer.borderColor = borderColor;
    self.nameLabel.layer.borderWidth = borderWidth;
    self.nameLabel.layer.cornerRadius = borderRadius;
    
    self.amperageLabel.layer.borderColor = borderColor;
    self.amperageLabel.layer.borderWidth = borderWidth;
    self.amperageLabel.layer.cornerRadius = borderRadius;
    
    self.onLabel.text = @"ON";
    self.offLabel.text = @"OFF";
    
    [self setFrames];
    
    [self.breakerView addSubview:self.nameLabel];
    [self.breakerView addSubview:self.amperageLabel];
    [self.onOffView addSubview:self.onLabel];
    [self.onOffView addSubview:self.offLabel];
    [self.breakerView addSubview:self.onOffView];
    [self.breakerView addSubview:self.gfciImage];
    [self.contentView addSubview:self.breakerView];
    [self.flipSwitchView addSubview:self.flipSwitch];
    [self.contentView addSubview:self.flipSwitchView];
    [self.contentView addSubview:self.fixtureBadge];
}

- (void)setFrames
{
    
    self.flipSwitch.transform = CGAffineTransformIdentity;
    self.breakerView.transform = CGAffineTransformIdentity;
    self.nameLabel.transform = CGAffineTransformIdentity;
    self.fixtureBadge.transform = CGAffineTransformIdentity;
    self.amperageLabel.transform = CGAffineTransformIdentity;
    self.offLabel.transform = CGAffineTransformIdentity;
    self.onLabel.transform = CGAffineTransformIdentity;
    self.gfciImage.transform = CGAffineTransformIdentity;
    
    self.flipSwitch.frame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.flipSwitch.frame),
                                       CGRectGetHeight(self.flipSwitch.frame));
    self.flipSwitchView.frame = self.flipSwitch.frame;
    
    CGRect breakerFrame = CGRectMake(0,
                                     0,
                                     CGRectGetWidth(self.contentView.bounds),
                                     CGRectGetHeight(self.contentView.bounds));
    
    if (self.cellStyle == CTRLBreakerCellStyleHorizontal) {
        if (CGRectGetWidth(breakerFrame) > 88) {
            breakerFrame.size.width = 88;
        }
    }
    else {
        if (CGRectGetHeight(breakerFrame) > 88) {
            breakerFrame.size.height = 88;
        }
    }
    
    self.breakerView.frame = breakerFrame;
    self.nameLabel.frame = CGRectMake(0, 0, 129, 31);
    self.amperageLabel.frame = CGRectMake(0, 0, 31, 18);
    self.fixtureBadge.frame = CGRectMake(0, 0, 25, 25);
    self.onOffView.frame = CGRectMake(0, 0, 85, CGRectGetHeight(breakerFrame));
    self.offLabel.frame = CGRectMake(0, 0, 25, 10);
    self.onLabel.frame = self.offLabel.frame;
    self.gfciImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.gfciImage.frame), CGRectGetHeight(self.gfciImage.frame));
    
    if (self.cellStyle == CTRLBreakerCellStyleHorizontal) {
        self.gfciImage.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.nameLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.fixtureBadge.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        if (self.switchOrientation == SwitchOrientationRight) {
            [self setFrameOffsetsForLeftHorizontalOrientation];
        }
        else {
            [self setFrameOffsetsForRightHorizontalOrientation];
        }

    }
    else {
        self.offLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.onLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.amperageLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        if (self.switchOrientation == SwitchOrientationLeft) {
            [self setFrameOffsetsForLeftVerticalOrientation];
        }
        else {
            [self setFrameOffsetsForRightVerticalOrientation];
        }
    }
}

- (void)setFrameOffsetsForLeftHorizontalOrientation
{
    self.flipSwitch.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    CGRect flipSwitchFrame = self.flipSwitch.frame;
    flipSwitchFrame.origin.x = 0;
    flipSwitchFrame.origin.y = 0;
    self.flipSwitch.frame = flipSwitchFrame;
    
    self.onLabel.frame = CGRectOffset(self.onLabel.frame, 0, 2);
    self.flipSwitch.frame = CGRectOffset(self.flipSwitch.frame, 0, CGRectGetMaxY(self.onLabel.frame)+4);
    self.offLabel.frame = CGRectOffset(self.offLabel.frame, 0, CGRectGetMaxY(self.flipSwitch.frame)+3);
    
    CGFloat amperageY = CGRectGetHeight(self.breakerView.frame)-CGRectGetHeight(self.amperageLabel.frame)-13;
    self.amperageLabel.frame = CGRectOffset(self.amperageLabel.frame, 0, amperageY);
    
    CGFloat nameY = CGRectGetMinY(self.amperageLabel.frame)-CGRectGetHeight(self.nameLabel.frame)-17.0;
    self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), nameY, CGRectGetWidth(self.nameLabel.frame), CGRectGetHeight(self.nameLabel.frame));
    
    CGFloat gfciY = CGRectGetMinY(self.nameLabel.frame)-CGRectGetHeight(self.gfciImage.frame)-2;
    self.gfciImage.frame = CGRectMake(CGRectGetMinX(self.gfciImage.frame),
                                      gfciY,
                                      CGRectGetWidth(self.gfciImage.frame),
                                      CGRectGetHeight(self.gfciImage.frame));
    
    CGPoint center = self.breakerView.center;
    CGPoint flipSwitchCenter = center;
    
    if (self.isDoubleCell) {
        flipSwitchCenter.x += 44.0;
    }
    self.onLabel.center = CGPointMake(center.x, self.onLabel.center.y);
    self.offLabel.center = CGPointMake(center.x, self.offLabel.center.y);
    
    self.nameLabel.center = CGPointMake(center.x, self.nameLabel.center.y);
    self.amperageLabel.center = CGPointMake(center.x, self.amperageLabel.center.y);
    self.flipSwitch.center = CGPointMake(flipSwitchCenter.x, self.flipSwitch.center.y);
    self.gfciImage.center = CGPointMake(center.x, self.gfciImage.center.y);
}

- (void)setFrameOffsetsForRightHorizontalOrientation
{
    self.flipSwitch.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.onOffView.frame = CGRectOffset(self.onOffView.frame,
                                        CGRectGetMaxX(self.breakerView.frame)-CGRectGetWidth(self.onOffView.frame),
                                        0);

    CGFloat offLabelHeight = CGRectGetHeight(self.offLabel.frame);
    CGFloat flipSwitchHeight = CGRectGetHeight(self.flipSwitch.frame);

    self.onLabel.frame = CGRectOffset(self.onLabel.frame, 0, CGRectGetWidth(self.onOffView.frame)-2);
    self.flipSwitch.frame = CGRectMake(0,
                                       CGRectGetMinY(self.onLabel.frame)-flipSwitchHeight-4 ,
                                       CGRectGetWidth(self.flipSwitch.frame), CGRectGetHeight(self.flipSwitch.frame));
    self.offLabel.frame = CGRectOffset(self.offLabel.frame, 0, CGRectGetMinY(self.flipSwitch.frame)-offLabelHeight-2);
    
    CGFloat amperageY = 13;
    self.amperageLabel.frame = CGRectOffset(self.amperageLabel.frame, 0, amperageY);
    
    CGFloat nameY = CGRectGetMaxY(self.amperageLabel.frame)+17.0;
    self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), nameY, CGRectGetWidth(self.nameLabel.frame), CGRectGetHeight(self.nameLabel.frame));
    
    CGFloat gfciY = CGRectGetMaxY(self.nameLabel.frame)+2;
    self.gfciImage.frame = CGRectMake(CGRectGetMinX(self.gfciImage.frame),
                                      gfciY,
                                      CGRectGetWidth(self.gfciImage.frame),
                                      CGRectGetHeight(self.gfciImage.frame));
    
    CGPoint center = self.breakerView.center;
    
    CGPoint flipSwitchCenter = center;
    
    if (self.isDoubleCell) {
        flipSwitchCenter.x += 44.0;
    }
    
    self.onLabel.center = CGPointMake(center.x, self.onLabel.center.y);
    self.offLabel.center = CGPointMake(center.x, self.offLabel.center.y);
    
    self.nameLabel.center = CGPointMake(center.x, self.nameLabel.center.y);
    self.amperageLabel.center = CGPointMake(center.x, self.amperageLabel.center.y);
    self.flipSwitch.center = CGPointMake(flipSwitchCenter.x, self.flipSwitch.center.y);
    self.gfciImage.center = CGPointMake(center.x, self.gfciImage.center.y);
}

- (void)setFrameOffsetsForLeftVerticalOrientation
{
    self.flipSwitchView.autoresizingMask = (self.flipSwitchView.autoresizingMask^UIViewAutoresizingFlexibleLeftMargin)| UIViewAutoresizingFlexibleRightMargin;
    self.onOffView.autoresizingMask = (self.onOffView.autoresizingMask^UIViewAutoresizingFlexibleLeftMargin)| UIViewAutoresizingFlexibleRightMargin;
    
    self.onOffView.frame = CGRectMake(0, 0, CGRectGetWidth(self.onOffView.frame), CGRectGetHeight(self.onOffView.frame));
    
    self.flipSwitch.transform = CGAffineTransformMakeScale(-1, 1);
    self.flipSwitch.frame = CGRectMake(0, 0, CGRectGetWidth(self.flipSwitch.frame), CGRectGetHeight(self.flipSwitch.frame));
    
    self.onLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.onLabel.frame), CGRectGetHeight(self.onLabel.frame));
    self.onLabel.frame = CGRectOffset(self.onLabel.frame, 2, 0);
    self.offLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.offLabel.frame), CGRectGetHeight(self.offLabel.frame));
    self.offLabel.frame = CGRectOffset(self.offLabel.frame, CGRectGetMaxX(self.onOffView.bounds)-CGRectGetWidth(self.offLabel.frame), 0);
    self.flipSwitchView.frame = CGRectOffset(self.flipSwitch.frame,
                                         CGRectGetMidX(self.onOffView.frame)-CGRectGetWidth(self.flipSwitch.frame)/2,
                                         0);

    
    CGFloat amperageX = CGRectGetWidth(self.breakerView.frame)-CGRectGetWidth(self.amperageLabel.frame)-16;
    self.amperageLabel.frame = CGRectOffset(self.amperageLabel.frame,amperageX,0);
    
    CGFloat nameX = CGRectGetMinX(self.amperageLabel.frame)-CGRectGetWidth(self.nameLabel.frame)-17.0;
    self.nameLabel.frame = CGRectOffset(self.nameLabel.frame, nameX, 0);
    
    self.fixtureBadge.frame = CGRectOffset(self.fixtureBadge.frame, CGRectGetMaxX(self.nameLabel.frame)-CGRectGetWidth(self.fixtureBadge.frame)-3, 0);
    
    CGFloat gfciX = CGRectGetMinX(self.nameLabel.frame)-CGRectGetWidth(self.gfciImage.frame)-2;
    self.gfciImage.frame = CGRectMake(gfciX,
                                      CGRectGetMinY(self.gfciImage.frame),
                                      CGRectGetWidth(self.gfciImage.frame),
                                      CGRectGetHeight(self.gfciImage.frame));
    
    CGPoint center = self.breakerView.center;
    CGPoint flipSwitchCenter = center;
    
    if (self.isDoubleCell) {
        flipSwitchCenter.y += 44.0;
    }
    
    self.onLabel.center = CGPointMake(self.onLabel.center.x, center.y);
    self.offLabel.center = CGPointMake(self.offLabel.center.x, center.y);
    
    self.nameLabel.center = CGPointMake(self.nameLabel.center.x, center.y);
    self.fixtureBadge.center = CGPointMake(self.fixtureBadge.center.x, center.y);
    self.amperageLabel.center = CGPointMake(self.amperageLabel.center.x, center.y);
    self.flipSwitchView.center = CGPointMake(self.flipSwitchView.center.x, flipSwitchCenter.y);
    self.gfciImage.center = CGPointMake(self.gfciImage.center.x, center.y);

}

- (void)setFrameOffsetsForRightVerticalOrientation
{
    self.flipSwitchView.autoresizingMask = (self.flipSwitchView.autoresizingMask^UIViewAutoresizingFlexibleRightMargin)| UIViewAutoresizingFlexibleLeftMargin;
    self.onOffView.autoresizingMask = (self.onOffView.autoresizingMask^UIViewAutoresizingFlexibleRightMargin)| UIViewAutoresizingFlexibleLeftMargin;
    
    self.onOffView.frame = CGRectOffset(self.onOffView.frame,
                                        CGRectGetMaxX(self.breakerView.frame)-CGRectGetWidth(self.onOffView.frame),
                                        0);

    CGFloat onLabelWidth = CGRectGetWidth(self.onLabel.frame); //Height/Width switched because its flipped

    self.onLabel.frame = CGRectMake(CGRectGetMaxX(self.onOffView.bounds)-onLabelWidth-2, 0, CGRectGetWidth(self.onLabel.frame), CGRectGetHeight(self.onLabel.frame));
    self.offLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.offLabel.frame), CGRectGetHeight(self.offLabel.frame));
    self.flipSwitchView.frame = CGRectOffset(self.flipSwitch.frame, CGRectGetMidX(self.onOffView.frame)-CGRectGetWidth(self.flipSwitch.frame)/2, 0.0);
    
    CGFloat amperageX = 5;
    self.amperageLabel.frame = CGRectOffset(self.amperageLabel.frame,amperageX,0);
    
    CGFloat nameX = CGRectGetMaxX(self.amperageLabel.frame)+17.0;
    self.nameLabel.frame = CGRectOffset(self.nameLabel.frame, nameX, 0);
    
    self.fixtureBadge.frame = CGRectOffset(self.fixtureBadge.frame, CGRectGetMinX(self.nameLabel.frame)+3, 0);
    
    CGFloat gfciX = CGRectGetMaxX(self.nameLabel.frame)+3;
    self.gfciImage.frame = CGRectMake(gfciX,
                                      CGRectGetMinY(self.gfciImage.frame),
                                      CGRectGetWidth(self.gfciImage.frame),
                                      CGRectGetHeight(self.gfciImage.frame));
    
    CGPoint center = self.breakerView.center;
    CGPoint flipSwitchCenter = center;
    
    if (self.isDoubleCell) {
        flipSwitchCenter.y += 44.0;
    }
    
    self.onLabel.center = CGPointMake(self.onLabel.center.x, center.y);
    self.offLabel.center = CGPointMake(self.offLabel.center.x, center.y);
    
    self.nameLabel.center = CGPointMake(self.nameLabel.center.x, center.y);
    self.fixtureBadge.center = CGPointMake(self.fixtureBadge.center.x, center.y);
    self.amperageLabel.center = CGPointMake(self.amperageLabel.center.x, center.y);
    self.flipSwitchView.center = CGPointMake(self.flipSwitchView.center.x, flipSwitchCenter.y);
    self.gfciImage.center = CGPointMake(self.gfciImage.center.x, center.y);
}

//#pragma mark - Getters
//
//- (BOOL)isEditing
//{
//    return _editing;
//}

#pragma mark - Setters

- (void)setGfci:(BOOL)gfci
{
    _gfci = gfci;
    
    if (gfci) {
        self.gfciImage.hidden = NO;
    }
    else {
        self.gfciImage.hidden = YES;
    }
}

//TODO: refactor - maybe an enum of accessory type or something
- (void)setTandem:(BOOL)tandem
{
    _tandem = tandem;
    
    CGRect frame = self.flipSwitch.frame;
    CGAffineTransform transfrom = self.flipSwitch.transform;
    
    [self.flipSwitch removeFromSuperview];
    BOOL wasOn = self.flipSwitch.on;
    
    if (tandem) {
        //Casting to a UISwitch is kind of sloppy
        self.flipSwitch = (CTRLSwitch *)[[CTRLTandemSwitch alloc] initWithFrame:frame];
        self.flipSwitch.transform = transfrom;
        self.flipSwitch.tintColor = self.tintColor;
        self.flipSwitch.onTintColor = self.tintColor;
        self.flipSwitch.on = wasOn;
    }
    else {
        if (self.isDoublePole) {
            self.flipSwitch = (CTRLSwitch *)[[CTRLDoublePoleSwitch alloc] initWithFrame:frame];
            self.flipSwitch.transform = transfrom;
            self.flipSwitch.tintColor = self.tintColor;
            self.flipSwitch.onTintColor = self.tintColor;
            self.flipSwitch.on = wasOn;
        }
        else {
            self.flipSwitch = [[CTRLSwitch alloc] initWithFrame:frame];
            self.flipSwitch.transform = transfrom;
            self.flipSwitch.tintColor = self.tintColor;
            self.flipSwitch.onTintColor = self.tintColor;
            self.flipSwitch.on = wasOn;
        }
    }
    
    [self.flipSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.flipSwitchView addSubview:self.flipSwitch];
}

- (void)setDoublePole:(BOOL)doublePole
{
    _doublePole = doublePole;
    
    CGRect frame = self.flipSwitch.frame;
    CGAffineTransform transfrom = self.flipSwitch.transform;
    
    [self.flipSwitch removeFromSuperview];
    BOOL wasOn = self.flipSwitch.on;
    
    if (doublePole || self.doubleCell) {
        //Casting to a UISwitch is kind of sloppy
        if (!self.doubleCell) {
            frame.size.height = 79;
        }
        else {
            frame.size.height = 122;
        }
        self.flipSwitch = (CTRLSwitch *)[[CTRLDoublePoleSwitch alloc] initWithFrame:frame];
        self.flipSwitch.transform = transfrom;
        self.flipSwitch.tintColor = self.tintColor;
        self.flipSwitch.onTintColor = self.tintColor;
        self.flipSwitch.on = wasOn;
    }
    else {
        if (self.isTandem) {
            self.flipSwitch = (CTRLSwitch *)[[CTRLTandemSwitch alloc] initWithFrame:frame];
            self.flipSwitch.transform = transfrom;
            self.flipSwitch.tintColor = self.tintColor;
            self.flipSwitch.onTintColor = self.tintColor;
            self.flipSwitch.on = wasOn;
        }
        else {
            self.flipSwitch = [[CTRLSwitch alloc] initWithFrame:frame];
            self.flipSwitch.transform = transfrom;
            self.flipSwitch.tintColor = self.tintColor;
            self.flipSwitch.onTintColor = self.tintColor;
            self.flipSwitch.on = wasOn;
        }
    }
    
    [self.flipSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    [self.flipSwitchView addSubview:self.flipSwitch];
}

- (void)setCellStyle:(CTRLBreakerCellStyle)cellStyle
{
    _cellStyle = cellStyle;

    [self setNeedsLayout];
}
//- (void)setEditing:(BOOL)editing
//{
//    [self setEditing:editing animated:NO];
//}
//
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//    if (_editing == editing)
//        return;
//    
//    [self willChangeValueForKey:@"editing"];
//    _editing = editing;
//    [self didChangeValueForKey:@"editing"];
//
//    void (^editAnimationBlock)();
//    void (^editAnimationCompletionBlock)(BOOL);
//    if (editing) {
//        
//        self.deleteButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
//        self.deleteButton.center = CGPointMake(30, self.breakerScrollView.center.y);
//        self.deleteButton.alpha = 0.0;
//        [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self.contentView addSubview:self.deleteButton];
//        
//        editAnimationBlock = ^(){
//            self.deleteButton.alpha = 1.0;
//            self.breakerContentView.frame = CGRectMake(60,
//                                                       0,
//                                                       CGRectGetWidth(self.breakerContentView.frame),
//                                                       CGRectGetHeight(self.breakerContentView.frame));
//        };
//        editAnimationCompletionBlock = ^(BOOL completed){};
//    }
//    else {
//        editAnimationBlock = ^(){
//            self.breakerContentView.frame = CGRectMake(0,
//                                                       0,
//                                                       CGRectGetWidth(self.breakerContentView.frame),
//                                                       CGRectGetHeight(self.breakerContentView.frame));
//            self.breakerScrollView.contentOffset = CGPointZero;
//            self.deleteButton.alpha = 0.0;
//        };
//        editAnimationCompletionBlock = ^(BOOL completed){
//            [self.deleteButton removeFromSuperview];
//            [self.deleteConfirmationButton removeFromSuperview];
//            self.breakerScrollView.userInteractionEnabled = NO;
//            self.breakerScrollView.scrollEnabled = NO;
//        };
//    }
//    
//    if (animated) {
//        [UIView animateWithDuration:.3 animations:editAnimationBlock completion:editAnimationCompletionBlock];
//    }
//    else {
//        editAnimationBlock();
//        editAnimationCompletionBlock(YES);
//    }
//
//}

- (void)setSwitchOrientation:(SwitchOrientation)switchOrientation
{
    _switchOrientation = switchOrientation;
    
    [self setFrames];
}

- (void)setDoubleCell:(BOOL)doubleCell
{
    _doubleCell = doubleCell;
    
    if (doubleCell) {
        self.breakerView.autoresizingMask = self.breakerView.autoresizingMask^UIViewAutoresizingFlexibleHeight;
        
        CGRect breakerFrame = self.breakerView.frame;
        breakerFrame.size.height = 88;
        self.breakerView.frame = breakerFrame;
        
        CGRect flipSwitchFrame = self.flipSwitch.frame;
        flipSwitchFrame.size.height = 122;

        CGAffineTransform transform = self.flipSwitch.transform;
        UIColor *onColor = self.flipSwitch.onTintColor;
        UIColor *tintColor = self.flipSwitch.tintColor;
        BOOL isOn = self.flipSwitch.isOn;
        
        [self.flipSwitch removeFromSuperview];
        
        self.flipSwitch = (CTRLSwitch *)[[CTRLDoublePoleSwitch alloc] initWithFrame:flipSwitchFrame];
        self.flipSwitch.transform = transform;
        self.flipSwitch.tintColor = tintColor;
        self.flipSwitch.onTintColor = onColor;
        self.flipSwitch.on = isOn;
        [self.flipSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        [self.flipSwitchView addSubview:self.flipSwitch];
        self.flipSwitchView.frame = CGRectOffset(self.flipSwitchView.frame, 0, 2);
        
        [self.breakerView2 removeFromSuperview];
        self.breakerView2 = [self copyBreakerView];
        self.breakerView2.frame = CGRectOffset(self.breakerView2.frame, 0, breakerFrame.size.height);
        
        self.seperatorLine2.frame = CGRectMake(0,
                                               CGRectGetMaxY(self.breakerView.frame)-1,
                                               CGRectGetWidth(self.contentView.bounds),
                                               .5);
        
        [self.contentView addSubview:self.breakerView2];
        [self.contentView addSubview:self.seperatorLine2];
        [self.contentView bringSubviewToFront:self.flipSwitchView];
    }
    else {
        [self.breakerView2 removeFromSuperview];
        self.tandem = self.isTandem;
        self.doublePole = self.isDoublePole;
    }
}

- (UIView *)copyBreakerView
{
    UIView *breakerViewCopy = [[UIView alloc] initWithFrame:self.breakerView.frame];
    breakerViewCopy.backgroundColor = self.breakerView.backgroundColor;
    breakerViewCopy.autoresizingMask = self.breakerView.autoresizingMask;
    
    self.onLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    self.onLabel2.autoresizingMask = self.onLabel.autoresizingMask;
    self.onLabel2.backgroundColor = self.onLabel2.backgroundColor;
    self.onLabel2.font = self.onLabel.font;
    self.onLabel2.textColor = self.onLabel.textColor;
    self.onLabel2.textAlignment = self.onLabel.textAlignment;
    self.onLabel2.text = self.onLabel.text;
    self.onLabel2.transform = self.onLabel.transform;
    self.onLabel2.frame = self.onLabel.frame;
    
    self.offLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    self.offLabel2.autoresizingMask = self.offLabel.autoresizingMask;
    self.offLabel2.backgroundColor = self.offLabel.backgroundColor;
    self.offLabel2.font = self.offLabel.font;
    self.offLabel2.textColor = self.offLabel.textColor;
    self.offLabel2.textAlignment = self.offLabel.textAlignment;
    self.offLabel2.text = self.offLabel.text;
    self.offLabel2.transform = self.offLabel.transform;
    self.offLabel2.frame = self.offLabel.frame;
    
    self.onOffView2 = [[UIView alloc] initWithFrame:self.onOffView.frame];
    self.onOffView2.backgroundColor = self.onOffView2.backgroundColor;
    self.onOffView2.autoresizingMask = self.onOffView2.autoresizingMask;
    
    self.nameLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel2.autoresizingMask = self.nameLabel.autoresizingMask;
    self.nameLabel2.backgroundColor = self.nameLabel.backgroundColor;
    self.nameLabel2.font = self.nameLabel.font;
    self.nameLabel2.textColor = self.nameLabel.textColor;
    self.nameLabel2.textAlignment = self.nameLabel.textAlignment;
    self.nameLabel2.text = self.nameLabel.text;
    self.nameLabel2.transform = self.nameLabel.transform;
    self.nameLabel2.frame = self.nameLabel.frame;
    self.nameLabel2.layer.borderColor = self.nameLabel.layer.borderColor;
    self.nameLabel2.layer.borderWidth = self.nameLabel.layer.borderWidth;
    self.nameLabel2.layer.cornerRadius = self.nameLabel.layer.cornerRadius;

    self.amperageLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    self.amperageLabel2.autoresizingMask = self.amperageLabel.autoresizingMask;
    self.amperageLabel2.backgroundColor = self.amperageLabel.backgroundColor;
    self.amperageLabel2.font = self.amperageLabel.font;
    self.amperageLabel2.textColor = self.amperageLabel.textColor;
    self.amperageLabel2.textAlignment = self.amperageLabel.textAlignment;
    self.amperageLabel2.text = self.amperageLabel.text;
    self.amperageLabel2.transform = self.amperageLabel.transform;
    self.amperageLabel2.frame = self.amperageLabel.frame;
    self.amperageLabel2.layer.borderColor = self.amperageLabel.layer.borderColor;
    self.amperageLabel2.layer.borderWidth = self.amperageLabel.layer.borderWidth;
    self.amperageLabel2.layer.cornerRadius = self.amperageLabel.layer.cornerRadius;
    
    [self.onOffView2 addSubview:self.onLabel2];
    [self.onOffView2 addSubview:self.offLabel2];
    [breakerViewCopy addSubview:self.onOffView2];
    [breakerViewCopy addSubview:self.amperageLabel2];
    [breakerViewCopy addSubview:self.nameLabel2];
    
    return breakerViewCopy;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setFrames];
}

#pragma mark - Actions

- (void)switchChanged
{
    if ([self.delegate respondsToSelector:@selector(breakerViewCell:didDetectSwitchChangeButtonTap:)])
    {
        [self.delegate breakerViewCell:self didDetectSwitchChangeButtonTap:self.flipSwitch];
    }
}

@end
