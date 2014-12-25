//
//  UIViewController+CoreData.h
//  FuzeBox
//
//  Created by Hank Jacobs on 1/3/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CoreData)

- (void)observeCoreDataStoreWillChangeWithSelector:(SEL)selector;
- (void)observeCoreDataStoreDidChangeWithSelector:(SEL)selector;
- (void)removeObservanceOfCoreDataStoreChanges;

@end
