//
//  CTRLHorizontalDoubleFlowLayout.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/29/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLBreakerLayout.h"
#import "UIColor+UIColorFromRGB.h"

static NSString *const CTRLBreakerLayoutCellKind = @"BreakerCell";

@interface CTRLBreakerLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSMutableDictionary *cellSizeCache;
@property (nonatomic, assign) CTRLBreakerLayoutStyle layoutStyle;
@property (nonatomic, assign) UIEdgeInsets itemInsets;
@property (nonatomic, readwrite, assign) CGSize defaultItemSize;
@property (nonatomic, assign) CGFloat interItemSpacingY;
@property (nonatomic, assign) NSInteger numberOfColumns;

@end

@implementation CTRLBreakerLayout

#pragma mark - Lifecycle

- (id)init
{
    return [self initWithLayoutStyle:CTRLBreakerLayoutStyleVerticalSingle];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithLayoutStyle:(CTRLBreakerLayoutStyle)layoutStyle
{
    self = [super init];
    
    if (self) {
        self.layoutStyle = layoutStyle;
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.cellSizeCache = [@{} mutableCopy];
    self.interItemSpacingY = 0.0;
    self.itemInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    [self setupDefaultSize];
}

- (void)setupDefaultSize
{
    
    switch (self.layoutStyle) {
        case CTRLBreakerLayoutStyleVerticalSingle:
            self.defaultItemSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), 44.0f);
            self.numberOfColumns = 1;
            break;
        case CTRLBreakerLayoutStyleVerticalDouble:
            self.defaultItemSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), 44.0f);
            self.numberOfColumns = 2;
            break;
        case CTRLBreakerLayoutStyleHorizontalSingle:
            self.defaultItemSize = CGSizeMake(44.0f, CGRectGetHeight(self.collectionView.bounds)-(2*self.itemInsets.top));
            self.numberOfColumns = 1;
            break;
        case CTRLBreakerLayoutStyleHorizontalDouble:
            self.defaultItemSize = CGSizeMake(44.0f, CGRectGetHeight(self.collectionView.bounds)-2*self.itemInsets.top);
            self.numberOfColumns = 2;
            break;
    }
}

#pragma mark - Layout

- (void)prepareLayout
{
    [self setupDefaultSize];
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForBreakerAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[CTRLBreakerLayoutCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[CTRLBreakerLayoutCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    NSArray *cellFrames = [self.layoutInfo[CTRLBreakerLayoutCellKind] allValues];

    CGFloat maxX = 0.0;
    CGFloat maxY = 0.0;
    
    for (UICollectionViewLayoutAttributes *attributes in cellFrames) {
        CGRect frame = attributes.frame;
        
        if (CGRectGetMaxX(frame) > maxX) {
            maxX = CGRectGetMaxX(frame);
        }
        
        if (CGRectGetMaxY(frame) > maxY) {
            maxY = CGRectGetMaxY(frame);
        }
    }
    
    return CGSizeMake(maxX, maxY);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark - Private


- (CGRect)frameForBreakerAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat cellWidth = self.defaultItemSize.width;
    CGFloat cellHeight = self.defaultItemSize.height;
    
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:sizeForCellAtIndexPath:)])
    {
        id<UICollectionViewDelegateCTRLBreakerLayout> delegate = (id<UICollectionViewDelegateCTRLBreakerLayout>)self.collectionView.delegate;
        CGSize cellSize = [delegate collectionView:self.collectionView sizeForCellAtIndexPath:indexPath];
        
        cellWidth = cellSize.width;
        cellHeight = cellSize.height;
        
        [self.cellSizeCache setObject:[NSValue valueWithCGSize:cellSize] forKey:indexPath];
    }
    
    CGSize cellSizeTotal = [self cellSizeTotalUpToIndexPath:indexPath];
    CGFloat originX = 0.0;
    CGFloat originY = 0.0;
    
    originX = cellSizeTotal.width + self.itemInsets.left;
    originY = cellSizeTotal.height + self.itemInsets.top;
    
    return CGRectMake(originX, originY, cellWidth, cellHeight);
}

//This factors in cell type to determine how to total width and height
- (CGSize)cellSizeTotalUpToIndexPath:(NSIndexPath *)indexPath
{
    CGFloat widthTotal = 0.0;
    CGFloat heightTotal = 0.0;
    
    
    NSInteger sectionToSpanUpTo = indexPath.section-1;
    
    for (NSInteger i = sectionToSpanUpTo; i >= 0; i--) {
        CGSize size;
        NSValue *cachedSize = [self.cellSizeCache objectForKey:[NSIndexPath indexPathForRow:indexPath.row inSection:i]];
        if (cachedSize) {
            size = [cachedSize CGSizeValue];
        }
        else {
            size = self.defaultItemSize;
        }
        
        
        if (self.layoutStyle == CTRLBreakerLayoutStyleVerticalDouble) {
            widthTotal += size.width;
        }
        else if (self.layoutStyle == CTRLBreakerLayoutStyleHorizontalDouble){
            if (size.height < self.collectionView.frame.size.height) {
                size.height = self.collectionView.frame.size.height; //We force it onto the next 'page' of the scroll view
            }
            heightTotal += size.height;
        }
    }
    
    for (int i = 0; i < indexPath.row; i++)
    {
        CGSize size;
        NSValue *cachedSize = [self.cellSizeCache objectForKey:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        if (cachedSize) {
            size = [cachedSize CGSizeValue];
        }
        else {
            size = self.defaultItemSize;
        }
        
        if (self.layoutStyle == CTRLBreakerLayoutStyleVerticalDouble || self.layoutStyle == CTRLBreakerLayoutStyleVerticalSingle) {
            heightTotal += size.height;
        }
        else if (self.layoutStyle == CTRLBreakerLayoutStyleHorizontalSingle ||
                 self.layoutStyle == CTRLBreakerLayoutStyleHorizontalDouble) {
            widthTotal += size.width;
        }
    }
    
    return CGSizeMake(widthTotal, heightTotal);
}

@end
