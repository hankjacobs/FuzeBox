//
//  CTRLSwitch.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLSwitch.h"

@interface CTRLSwitch ()

@property (nonatomic, strong) UIView *trackOutline;
@property (nonatomic, strong) UIView *trackFill;
@property (nonatomic, strong) UIImageView *knob;
@property (nonatomic, assign) BOOL wasTracking;

@end
@implementation CTRLSwitch

- (id)initWithFrame:(CGRect)frame
{
    CGRect forcedFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 51, 33);
    frame = forcedFrame;
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"onTintColor"];
        [self removeObserver:self forKeyPath:@"tintColor"];
    }
    @catch (NSException *exception) {
        NSLog(@"Observer was not registered in %@", [self class]);
    }
}

- (void)setup
{
    self.userInteractionEnabled = YES;
    self.trackOutline = [[UIView alloc] initWithFrame:CGRectMake(0, 1, CGRectGetWidth(self.frame), 32)];
    self.trackFill = [[UIView alloc] initWithFrame:self.trackOutline.frame];
    
    CGRect knobFrame = CGRectMake(CGRectGetMinX(self.trackOutline.frame),
                                     CGRectGetMinY(self.trackOutline.frame),
                                     CGRectGetHeight(self.trackOutline.frame),
                                     CGRectGetHeight(self.trackOutline.frame));
    knobFrame = CGRectInset(knobFrame, 1, 1);
    
    self.knob = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breakerSwitch"]];
    
    self.knob.center = CGPointMake(CGRectGetMinX(self.trackOutline.frame)+CGRectGetWidth(self.knob.frame)/2-5.25,CGRectGetMinY(self.trackOutline.frame)+CGRectGetHeight(self.knob.frame)/2-2);
    
    self.trackOutline.layer.cornerRadius = 15.5;
    self.trackFill.layer.cornerRadius = 15.5;

    if (!self.tintColor) {
        self.tintColor = [[UIApplication sharedApplication] keyWindow].tintColor;
    }
    
    if (!self.onTintColor) {
        self.onTintColor = [[UIApplication sharedApplication] keyWindow].tintColor;
    }
    
    self.trackOutline.layer.borderWidth = 1.5;
    self.trackFill.layer.borderWidth = 0.0;
    
    [self addSubview:self.trackFill];
    [self addSubview:self.trackOutline];
    [self addSubview:self.knob];
    
    self.trackFill.userInteractionEnabled = NO;
    self.trackOutline.userInteractionEnabled = NO;

    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self addObserver:self forKeyPath:@"onTintColor" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"tintColor" options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)setupColors
{

    self.trackFill.backgroundColor = [UIColor clearColor];

    self.trackOutline.layer.borderColor = [self.tintColor CGColor];
    self.trackFill.layer.borderColor = [self.onTintColor CGColor];
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    [self.onTintColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.trackOutline.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:.15];
}

- (void)setOn:(BOOL)on
{
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    if (on) {
        [self moveKnobToOnPositionAnimated:animated resetSize:YES];
        [self fillTracksAnimated:animated];
    }
    else {
        [self moveKnobToOffPostionAnimated:animated resetSize:YES];
        [self drainTracksAnimated:animated];
    }
    
    _on = on;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)fillTracksAnimated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        fillAnimation.duration = .3;
        [self.trackFill.layer addAnimation:fillAnimation forKey:@"borderWidth"];
    }
    
    self.trackFill.layer.borderWidth = CGRectGetHeight(self.trackFill.frame);
}

- (void)drainTracksAnimated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        fillAnimation.duration = .3;
        [self.trackFill.layer addAnimation:fillAnimation forKey:@"borderWidth"];
    }
    
    self.trackFill.layer.borderWidth = 0.0;
}

- (void)moveKnobToOnPositionAnimated:(BOOL)animated resetSize:(BOOL)resetSize
{
    CGSize knobSize = self.knob.frame.size;
    
    if (resetSize) {
        knobSize = self.knob.image.size;
    }
    
    CGFloat xOffset = CGRectGetWidth(self.trackOutline.frame)-36.0;
    
    if (!resetSize) {
        xOffset = CGRectGetWidth(self.trackOutline.frame)-42.0;
    }
    
    CGRect knobFrame = CGRectMake(xOffset,
                                  CGRectGetMinY(self.knob.frame),
                                  self.knob.image.size.width,
                                  CGRectGetHeight(self.knob.frame));
    
    knobFrame.size = knobSize;
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            self.knob.frame = knobFrame;
        }];
    }
    else {
        self.knob.frame = knobFrame;
    }
}

- (void)moveKnobToOffPostionAnimated:(BOOL)animated resetSize:(BOOL)resetSize
{
    CGSize knobSize = self.knob.frame.size;
    
    if (resetSize) {
        knobSize = self.knob.image.size;
    }
    
    
    CGRect knobFrame = CGRectMake(-5,
                                  CGRectGetMinY(self.knob.frame),
                                  self.knob.image.size.width,
                                  CGRectGetHeight(self.knob.frame));
    
    knobFrame.size = knobSize;
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            self.knob.frame = knobFrame;
        }];
    }
    else {
        self.knob.frame = knobFrame;
    }
}

#pragma mark - Touch Handling
- (void)touchDown:(CTRLSwitch *)toggleSwitch
{
    if (!self.isOn) {
        [self fillTracksAnimated:YES];
    }
    
    CGFloat xOffset = 0.0;
    
    if (self.isOn) {
        xOffset = .25 * CGRectGetWidth(self.knob.frame);
    }
    
    [UIView animateWithDuration:.3 animations:^{
        self.knob.frame = CGRectMake(CGRectGetMinX(self.knob.frame)-xOffset,
                                     CGRectGetMinY(self.knob.frame),
                                     CGRectGetWidth(self.knob.frame)*1.25,
                                     CGRectGetHeight(self.knob.frame));
    }];
}

- (void)touchUpInside:(CTRLSwitch *)toggleSwitch
{
    if (self.wasTracking) {
        self.wasTracking = NO;
        return;
    }
    
    if (!self.isOn) {
        [self moveKnobToOnPositionAnimated:YES resetSize:YES];
    }
    else {
        [self moveKnobToOffPostionAnimated:YES resetSize:YES];
        [self drainTracksAnimated:YES];
    }
    
    _on = !self.isOn;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchUpOutside:(CTRLSwitch *)toggleSwitch
{
    if (self.wasTracking) {
        self.wasTracking = NO;
        return;
    }
    
    if (!self.isOn) {
        [self drainTracksAnimated:YES];
        [self moveKnobToOffPostionAnimated:YES resetSize:YES];
    }
    else {
        [self moveKnobToOnPositionAnimated:YES resetSize:YES];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"onTintColor"] || [keyPath isEqualToString:@"tintColor"]) {
        [self setupColors];
    }
}

@end
