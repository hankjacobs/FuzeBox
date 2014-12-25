//
//  CTRPanelCollectionViewCell.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/28/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLPanelCollectionViewCell.h"
#import "UIColor+UIColorFromRGB.h"

@interface CTRLPanelCollectionViewCell ()

@property (nonatomic, readwrite) UIImageView *panelImageView;
@property (nonatomic, strong) UIButton *panelNameBadge;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation CTRLPanelCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self instantiateCell];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self instantiateCell];
    }
    return self;
}

- (void)dealloc
{
    [self.panelImageView removeObserver:self forKeyPath:@"image"];
}

#pragma Layout

- (void)instantiateCell
{
    self.backgroundColor = [UIColor clearColor];
    self.panelImageView = [[UIImageView alloc] init];
    self.panelImageView.center = self.contentView.center;
    self.panelImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.panelImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.panelImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.panelNameBadge = [UIButton buttonWithType:UIButtonTypeCustom];
    self.panelNameBadge.userInteractionEnabled = NO;
    self.panelNameBadge.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                          |UIViewAutoresizingFlexibleRightMargin
                                          |UIViewAutoresizingFlexibleLeftMargin;
    
    self.panelNameBadge.titleLabel.font = [UIFont systemFontOfSize:12];
    self.panelNameBadge.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.panelNameBadge.userInteractionEnabled = NO;
    [self.panelNameBadge setBackgroundImage:[UIImage imageNamed:@"panelNameBadgeWhite"] forState:UIControlStateNormal];
    [self.panelNameBadge setTitleColor:[UIColor colorWithR:141 g:141 b:141]
                              forState:UIControlStateNormal];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.frame = CGRectMake(0, 0, 25, 25);
    [self.deleteButton setImage:[UIImage imageNamed:@"panelDeleteBadge"] forState:UIControlStateNormal];
    [self.deleteButton setImage:[UIImage imageNamed:@"panelDeleteBadgePressed"] forState:UIControlStateSelected];
    [self.deleteButton addTarget:self
                          action:@selector(deleteButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.hidden = YES;
    
    [self.contentView addSubview:self.panelImageView];
    [self.contentView addSubview:self.panelNameBadge];
    [self.contentView addSubview:self.deleteButton];
}

- (void)layoutSubviews
{
    self.panelImageView.center = self.contentView.center;
    self.panelSnapshot.center = self.contentView.center;
    
    CGRect panelNameBadgeFrame = self.panelNameBadge.frame;
    panelNameBadgeFrame.origin.y =  CGRectGetMaxY(self.panelImageView.frame)+10;
    
    self.panelNameBadge.frame = panelNameBadgeFrame;
    
    self.panelNameBadge.center = CGPointMake(self.contentView.center.x,
                                             self.panelNameBadge.center.y);
    
    self.deleteButton.center = CGPointMake(CGRectGetMinX(self.panelImageView.frame),
                                           CGRectGetMinY(self.panelImageView.frame));
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setEditing:NO];
    
    self.panelSnapshot = nil;
    self.panelImageView.image = nil;
    self.panelName = nil;
}

#pragma mark - Setters

- (void)setPanelName:(NSString *)panelName
{
    NSDictionary *attributes = @{NSFontAttributeName: self.panelNameBadge.titleLabel.font};
    
    CGRect rect = [panelName boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.contentView.bounds)-60,
                                                             MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    
    self.panelNameBadge.frame = CGRectMake(CGRectGetMinX(self.panelNameBadge.frame),
                                           CGRectGetMinY(self.panelNameBadge.frame),
                                           rect.size.width+40,
                                           25);
    
    [self.panelNameBadge setTitle:panelName forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setPanelSnapshot:(UIView *)panelSnapshot
{
    [self.panelSnapshot removeFromSuperview];
    
    _panelSnapshot = panelSnapshot;
    self.panelSnapshot.center = self.panelImageView.center;
    self.panelSnapshot.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.contentView insertSubview:self.panelSnapshot aboveSubview:self.panelImageView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"image"]) {
        if (self.panelImageView.image) {
            CGRect newFrame = self.panelImageView.frame;
            newFrame.size.height = self.panelImageView.image.size.height;
            newFrame.size.width = self.panelImageView.image.size.width;
            self.panelImageView.frame = newFrame;
            self.panelImageView.center = self.contentView.center;
            [self setNeedsLayout];
        }
    }
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    void (^styleBlock)();
    void (^completionBlock)(BOOL completed) = ^(BOOL completed){};
    if (editing) {
        self.deleteButton.alpha = 0.0;
        styleBlock = ^{
            [self.panelNameBadge setBackgroundImage:[UIImage imageNamed:@"panelNameBadgeGrey"]
                                           forState:UIControlStateNormal];
            [self.panelNameBadge setTitleColor:[UIColor whiteColor]
                                      forState:UIControlStateNormal];
            self.deleteButton.alpha = 1.0;
            self.deleteButton.hidden = NO;
        };
    }
    else {
        styleBlock = ^{

            [self.panelNameBadge setBackgroundImage:[UIImage imageNamed:@"panelNameBadgeWhite"]
                                           forState:UIControlStateNormal];
            [self.panelNameBadge setTitleColor:[UIColor colorWithR:141 g:141 b:141]
                                      forState:UIControlStateNormal];
            self.deleteButton.alpha = 0.0;
        };
        completionBlock = ^(BOOL completed) {
            if (completed) {
                self.deleteButton.hidden = YES;
                self.deleteButton.alpha = 1.0;
            }
        };
    }
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:styleBlock completion:completionBlock];
    }
    else {
        styleBlock();
        completionBlock(YES);
    }
}

- (void)deleteButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(panelCellDeleteButtonWasTapped:)]) {
        [self.delegate panelCellDeleteButtonWasTapped:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
