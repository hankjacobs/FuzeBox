//
//  CTRLSeededGenericSelectionListViewController.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLGenericSelectionListViewController.h"

@class House;
@interface CTRLSeededRoomSelectionListViewController : CTRLGenericSelectionListViewController

@property (nonatomic, readonly) NSString *sectionNameKeypath; //forced to nil.
@property (nonatomic, strong) NSArray *seededCellTitles;
@property (nonatomic, strong) NSString *selectedCellTitle;
@property (nonatomic, strong) House *house;

@end
