//
//  Room+Helpers.m
//  FuzeBox
//
//  Created by Hank Jacobs on 1/12/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import "Room+Helpers.h"
#import "House.h"

@implementation Room (Helpers)

+ (Room *)unassignedRoomForHouse:(House *)house
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"house = %@ AND name = %@", house, @"Unassigned"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Room"];
    fetchRequest.predicate = predicate;
    
    __block Room *room = nil;
    
    [house.managedObjectContext performBlockAndWait:^{
        room = [[house.managedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
    }];
    
    if (!room) {
        room = [NSEntityDescription insertNewObjectForEntityForName:@"Room"
                                             inManagedObjectContext:house.managedObjectContext];
        room.name = @"Unassigned";
        room.house = house;
    }
    
    return room;
}
@end
