//
//  CTRLBreakerLayout.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/29/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CTRLBreakerLayoutStyle){
        CTRLBreakerLayoutStyleVerticalSingle,
        CTRLBreakerLayoutStyleVerticalDouble,
        CTRLBreakerLayoutStyleHorizontalSingle,
        CTRLBreakerLayoutStyleHorizontalDouble
};

@protocol UICollectionViewDelegateCTRLBreakerLayout;
@interface CTRLBreakerLayout : UICollectionViewLayout

@property (nonatomic, readonly) CGSize defaultItemSize;

- (id)initWithLayoutStyle:(CTRLBreakerLayoutStyle)layoutStyle;

@end

@protocol UICollectionViewDelegateCTRLBreakerLayout <NSObject>
@optional
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForCellAtIndexPath:(NSIndexPath *)indexPath;
@end