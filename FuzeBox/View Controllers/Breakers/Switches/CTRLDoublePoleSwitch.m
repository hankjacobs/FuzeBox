//
//  CTRLDoublePoleSwitch.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 12/1/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLDoublePoleSwitch.h"

@interface CTRLDoublePoleSwitch ()

@property (nonatomic, strong) UIView *topTrackOutline;
@property (nonatomic, strong) UIView *topTrackFill;
@property (nonatomic, strong) UIView *bottomTrackOutline;
@property (nonatomic, strong) UIView *bottomTrackFill;
@property (nonatomic, strong) UIImageView *knob;
@property (nonatomic, assign) BOOL wasTracking;
@property (nonatomic, assign) CGRect originalFrame;
@end
@implementation CTRLDoublePoleSwitch

- (id)initWithFrame:(CGRect)frame
{
    CGRect forcedFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 51, CGRectGetHeight(frame));
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
    self.topTrackOutline = [[UIView alloc] initWithFrame:CGRectMake(0, 1, CGRectGetWidth(self.frame), 31)];
    self.topTrackFill = [[UIView alloc] initWithFrame:self.topTrackOutline.frame];
    self.bottomTrackOutline = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-31-2, CGRectGetWidth(self.frame), 31)];
    self.bottomTrackFill = [[UIView alloc] initWithFrame:self.bottomTrackOutline.frame];
    
    CGRect topKnobFrame = CGRectMake(CGRectGetMinX(self.topTrackOutline.frame),
                                     CGRectGetMinY(self.topTrackOutline.frame),
                                     CGRectGetHeight(self.topTrackOutline.frame),
                                     CGRectGetHeight(self.topTrackOutline.frame));
    topKnobFrame = CGRectInset(topKnobFrame, 1, 1);
    
    self.knob = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breakerDoublePoleSwitch"]];
    self.knob.frame = CGRectMake(-5, -1, CGRectGetWidth(self.knob.frame), CGRectGetHeight(self.frame)+7);
    self.originalFrame = self.knob.frame;
    
    self.topTrackOutline.layer.cornerRadius = 15.5;
    self.topTrackFill.layer.cornerRadius = 15.5;
    self.bottomTrackOutline.layer.cornerRadius = 15.5;
    self.bottomTrackFill.layer.cornerRadius = 15.5;
    

    if (!self.tintColor) {
        self.tintColor = [[UIApplication sharedApplication] keyWindow].tintColor;
    }
    
    if (!self.onTintColor) {
        self.onTintColor = [[UIApplication sharedApplication] keyWindow].tintColor;
    }

    self.topTrackOutline.layer.borderWidth = 1.5;
    self.bottomTrackOutline.layer.borderWidth = 1.5;
    self.topTrackFill.layer.borderWidth = 0.0;
    self.bottomTrackFill.layer.borderWidth = 0.0;
    
    [self addSubview:self.topTrackFill];
    [self addSubview:self.topTrackOutline];
    [self addSubview:self.bottomTrackFill];
    [self addSubview:self.bottomTrackOutline];
    [self addSubview:self.knob];
    
    self.topTrackFill.userInteractionEnabled = NO;
    self.topTrackOutline.userInteractionEnabled = NO;
    self.bottomTrackFill.userInteractionEnabled = NO;
    self.bottomTrackOutline.userInteractionEnabled = NO;
    self.knob.userInteractionEnabled = NO;
    
    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self addObserver:self forKeyPath:@"onTintColor" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"tintColor" options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)setupColors
{

    self.topTrackFill.backgroundColor = [UIColor clearColor];
    self.bottomTrackFill.backgroundColor = [UIColor clearColor];
    self.topTrackOutline.layer.borderColor = [self.tintColor CGColor];
    self.bottomTrackOutline.layer.borderColor = [self.tintColor CGColor];
    self.topTrackFill.layer.borderColor = [self.tintColor CGColor];
    self.bottomTrackFill.layer.borderColor = [self.tintColor CGColor];
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    [self.onTintColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.topTrackOutline.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:.15];
    self.bottomTrackOutline.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:.15];
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
        [self.topTrackFill.layer addAnimation:fillAnimation forKey:@"borderWidth"];
        [self.bottomTrackFill.layer addAnimation:fillAnimation forKey:@"borderWidth"];
    }
    
    self.topTrackFill.layer.borderWidth = CGRectGetHeight(self.topTrackFill.frame);
    self.bottomTrackFill.layer.borderWidth = CGRectGetHeight(self.bottomTrackFill.frame);
}

- (void)drainTracksAnimated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        fillAnimation.duration = .3;
        [self.topTrackFill.layer addAnimation:fillAnimation forKey:@"borderWidth"];
        [self.bottomTrackFill.layer addAnimation:fillAnimation forKey:@"borderWidth"];
    }
    
    self.topTrackFill.layer.borderWidth = 0.0;
    self.bottomTrackFill.layer.borderWidth = 0.0;
}

- (void)moveKnobToOnPositionAnimated:(BOOL)animated resetSize:(BOOL)resetSize
{
    CGSize knobSize = self.knob.frame.size;

    if (resetSize) {
        knobSize = self.originalFrame.size;
    }
    
    CGFloat xOffset = CGRectGetWidth(self.topTrackOutline.frame)-36.0;
    
    if (!resetSize) {
        xOffset = CGRectGetWidth(self.topTrackOutline.frame)-42.0;
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
        knobSize = self.originalFrame.size;
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
- (void)touchDown:(CTRLDoublePoleSwitch *)tandemSwitch
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

- (void)touchUpInside:(CTRLDoublePoleSwitch *)tandemSwitch
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

- (void)touchUpOutside:(CTRLDoublePoleSwitch *)tandemSwitch
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

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    return YES;
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    CGPoint touchLocation = [touch locationInView:self];
//    if (touchLocation.x > CGRectGetWidth(self.frame)/2) {
//        [self moveKnobsToOnPositionAnimated:YES resetSize:NO];
//        self.on = YES;
//    }
//    else {
//        [self moveKnobsToOffPostionAnimated:YES resetSize:NO];
//        self.on = NO;
//    }
//
//    return YES;
//}
//
//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    self.wasTracking = YES;
//
//    if (self.on) {
//        [self moveKnobsToOnPositionAnimated:YES resetSize:YES];
//    }
//    else {
//        [self moveKnobsToOffPostionAnimated:YES resetSize:YES];
//    }
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"onTintColor"] || [keyPath isEqualToString:@"tintColor"]) {
        [self setupColors];
    }
}

@end
