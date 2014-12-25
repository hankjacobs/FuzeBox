//
//  CTRLGridImagePicker.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const CTRLGridImagePickerInvalidIndex;

@interface CTRLGridImagePicker : UIControl

@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, assign) NSInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame images:(NSArray *)images selectedImages:(NSArray *)selectedImages;

@end
