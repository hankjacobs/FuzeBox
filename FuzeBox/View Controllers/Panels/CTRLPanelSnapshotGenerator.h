//
//  CTRLPanelSnapshotGenerator.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/21/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Panel;
@interface CTRLPanelSnapshotGenerator : NSObject

+ (UIView *)snapshotForPanel:(Panel *)panel;

@end
