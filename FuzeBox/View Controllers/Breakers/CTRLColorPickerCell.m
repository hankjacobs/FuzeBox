//
//  CTRLColorPickerCell.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/11/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLColorPickerCell.h"

@implementation CTRLColorPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setColorPicker:(CTRLColorPicker *)colorPicker
{
    _colorPicker = colorPicker;
    
    if (colorPicker) {
       _colorPicker = colorPicker;
        
        [self.contentView addSubview:_colorPicker];
    }
    else {
        if (_colorPicker.superview) {
            [_colorPicker removeFromSuperview];
        }
        
        _colorPicker = colorPicker;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.colorPicker.frame = self.contentView.bounds;
}

@end
