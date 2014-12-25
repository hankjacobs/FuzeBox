//
//  CTRPanelCollectionViewCell.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/28/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTRLPanelCollectionViewCellDelegate;
@interface CTRLPanelCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIImageView *panelImageView;
@property (nonatomic, strong) UIView *panelSnapshot;
@property (nonatomic, strong) NSString *panelName;
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@property (nonatomic, weak) id<CTRLPanelCollectionViewCellDelegate> delegate;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end


@protocol CTRLPanelCollectionViewCellDelegate <NSObject>

- (void)panelCellDeleteButtonWasTapped:(CTRLPanelCollectionViewCell *)cell;

@end