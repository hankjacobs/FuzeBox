//
//  Breaker+Helpers.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "Breaker+Helpers.h"

@implementation Breaker (Helpers)

- (BOOL)isPunchout
{
    return self.punchout.boolValue;
}
- (BOOL)isGFCI
{
    return self.gfci.boolValue;
}

- (BOOL)isTandem
{
    return self.tandem.boolValue;
}

- (BOOL)isDoublePole
{
    return self.doublePole.boolValue;
}

- (SwitchOrientation)switchOrientation
{
    return self.breakerOrientation.intValue;
}

- (void)setSwitchOrientation:(SwitchOrientation)switchOrientation
{
    self.breakerOrientation = @(switchOrientation);
}

@end
