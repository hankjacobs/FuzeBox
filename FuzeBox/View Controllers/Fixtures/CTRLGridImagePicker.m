//
//  CTRLGridImagePicker.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLGridImagePicker.h"

NSInteger const CTRLGridImagePickerInvalidIndex = -1;

@interface CTRLGridImagePicker ()

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, strong) UIView *lines;

@end
@implementation CTRLGridImagePicker

- (id)initWithFrame:(CGRect)frame images:(NSArray *)images selectedImages:(NSArray *)selectedImages
{
    self = [super initWithFrame:frame];
    if (self) {
        self.images = images;
        self.selectedImages = selectedImages;
        self.selectedIndex = CTRLGridImagePickerInvalidIndex;
        [self setUpControlWithImages:self.images];
    }
    return self;
}

- (void)setUpControlWithImages:(NSArray *)images
{
    self.imageViews = [self generateImageViewsWithImages:images];
    
    for (UIView *view in self.imageViews) {
        [self addSubview:view];
    }
    
    [self generateLines];
}

- (NSArray *)generateImageViewsWithImages:(NSArray *)images
{
    NSMutableArray *imageViews = [NSMutableArray array];
    for (UIImage *image in images) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tintColor = [UIColor colorWithRed:.737 green:.737 blue:.737 alpha:1.0];
        [imageViews addObject:imageView];
    }
    
    if (imageViews.count % 4) {
        NSInteger remainder = 4 - (imageViews.count % 4);
        
        for (int i = 0; i < remainder; i++) {
            //should probably calculate this based off of the average size of the images, etc, etc
            UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
            [imageViews addObject:dummyView];
        }
    }
    
    return imageViews;
}

- (void)generateLines
{
    [self.lines removeFromSuperview];
    
    self.lines = [[UIView alloc] initWithFrame:self.bounds];
    self.lines.backgroundColor = [UIColor clearColor];
    self.lines.userInteractionEnabled = NO;
    
    for (int i = 1; i < 4; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.frame))];
        line.frame = CGRectOffset(line.frame, i*80, 0);
        line.backgroundColor = [UIColor colorWithRed:.737 green:.737 blue:.737 alpha:1.0];
        
        [self.lines addSubview:line];
    }
    
    
    for (int i = 1; i < floor(self.imageViews.count/4); i++)
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
        line.frame = CGRectOffset(line.frame, 0, i*80);
        line.backgroundColor = [UIColor colorWithRed:.737 green:.737 blue:.737 alpha:1.0];
        
        [self.lines addSubview:line];
    }
    
    [self insertSubview:self.lines atIndex:0];
}

- (void)layoutSubviews
{
    for (UIView *view in self.imageViews) {
        NSInteger index = [self.imageViews indexOfObject:view];
        NSInteger columnNumber = index % 4;
        NSInteger rowNumber = floor(index/4);
        view.frame = CGRectMake(columnNumber * CGRectGetWidth(self.frame)/4,
                                rowNumber * CGRectGetWidth(self.frame)/4,
                                CGRectGetWidth(view.frame),
                                CGRectGetHeight(view.frame));
    }
    
    [self generateLines];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex >= 0 && selectedIndex < self.imageViews.count) {
        
        UIImageView *imageView = [self.imageViews objectAtIndex:selectedIndex];
        
        if ([imageView isKindOfClass:[UIImageView class]]) {
            
            if (_selectedIndex != CTRLGridImagePickerInvalidIndex) {
                UIImageView *oldImageView = [self.imageViews objectAtIndex:_selectedIndex];
                oldImageView.tintColor = [UIColor colorWithRed:.737 green:.737 blue:.737 alpha:1.0];
                oldImageView.image = [self.images objectAtIndex:_selectedIndex];
            }
            
            imageView.image = [self.selectedImages objectAtIndex:selectedIndex];
            imageView.tintColor = [UIColor colorWithRed:.2588 green:.835 blue:.3176 alpha:1.0];
            _selectedIndex = selectedIndex;
        }
    }
    else {
       _selectedIndex = CTRLGridImagePickerInvalidIndex;
    }
}

#pragma mark - Touch Events

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
    
    if (tappedView  && [self.imageViews containsObject:tappedView] && [tappedView isMemberOfClass:[UIImageView class]]) {
        NSInteger selectedIndex = [self.imageViews indexOfObject:tappedView];
        
        if (self.selectedIndex != selectedIndex) {
            self.selectedIndex = selectedIndex;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    
}

@end
