//
//  Fixture+Helpers.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "Fixture+Helpers.h"
#import "Breaker.h"
#import "Panel.h"

@implementation Fixture (Helpers)

- (NSString *)sectionDisplayName
{
    if (self.breaker.panel.name && self.breaker.name)
        return [NSString stringWithFormat:@"%@ - Breaker %@",self.breaker.panel.name, self.breaker.name];
    else
        return @"Unassigned";
}

@end
