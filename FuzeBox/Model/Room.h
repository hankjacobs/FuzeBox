//
//  Room.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/2/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fixture, House;

@interface Room : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *fixtures;
@property (nonatomic, retain) House *house;
@end

@interface Room (CoreDataGeneratedAccessors)

- (void)addFixturesObject:(Fixture *)value;
- (void)removeFixturesObject:(Fixture *)value;
- (void)addFixtures:(NSSet *)values;
- (void)removeFixtures:(NSSet *)values;

@end
