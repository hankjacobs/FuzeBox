//
//  CTRLAboutViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/30/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLAboutViewController.h"

@interface CTRLAboutViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CTRLAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
