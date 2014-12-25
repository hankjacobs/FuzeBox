//
//  House.h
//  FuzeBox
//
//  Created by Hank Jacobs on 1/5/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Panel, Room;

@interface House : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *panels;
@property (nonatomic, retain) NSSet *rooms;
@end

@interface House (CoreDataGeneratedAccessors)

- (void)addPanelsObject:(Panel *)value;
- (void)removePanelsObject:(Panel *)value;
- (void)addPanels:(NSSet *)values;
- (void)removePanels:(NSSet *)values;

- (void)addRoomsObject:(Room *)value;
- (void)removeRoomsObject:(Room *)value;
- (void)addRooms:(NSSet *)values;
- (void)removeRooms:(NSSet *)values;

@end
