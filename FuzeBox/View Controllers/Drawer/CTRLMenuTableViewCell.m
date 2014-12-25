//
//  CTRLMenuTableViewCell.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/26/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLMenuTableViewCell.h"
#import "UIColor+UIColorFromRGB.h"

@interface CTRLMenuTableViewCell ()

@property (nonatomic, strong) NSArray *indentationConstraints;

@end
@implementation CTRLMenuTableViewCell
@synthesize indentationLevel = _indentationLevel;
@synthesize indentationWidth = _indentationWidth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell
{
    self.backgroundColor = [UIColor colorWithR:131 g:131 b:131];
    
    [self willChangeValueForKey:@"menuImageView"];
    _menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 23, 24)];
    [self didChangeValueForKey:@"menuImageView"];
    
    self.menuImageView.center = CGPointMake(self.menuImageView.center.x, self.contentView.center.y);
    self.menuImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.menuImageView.tintColor = [UIColor whiteColor];
    self.menuImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.menuImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.menuImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:21]];
    [self.menuImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.menuImageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:18]];
    
    _menuTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(45,
                                                               0,
                                                               CGRectGetWidth(self.contentView.bounds)-45,
                                                               CGRectGetHeight(self.contentView.bounds))];
    self.menuTextLabel.center = CGPointMake(self.menuTextLabel.center.x, self.contentView.center.y);
    self.menuTextLabel.backgroundColor = [UIColor clearColor];
    self.menuTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.menuTextLabel.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:self.menuImageView];
    [self.contentView addSubview:self.menuTextLabel];

    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIApplication sharedApplication].keyWindow.tintColor;
    self.selectedBackgroundView = selectedView;

    self.indentationWidth = 15;
    self.indentationLevel = 0;

}

- (void)setIndentationLevel:(NSInteger)indentationLevel
{
    _indentationLevel = indentationLevel;
    
    if (self.indentationConstraints)
        [self.contentView removeConstraints:self.indentationConstraints];
    
    [self generateIdentationConstraint];
}

- (void)setIndentationWidth:(CGFloat)indentationWidth
{
    _indentationWidth = indentationWidth;
    if (self.indentationConstraints)
        [self.contentView removeConstraints:self.indentationConstraints];
    
    [self generateIdentationConstraint];
}

- (void)generateIdentationConstraint
{
    CGFloat indentTotal = self.indentationLevel*self.indentationWidth;
    indentTotal = (indentTotal ? indentTotal : 15.0);
    
    NSString *visualFormat = [NSString stringWithFormat:@"|-%f-[imageView]-15-[textLabel]", indentTotal];
    self.indentationConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                         options:0
                                                                         metrics:nil
                                                                            views:@{ @"imageView" : self.menuImageView,
                                                                                     @"textLabel" : self.menuTextLabel }];
    [self.contentView addConstraints:self.indentationConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)tintColorDidChange
{
    self.selectedBackgroundView.backgroundColor = self.tintColor;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.indentationLevel = 0;
}


@end
