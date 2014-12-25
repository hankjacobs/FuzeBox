//
//  CTRLDoublePoleSwitch.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/30/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLTandemSwitch.h"

@interface CTRLTandemSwitch ()

@property (nonatomic, strong) UIView *trackingView;
@property (nonatomic, strong) UIView *topTrackOutline;
@property (nonatomic, strong) UIView *topTrackFill;
@property (nonatomic, strong) UIView *bottomTrackOutline;
@property (nonatomic, strong) UIView *bottomTrackFill;
@property (nonatomic, strong) UIImageView *topKnob;
@property (nonatomic, strong) UIImageView *bottomKnob;
@property (nonatomic, assign) BOOL wasTracking;

@end

@implementation CTRLTandemSwitch

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
    self.trackingView = [[UIView alloc] initWithFrame:self.frame];
    self.topTrackOutline = [[UIView alloc] initWithFrame:CGRectMake(0, 1, CGRectGetWidth(self.frame), 13)];
    self.topTrackFill = [[UIView alloc] initWithFrame:self.topTrackOutline.frame];
    self.bottomTrackOutline = [[UIView alloc] initWithFrame:CGRectMake(0, 18, CGRectGetWidth(self.frame), 13)];
    self.bottomTrackFill = [[UIView alloc] initWithFrame:self.bottomTrackOutline.frame];
    
    CGRect topKnobFrame = CGRectMake(CGRectGetMinX(self.topTrackOutline.frame),
                                     CGRectGetMinY(self.topTrackOutline.frame),
                                     CGRectGetHeight(self.topTrackOutline.frame),
                                     CGRectGetHeight(self.topTrackOutline.frame));
    topKnobFrame = CGRectInset(topKnobFrame, 1, 1);
    
    CGRect bottomKnobFrame = CGRectMake(CGRectGetMinX(self.bottomTrackOutline.frame),
                                     CGRectGetMinY(self.bottomTrackOutline.frame),
                                     CGRectGetHeight(self.bottomTrackOutline.frame),
                                     CGRectGetHeight(self.bottomTrackOutline.frame));
    bottomKnobFrame = CGRectInset(bottomKnobFrame, 1, 1);
    
    self.topKnob = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breakerTandemSwitch"]];
    self.bottomKnob = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breakerTandemSwitch"]];
    
    self.topKnob.center = CGPointMake(7 + CGRectGetMinX(self.topTrackOutline.frame), 9.25 + CGRectGetMinY(self.topTrackOutline.frame));
    self.bottomKnob.center = CGPointMake(7 + CGRectGetMinX(self.bottomTrackOutline.frame), 9.25 + CGRectGetMinY(self.bottomTrackOutline.frame));
    
    self.topTrackOutline.layer.cornerRadius = 7;
    self.topTrackFill.layer.cornerRadius = 7;
    self.bottomTrackOutline.layer.cornerRadius = 7;
    self.bottomTrackFill.layer.cornerRadius = 7;
    
    if (self.on) {
        self.topTrackFill.backgroundColor = self.onTintColor;
        self.bottomTrackFill.backgroundColor = self.onTintColor;
    }
    else {
        self.topTrackFill.backgroundColor = [UIColor clearColor];
        self.bottomTrackFill.backgroundColor = [UIColor clearColor];
    }
    
    if (!self.tintColor) {
        self.tintColor = [[UIApplication sharedApplication] keyWindow].tintColor;
    }
    
    if (!self.onTintColor) {
        self.onTintColor = [[UIApplication sharedApplication] keyWindow].tintColor;
    }
    
    self.topTrackOutline.layer.borderColor = [self.tintColor CGColor];
    self.bottomTrackOutline.layer.borderColor = [self.tintColor CGColor];
    self.topTrackFill.layer.borderColor = [self.tintColor CGColor];
    self.bottomTrackFill.layer.borderColor = [self.tintColor CGColor];
    
    self.topTrackOutline.layer.borderWidth = 1.0;
    self.bottomTrackOutline.layer.borderWidth = 1.0;
    self.topTrackFill.layer.borderWidth = 0.0;
    self.bottomTrackFill.layer.borderWidth = 0.0;
    
    [self addSubview:self.topTrackFill];
    [self addSubview:self.topTrackOutline];
    [self addSubview:self.bottomTrackFill];
    [self addSubview:self.bottomTrackOutline];
    [self addSubview:self.topKnob];
    [self addSubview:self.bottomKnob];
    [self addSubview:self.trackingView];
    
    self.topTrackFill.userInteractionEnabled = NO;
    self.topTrackOutline.userInteractionEnabled = NO;
    self.bottomTrackFill.userInteractionEnabled = NO;
    self.bottomTrackOutline.userInteractionEnabled = NO;
    self.topKnob.userInteractionEnabled = NO;
    self.bottomKnob.userInteractionEnabled = NO;
    self.trackingView.userInteractionEnabled = NO;
    
    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self addObserver:self forKeyPath:@"onTintColor" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"tintColor" options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)setupColors
{
    if (self.on) {
        self.topTrackFill.backgroundColor = self.onTintColor;
        self.bottomTrackFill.backgroundColor = self.onTintColor;
    }
    else {
        self.topTrackFill.backgroundColor = [UIColor clearColor];
        self.bottomTrackFill.backgroundColor = [UIColor clearColor];
    }
    
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
        [self moveKnobsToOnPositionAnimated:animated resetSize:YES];
        [self fillTracksAnimated:animated];
    }
    else {
        [self moveKnobsToOffPostionAnimated:animated resetSize:YES];
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

- (void)moveKnobsToOnPositionAnimated:(BOOL)animated resetSize:(BOOL)resetSize
{
    CGSize topKnobSize = self.topKnob.frame.size;
    CGSize bottomKnobSize = self.bottomKnob.frame.size;
    
    if (resetSize) {
        topKnobSize = self.topKnob.image.size;
        bottomKnobSize = self.bottomKnob.image.size;
    }
    
    CGFloat xOffset = CGRectGetWidth(self.topTrackOutline.frame)-18.5;
    
    if (!resetSize) {
        xOffset = CGRectGetWidth(self.topTrackOutline.frame)-24.5;
    }
    
    CGRect topFrame = CGRectMake(xOffset,
                          CGRectGetMinY(self.topKnob.frame),
                          self.topKnob.image.size.width,
                          CGRectGetHeight(self.topKnob.frame));
    CGRect bottomFrame = CGRectMake(xOffset,
                             CGRectGetMinY(self.bottomKnob.frame),
                             self.bottomKnob.image.size.width,
                             CGRectGetHeight(self.bottomKnob.frame));
    
    topFrame.size = topKnobSize;
    bottomFrame.size = bottomKnobSize;

    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            self.topKnob.frame = topFrame;
            self.bottomKnob.frame = bottomFrame;
        }];
    }
    else {
        self.topKnob.frame = topFrame;
        self.bottomKnob.frame = bottomFrame;
    }
}

- (void)moveKnobsToOffPostionAnimated:(BOOL)animated resetSize:(BOOL)resetSize
{
    CGSize topKnobSize = self.topKnob.frame.size;
    CGSize bottomKnobSize = self.bottomKnob.frame.size;
    
    if (resetSize) {
        topKnobSize = self.topKnob.image.size;
        bottomKnobSize = self.bottomKnob.image.size;
    }

    
    CGRect topFrame = CGRectMake(-5,
                          CGRectGetMinY(self.topKnob.frame),
                          self.topKnob.image.size.width,
                          CGRectGetHeight(self.topKnob.frame));
    CGRect bottomFrame = CGRectMake(-5,
                             CGRectGetMinY(self.bottomKnob.frame),
                             self.bottomKnob.image.size.width,
                             CGRectGetHeight(self.bottomKnob.frame));
    
    topFrame.size = topKnobSize;
    bottomFrame.size = bottomKnobSize;

    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            self.topKnob.frame = topFrame;
            self.bottomKnob.frame = bottomFrame;
        }];
    }
    else {
        self.topKnob.frame = topFrame;
        self.bottomKnob.frame = bottomFrame;
    }
}

#pragma mark - Touch Handling
- (void)touchDown:(CTRLTandemSwitch *)tandemSwitch
{
    if (!self.isOn) {
        [self fillTracksAnimated:YES];
    }
    
    CGFloat xOffset = 0.0;
    
    if (self.isOn) {
        xOffset = .25 * CGRectGetWidth(self.topKnob.frame);
    }
    
    [UIView animateWithDuration:.3 animations:^{
        self.topKnob.frame = CGRectMake(CGRectGetMinX(self.topKnob.frame)-xOffset,
                                        CGRectGetMinY(self.topKnob.frame),
                                        CGRectGetWidth(self.topKnob.frame)*1.25,
                                        CGRectGetHeight(self.topKnob.frame));
        self.bottomKnob.frame = CGRectMake(CGRectGetMinX(self.bottomKnob.frame)-xOffset,
                                           CGRectGetMinY(self.bottomKnob.frame),
                                           CGRectGetWidth(self.bottomKnob.frame)*1.25,
                                           CGRectGetHeight(self.bottomKnob.frame));
        }];
}

- (void)touchUpInside:(CTRLTandemSwitch *)tandemSwitch
{
    if (self.wasTracking) {
        self.wasTracking = NO;
        return;
    }
    
    if (!self.isOn) {
        [self moveKnobsToOnPositionAnimated:YES resetSize:YES];
    }
    else {
        [self moveKnobsToOffPostionAnimated:YES resetSize:YES];
        [self drainTracksAnimated:YES];
    }
    
    _on = !self.isOn;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchUpOutside:(CTRLTandemSwitch *)tandemSwitch
{
    if (self.wasTracking) {
        self.wasTracking = NO;
        return;
    }
    
    if (!self.isOn) {
        [self drainTracksAnimated:YES];
        [self moveKnobsToOffPostionAnimated:YES resetSize:YES];
    }
    else {
        [self moveKnobsToOnPositionAnimated:YES resetSize:YES];
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
