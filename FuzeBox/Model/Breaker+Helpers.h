//
//  Breaker+Helpers.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "Breaker.h"
#import "FuzeBoxConstants.h"

@interface Breaker (Helpers)

- (BOOL)isPunchout;
- (BOOL)isGFCI;
- (BOOL)isTandem;
- (BOOL)isDoublePole;
- (SwitchOrientation)switchOrientation;
- (void)setSwitchOrientation:(SwitchOrientation)switchOrientation;

@end
