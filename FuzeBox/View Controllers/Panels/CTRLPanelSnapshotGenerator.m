//
//  CTRLPanelSnapshotGenerator.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/21/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLPanelSnapshotGenerator.h"
#import "Panel.h"
#import "Breaker.h"
#import "Breaker+Helpers.h"
#import "Panel+Helpers.h"

@implementation CTRLPanelSnapshotGenerator

+ (UIView *)snapshotForPanel:(Panel *)panel
{
    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 79, 180)];
    BOOL isHorizontal = (panel.panelType == PanelHorizontalDoubleRow || panel.panelType == PanelHorizontalSingleRow);

    if (isHorizontal) {
        if (panel.panelType == PanelHorizontalDoubleRow) {
            panelView.frame = CGRectMake(0, 0, 180, 128);
        }
        else {
            panelView.frame = CGRectMake(0, 0, 180, 79);
        }
    }
    else {
        if (panel.panelType == PanelVerticalDoubleRow) {
            panelView.frame = CGRectMake(0, 0, 128, 180);
        }
    }
    
    UIView *panelLayoutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 79, 180)];
    
    
    CGFloat offset = 0.0;
    NSArray *breakers = [panel.breakers sortedArrayUsingDescriptors:@[[NSSortDescriptor
                                                                       sortDescriptorWithKey:@"panelRow"
                                                                       ascending:YES]]];
    if (panel.panelType == PanelHorizontalDoubleRow || panel.panelType == PanelVerticalDoubleRow) {
        panelLayoutView.frame = CGRectMake(0, 0, 128, 180);
        panelLayoutView = [self formDoubleWidePanelLayoutViewWithBreakers:breakers
                                                                   inView:panelLayoutView
                                                                    panel:panel];
    }
    else {
        for (Breaker *breaker in breakers) {
            UIView *breakerView = [self breakerSnapshotForBreaker:breaker];

            breakerView.frame = CGRectOffset(breakerView.frame, 0.0, offset);
            offset += CGRectGetHeight(breakerView.frame);


            if (CGRectGetMaxY(breakerView.frame) > CGRectGetHeight(panelLayoutView.frame))
                break;
            
            [panelLayoutView addSubview:breakerView];
        }
        
        //Fill remainder with blanks
        while (offset < CGRectGetMaxY(panelLayoutView.frame)) {
            UIImageView *blankBreakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSingle"]];
            
            blankBreakerImage.frame = CGRectOffset(blankBreakerImage.frame, 0, offset);
            offset += CGRectGetHeight(blankBreakerImage.frame);
            
            if (CGRectGetMaxY(blankBreakerImage.frame) > CGRectGetHeight(panelLayoutView.frame))
                break;
            
            [panelLayoutView addSubview:blankBreakerImage];
        }
    }

    if (isHorizontal) {
        panelLayoutView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        panelLayoutView.center = panelView.center;
    }
    
    [panelView addSubview:panelLayoutView];
    
    
    return [panelView snapshotViewAfterScreenUpdates:YES];
}

+ (UIView *)formDoubleWidePanelLayoutViewWithBreakers:(NSArray *)breakers inView:(UIView *)panelLayoutView panel:(Panel *)panel
{
    CGFloat offset = 0.0;
    
    NSString *column1Predicate = @"panelColumn = 0";
    NSString *column2Predicate = @"panelColumn = 1";
    
    if (panel.panelType == PanelHorizontalDoubleRow) {
        NSString *temp = column1Predicate;
        column1Predicate = column2Predicate;
        column2Predicate = temp;
    }
    
    NSArray *column1 = [breakers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:column1Predicate]];
    NSArray *column2 = [breakers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:column2Predicate]];
    
    for (Breaker *breaker in column1) {
        UIView *breakerView = [self breakerSnapshotForBreaker:breaker];
        breakerView.frame = CGRectMake(0, 0, CGRectGetWidth(breakerView.frame)-20, CGRectGetHeight(breakerView.frame));
        
        breakerView.frame = CGRectOffset(breakerView.frame, 0.0, offset);
        offset += CGRectGetHeight(breakerView.frame);
        
        
        if (CGRectGetMaxY(breakerView.frame) > CGRectGetHeight(panelLayoutView.frame))
            break;
        
        [panelLayoutView addSubview:breakerView];
    }
    
    //Fill remainder with blanks
    while (offset < CGRectGetMaxY(panelLayoutView.frame)) {
        UIImageView *blankBreakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSingle"]];
        blankBreakerImage.frame = CGRectMake(0,
                                             0,
                                             CGRectGetWidth(blankBreakerImage.frame)-20,
                                             CGRectGetHeight(blankBreakerImage.frame));
        blankBreakerImage.frame = CGRectOffset(blankBreakerImage.frame, 0, offset);
        offset += CGRectGetHeight(blankBreakerImage.frame);
        
        if (CGRectGetMaxY(blankBreakerImage.frame) > CGRectGetHeight(panelLayoutView.frame))
            break;
        
        [panelLayoutView addSubview:blankBreakerImage];
    }

    offset = 0.0;
    
    for (Breaker *breaker in column2) {
        UIView *breakerView = [self breakerSnapshotForBreaker:breaker];
        breakerView.frame = CGRectMake(0, 0, CGRectGetWidth(breakerView.frame)-20, CGRectGetHeight(breakerView.frame));
        
        breakerView.frame = CGRectOffset(breakerView.frame, 69.0, offset);
        offset += CGRectGetHeight(breakerView.frame);
        
        
        if (CGRectGetMaxY(breakerView.frame) > CGRectGetHeight(panelLayoutView.frame))
            break;
        
        [panelLayoutView addSubview:breakerView];
    }
    
    //Fill remainder with blanks
    while (offset < CGRectGetMaxY(panelLayoutView.frame)) {
        UIImageView *blankBreakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSingle"]];
        blankBreakerImage.frame = CGRectMake(0,
                                             0,
                                             CGRectGetWidth(blankBreakerImage.frame)-20,
                                             CGRectGetHeight(blankBreakerImage.frame));
        blankBreakerImage.frame = CGRectOffset(blankBreakerImage.frame, 69.0, offset);
        offset += CGRectGetHeight(blankBreakerImage.frame);
        
        if (CGRectGetMaxY(blankBreakerImage.frame) > CGRectGetHeight(panelLayoutView.frame))
            break;
        
        [panelLayoutView addSubview:blankBreakerImage];
    }
    
    return panelLayoutView;
}

+ (UIView *)breakerSnapshotForBreaker:(Breaker *)breaker
{
    UIView *breakerImage;
    
    if (breaker.amperage.intValue < 30 || (breaker.amperage.intValue == 30 && !breaker.isDoublePole)) {
        
        if (!breaker.isPunchout) {
            breakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSingleWithName"]];
            UIImageView *breakerSwitchCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSwitchCircle"]];
            breakerSwitchCircle.frame = CGRectOffset(breakerSwitchCircle.frame, 0, -.5);
            breakerSwitchCircle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *breakerSwitchRingImage = [UIImage imageNamed:@"miniBreakerSwitchRing"];
            breakerSwitchRingImage = [breakerSwitchRingImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *breakerSwitchRing = [[UIImageView alloc] initWithImage:breakerSwitchRingImage];
            breakerSwitchRing.tintColor = breaker.color;
            breakerSwitchRing.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            
            breakerSwitchRing.frame = CGRectOffset(breakerSwitchRing.frame, 5, 0);
            breakerSwitchCircle.frame = CGRectOffset(breakerSwitchCircle.frame, 4, 0);
            [breakerSwitchRing addSubview:breakerSwitchCircle];
            
            breakerSwitchRing.center = CGPointMake(breakerSwitchRing.center.x, breakerImage.center.y-.5);
            [breakerImage addSubview:breakerSwitchRing];
            
            if (breaker.switchOrientation == SwitchOrientationRight) {
                breakerImage.layer.transform = CATransform3DMakeRotation(M_PI,0.0,1.0,0.0);
            }
        }
        else {
            breakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSingle"]];
        }
    }
    else if (breaker.amperage.intValue >= 30 && breaker.amperage.intValue < 60) {
        if (!breaker.isPunchout) {
            
            breakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerDoubleWithName"]];
            UIImageView *breakerSwitchBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSwitchBar2"]];
            breakerSwitchBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *breakerSwitchRingTopImage = [UIImage imageNamed:@"miniBreakerSwitchRing"];
            breakerSwitchRingTopImage = [breakerSwitchRingTopImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *breakerSwitchRingTop = [[UIImageView alloc] initWithImage:breakerSwitchRingTopImage];
            breakerSwitchRingTop.tintColor = breaker.color;
            breakerSwitchRingTop.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *breakerSwitchRingBottomImage = [UIImage imageNamed:@"miniBreakerSwitchRing"];
            breakerSwitchRingBottomImage = [breakerSwitchRingBottomImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *breakerSwitchRingBottom = [[UIImageView alloc] initWithImage:breakerSwitchRingTopImage];
            breakerSwitchRingBottom.tintColor = breaker.color;
            breakerSwitchRingBottom.autoresizingMask = UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleLeftMargin;

            breakerSwitchRingTop.frame = CGRectOffset(breakerSwitchRingTop.frame, 5, 1.5);
            breakerSwitchRingBottom.frame = CGRectOffset(breakerSwitchRingBottom.frame,
                                                         5,
                                                         CGRectGetMaxY(breakerSwitchRingTop.frame)+4);
            breakerSwitchBar.frame = CGRectOffset(breakerSwitchBar.frame, 9, 1);

            
            [breakerImage addSubview:breakerSwitchRingTop];
            [breakerImage addSubview:breakerSwitchRingBottom];
            [breakerImage addSubview:breakerSwitchBar];
            
            if (breaker.switchOrientation == SwitchOrientationRight) {
                breakerImage.layer.transform = CATransform3DMakeRotation(M_PI,0.0,1.0,0.0);
            }
        }
        else {
            breakerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerDouble"]];
        }
    }
    else {
        
        UIImageView *breakerImageTop = nil;
        if (breaker.isPunchout) {
           breakerImageTop = [[UIImageView alloc] initWithImage:
               [UIImage imageNamed:@"miniBreakerDouble"]];
        }
        else {
            breakerImageTop = [[UIImageView alloc] initWithImage:
                               [UIImage imageNamed:@"miniBreakerDoubleWithName"]];
        }
        breakerImageTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIImageView *breakerImageBottom = nil;
        if (breaker.isPunchout) {
            breakerImageBottom = [[UIImageView alloc] initWithImage:
                               [UIImage imageNamed:@"miniBreakerDouble"]];
        }
        else {
            breakerImageBottom = [[UIImageView alloc] initWithImage:
                               [UIImage imageNamed:@"miniBreakerDoubleWithName"]];
        }
        breakerImageBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        breakerImage = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                CGRectGetWidth(breakerImageTop.frame),
                                                                CGRectGetHeight(breakerImageTop.frame)*2)];
        breakerImageBottom.frame = CGRectOffset(breakerImageBottom.frame, 0, CGRectGetMaxY(breakerImageTop.frame));
        
        [breakerImage addSubview:breakerImageTop];
        [breakerImage addSubview:breakerImageBottom];
        
        if (!breaker.isPunchout) {
            UIImageView *breakerSwitchBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniBreakerSwitchBar4"]];
            breakerSwitchBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *breakerSwitchRingTopImage = [UIImage imageNamed:@"miniBreakerSwitchRing"];
            breakerSwitchRingTopImage = [breakerSwitchRingTopImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *breakerSwitchRingTop = [[UIImageView alloc] initWithImage:breakerSwitchRingTopImage];
            breakerSwitchRingTop.tintColor = breaker.color;
            breakerSwitchRingTop.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *breakerSwitchRingBottomImage = [UIImage imageNamed:@"miniBreakerSwitchRing"];
            breakerSwitchRingBottomImage = [breakerSwitchRingBottomImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *breakerSwitchRingBottom = [[UIImageView alloc] initWithImage:breakerSwitchRingTopImage];
            breakerSwitchRingBottom.tintColor = breaker.color;
            breakerSwitchRingBottom.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
            
            breakerSwitchRingTop.frame = CGRectOffset(breakerSwitchRingTop.frame, 5, 0);
            breakerSwitchRingTop.center = CGPointMake(breakerSwitchRingTop.center.x, breakerImageTop.center.y);
            
            breakerSwitchRingBottom.frame = CGRectOffset(breakerSwitchRingBottom.frame,
                                                         5,
                                                         0);
            breakerSwitchRingBottom.center = CGPointMake(breakerSwitchRingBottom.center.x,
                                                         breakerImageBottom.center.y);
            breakerSwitchBar.frame = CGRectOffset(breakerSwitchBar.frame,
                                                  9,
                                                  CGRectGetMinY(breakerSwitchRingTop.frame));
            
            [breakerImage addSubview:breakerSwitchRingTop];
            [breakerImage addSubview:breakerSwitchRingBottom];
            [breakerImage addSubview:breakerSwitchBar];
            
            if (breaker.switchOrientation == SwitchOrientationRight) {
                breakerImage.layer.transform = CATransform3DMakeRotation(M_PI,0.0,1.0,0.0);
            }
        }
    }
    
    breakerImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return breakerImage;
}

@end
