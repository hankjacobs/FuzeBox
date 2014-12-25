//
//  UIViewController+CoreData.m
//  FuzeBox
//
//  Created by Hank Jacobs on 1/3/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import "UIViewController+CoreData.h"
#import "CTRLDataStack.h"

@implementation UIViewController (CoreData)

- (void)observeCoreDataStoreWillChangeWithSelector:(SEL)selector
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:selector name:CTRLDataStoreWillLoad object:nil];
}

- (void)observeCoreDataStoreDidChangeWithSelector:(SEL)selector
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:selector name:CTRLDataStoreDidLoad object:nil];
}

- (void)removeObservanceOfCoreDataStoreChanges
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
