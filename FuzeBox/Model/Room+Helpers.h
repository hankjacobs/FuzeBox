//
//  Room+Helpers.h
//  FuzeBox
//
//  Created by Hank Jacobs on 1/12/14.
//  Copyright (c) 2014 CTRL-Point. All rights reserved.
//

#import "Room.h"

@class House;

@interface Room (Helpers)

+ (Room *)unassignedRoomForHouse:(House *)house;

@end
