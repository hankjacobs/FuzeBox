//
//  CTRLDataStack.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

@import Foundation;

@interface CTRLDataStack : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectContext *scratchContext;
@property (nonatomic, assign) BOOL useiCloud;
@property (nonatomic, readonly) BOOL cloudAvailable;

+ (instancetype)sharedDataStack;
- (void)setUseiCloudAndReplace:(BOOL)useiCloud;
- (void)destroyEverything; //No longer working


@end

extern NSString *const CTRLDataStoreWillLoad;
extern NSString *const CTRLDataStoreDidLoad;