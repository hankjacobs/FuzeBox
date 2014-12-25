//
//  CTRLPunchoutCell.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/3/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLPunchoutCell.h"

@implementation CTRLPunchoutCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [self.tintColor CGColor]);
    CGContextSetLineWidth(context, 1.0);
    //Outer rounded rect
    CGRect outerRect = CGRectInset(rect, 5, 5);
    UIBezierPath *outerRectPath = [UIBezierPath bezierPathWithRoundedRect:outerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
    outerRectPath.lineWidth = 1.0;
    [outerRectPath stroke];

    CGRect rightRect = CGRectInset(outerRect, (CGRectGetWidth(outerRect)-(CGRectGetWidth(outerRect)*.2))/2, 5);
    rightRect = CGRectOffset(rightRect, ((CGRectGetWidth(outerRect)-(CGRectGetWidth(outerRect)*.2))/2)-5, 0);
    UIBezierPath *rightRectPath = [UIBezierPath bezierPathWithRoundedRect:rightRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
    rightRectPath.lineWidth = 1.0;
    [rightRectPath stroke];
    
    CGRect centerRect = CGRectInset(outerRect, (CGRectGetWidth(outerRect)-(CGRectGetWidth(outerRect)*.55))/2, 5);
    centerRect.origin.x = CGRectGetMinX(rightRect)-CGRectGetWidth(centerRect)-5;
    UIBezierPath *centerRectPath = [UIBezierPath bezierPathWithRoundedRect:centerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
    centerRectPath.lineWidth = 1.0;
    [centerRectPath stroke];
    
    CGRect ellipseRect = CGRectInset(outerRect, 10, 5);
    ellipseRect.size.width = CGRectGetWidth(ellipseRect)*.18;
    UIBezierPath *ellipseRectPath = [UIBezierPath bezierPathWithRoundedRect:ellipseRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    ellipseRectPath.lineWidth = 1.0;
    [ellipseRectPath stroke];
    
    CGRect circleRect = CGRectInset(outerRect, 10, 5);
    circleRect.size.width = CGRectGetHeight(circleRect);
    circleRect.origin.x = CGRectGetMaxX(ellipseRect)-CGRectGetWidth(circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);

}


@end
