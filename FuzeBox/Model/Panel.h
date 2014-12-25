//
//  Panel.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Breaker, House;

@interface Panel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSSet *breakers;
@property (nonatomic, retain) House *house;
@end

@interface Panel (CoreDataGeneratedAccessors)

- (void)addBreakersObject:(Breaker *)value;
- (void)removeBreakersObject:(Breaker *)value;
- (void)addBreakers:(NSSet *)values;
- (void)removeBreakers:(NSSet *)values;

@end
