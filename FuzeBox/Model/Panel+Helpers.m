//
//  Panel+Helpers.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/29/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "Panel+Helpers.h"

@implementation Panel (Helpers)
@dynamic panelType;
@dynamic doubleRowPanel;

- (PanelType)panelType
{
    return self.type.intValue;
}

- (void)setPanelType:(PanelType)panelType
{
    self.type = @(panelType);
}

- (BOOL)isDoubleRowPanel
{
    if (self.panelType == PanelVerticalDoubleRow || self.panelType == PanelHorizontalDoubleRow)
        return YES;
    else
        return NO;
}

- (NSString *)friendlyNameForPanelType
{
    switch (self.panelType) {
        case PanelVerticalSingleRow:
            return @"Vertical (Single Row)";
            break;
        case PanelVerticalDoubleRow:
            return @"Vertical (Double Row)";
            break;
        case PanelHorizontalSingleRow:
            return @"Horizontal (Single Row)";
            break;
        case PanelHorizontalDoubleRow:
            return @"Horizontal (Double Row)";
            break;
        default:
            return @"";
            break;
    }
}

@end
