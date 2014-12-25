//
//  Panel+Helpers.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/29/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "Panel.h"


typedef NS_ENUM(NSInteger, PanelType){
    PanelVerticalSingleRow,
    PanelVerticalDoubleRow,
    PanelHorizontalSingleRow,
    PanelHorizontalDoubleRow
};

@interface Panel (Helpers)

@property (nonatomic, assign) PanelType panelType;
@property (nonatomic, readonly, getter = isDoubleRowPanel) BOOL doubleRowPanel;

- (NSString *)friendlyNameForPanelType;

@end
