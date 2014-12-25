//
//  CTRLEditPropertyViewController.h
//  Breaker Buddy
//
//  Created by Hank Jacobs on 11/13/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTRLEditPropertyDelegate;
@interface CTRLPropertyEditorViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (nonatomic, strong) NSString *propertyKey;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, weak) id<CTRLEditPropertyDelegate> delegate;

+ (instancetype)propertyEditorFromStoryboard;

@end

@protocol CTRLEditPropertyDelegate <NSObject>

- (void)propertyEditor:(CTRLPropertyEditorViewController *)propertyEditor didRegisterChangeForPropertyKey:(NSString *)propertyKey withValue:(NSString *)value;

@end