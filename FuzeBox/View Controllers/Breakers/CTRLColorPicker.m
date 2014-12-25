//
//  CTRLColorPicker.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/8/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLColorPicker.h"
#import "UIColor+UIColorFromRGB.h"

static NSArray *generateDefaultColors()
{
    return @[[UIColor colorWithR:156 g:0 b:2],
             [UIColor colorWithR:0 g:128 b:0],
             [UIColor colorWithR:0 g:0 b:114],
             [UIColor colorWithR:80 g:0 b:164],
             [UIColor colorWithR:109 g:109 b:109],
             [UIColor colorWithR:0 g:0 b:0],
             [UIColor colorWithR:251 g:0 b:6],
             [UIColor colorWithR:89 g:178 b:38],
             [UIColor colorWithR:17 g:56 b:204],
             [UIColor colorWithR:122 g:0 b:203],
             [UIColor colorWithR:135 g:135 b:135],
             [UIColor colorWithR:20 g:20 b:20],
             [UIColor colorWithR:252 g:110 b:125],
             [UIColor colorWithR:76 g:217 b:100],
             [UIColor colorWithR:70 g:100 b:248],
             [UIColor colorWithR:150 g:69 b:198],
             [UIColor colorWithR:164 g:164 b:164],
             [UIColor colorWithR:39 g:39 b:39],
             [UIColor colorWithR:252 g:128 b:7],
             [UIColor colorWithR:181 g:255 b:27],
             [UIColor colorWithR:14 g:108 b:255],
             [UIColor colorWithR:197 g:121 b:242],
             [UIColor colorWithR:192 g:193 b:192],
             [UIColor colorWithR:60 g:60 b:60],
             [UIColor colorWithR:253 g:183 b:87],
             [UIColor colorWithR:206 g:255 b:94],
             [UIColor colorWithR:128 g:201 b:255],
             [UIColor colorWithR:233 g:193 b:255],
             [UIColor colorWithR:224 g:224 b:224],
             [UIColor colorWithR:83 g:83 b:83],
             [UIColor colorWithR:253 g:247 b:84],
             [UIColor colorWithR:237 g:255 b:189],
             [UIColor colorWithR:158 g:227 b:252],
             [UIColor colorWithR:253 g:183 b:255],
             [UIColor colorWithR:255 g:255 b:255],
             [UIColor colorWithR:108 g:108 b:108]];
}

@interface CTRLColorPicker ()

@property (nonatomic, readwrite) NSArray *colors;
@property (nonatomic, strong) NSMutableArray *colorViews;
@property (nonatomic, strong) UIView *selectedColorView;

@end

@implementation CTRLColorPicker

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setUpControlWithColors:nil];
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame colors:nil];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpControlWithColors:colors];
    }
    
    return self;
}

- (void)setUpControlWithColors:(NSArray *)colors
{
    self.colorViews = [NSMutableArray array];
    
    if (colors)
        self.colors = [colors mutableCopy];
    else
        self.colors = generateDefaultColors();
    
    [self formColorViews];
    self.selectedColorIndex = 1;
}

- (void)formColorViews
{
    for (UIColor *color in self.colors) {
        CGRect colorRect = [self rectForColorAtIndex:[self.colors indexOfObject:color]];
        UIView *colorView = [[UIView alloc] initWithFrame:colorRect];
        colorView.backgroundColor = color;
        colorView.userInteractionEnabled = NO;
        [self.colorViews addObject:colorView];
        [self addSubview:colorView];
    }
}

- (CGRect)rectForColorAtIndex:(NSInteger)index
{
    int columnCount = 6;
    if (self.colors.count % columnCount != 0) {
        if (self.colors.count % columnCount > 6) {
            columnCount += columnCount % 6;
        }
        else {
            columnCount -= columnCount % 6;
        }
    }
    
    int rowCount = 6;
    if (self.colors.count % rowCount != 0) {
        if (self.colors.count % rowCount > 6) {
            rowCount += rowCount % 6;
        }
        else {
            rowCount -= rowCount % 6;
        }
    }
    
    int column = (index%columnCount)%columnCount;
    int row = floor(index/rowCount);
    
    CGFloat width = CGRectGetWidth(self.frame)/columnCount;
    CGFloat height = CGRectGetHeight(self.frame)/rowCount;
    
    CGFloat xPos = width * column;
    CGFloat yPos = height * row;
    
    return CGRectMake(xPos, yPos, width, height);
}

#pragma mark - Color Setter
- (void)setSelectedColorIndex:(NSInteger)selectedColorIndex
{
    if (selectedColorIndex >= 0 && selectedColorIndex < self.colorViews.count) {
        _selectedColorIndex = selectedColorIndex;
        
        UIView *colorView = [self.colorViews objectAtIndex:selectedColorIndex];
        self.selectedColorView = colorView;
        
        colorView.layer.borderColor = [UIColor whiteColor].CGColor;
        colorView.layer.borderWidth = 1.0;
        
        
        [self setNeedsDisplay];
    }
    else {
        _selectedColorIndex = 0;
        
        UIView *colorView = [self.colorViews objectAtIndex:_selectedColorIndex];
        self.selectedColorView = colorView;
        
        colorView.layer.borderColor = [UIColor whiteColor].CGColor;
        colorView.layer.borderWidth = 1.0;
        
        
        [self setNeedsDisplay];
    }
}

- (void)setSelectedColorView:(UIView *)selectedColorView
{
    if (_selectedColorView) {
        _selectedColorView.layer.borderColor = nil;
        _selectedColorView.layer.borderWidth = 0;
    }
    
    _selectedColorView = selectedColorView;
}

#pragma mark - View Life Cycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIColor *color in self.colors) {
        NSInteger colorIndex = [self.colors indexOfObject:color];
        UIView *colorView = [self.colorViews objectAtIndex:[self.colors indexOfObject:color]];
        colorView.frame = [self rectForColorAtIndex:colorIndex];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];

    UIView *tappedView = nil;
    
    for (UIView *subview in self.subviews)
    {
        CGPoint point = [self convertPoint:location toView:subview];
        if ([subview pointInside:point withEvent:nil]) {
            tappedView = subview;
        }
    }
    
    if (tappedView  && [self.colorViews containsObject:tappedView]) {
        NSInteger selectedIndex = [self.colorViews indexOfObject:tappedView];
        
        if (self.selectedColorIndex != selectedIndex) {
            [self setSelectedColorIndex:selectedIndex];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    
}

@end
