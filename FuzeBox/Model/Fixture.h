//
//  Fixture.h
//  FuzeBox
//
//  Created by Hank Jacobs on 1/12/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Breaker, Room;

@interface Fixture : NSManagedObject

@property (nonatomic, retain) NSNumber * iconIndex;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionDisplayName;
@property (nonatomic, retain) Breaker *breaker;
@property (nonatomic, retain) Room *room;

@end
