//
//  Breaker.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/29/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fixture, Panel;

@interface Breaker : NSManagedObject

@property (nonatomic, retain) NSNumber * amperage;
@property (nonatomic, retain) NSNumber * breakerOrientation;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSNumber * doublePole;
@property (nonatomic, retain) NSNumber * gfci;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * panelColumn;
@property (nonatomic, retain) NSNumber * panelRow;
@property (nonatomic, retain) NSNumber * punchout;
@property (nonatomic, retain) NSNumber * tandem;
@property (nonatomic, retain) NSNumber * on;
@property (nonatomic, retain) NSSet *fixtures;
@property (nonatomic, retain) Panel *panel;
@end

@interface Breaker (CoreDataGeneratedAccessors)

- (void)addFixturesObject:(Fixture *)value;
- (void)removeFixturesObject:(Fixture *)value;
- (void)addFixtures:(NSSet *)values;
- (void)removeFixtures:(NSSet *)values;

@end
