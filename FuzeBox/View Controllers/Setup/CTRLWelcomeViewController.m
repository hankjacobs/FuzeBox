//
//  CTRLWelcomeViewController.m
//  FuzeBox
//
//  Created by Hank Jacobs on 12/22/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLWelcomeViewController.h"
#import "CTRLSetupCloudOptionViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface CTRLWelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (nonatomic, strong) MPMoviePlayerController *movieController;
@property (nonatomic, strong) UIImageView *welcomeFirstFrame;
@end

@implementation CTRLWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL * resourcePath = [[NSBundle mainBundle] resourceURL];
    resourcePath = [NSURL URLWithString:@"welcomeAnimation@2x.mov" relativeToURL:resourcePath];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:resourcePath];
    self.movieController.controlStyle = MPMovieControlStyleNone;
    self.movieController.shouldAutoplay = NO;
    [self.movieController prepareToPlay];
    self.movieController.view.frame = self.movieView.bounds;
    self.movieController.view.backgroundColor = self.view.backgroundColor;
    self.movieController.backgroundView.backgroundColor = self.view.backgroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.movieController];
    
    self.welcomeFirstFrame = [[UIImageView alloc] initWithImage:
                              [UIImage imageNamed:@"welcomeAnimationFirstFrame.png"]];
    self.welcomeFirstFrame.frame = self.movieView.bounds;
    [self.movieView addSubview:self.movieController.view];
    [self.movieView addSubview:self.welcomeFirstFrame];
    self.movieController.view.hidden = YES;
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.movieController setCurrentPlaybackTime:0.0];
    [self.movieController play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.movieController pause];
    [self.movieController setCurrentPlaybackTime:0.0];
    self.movieController.view.hidden = YES;
}

- (void)movieStateChanged:(NSNotification *)notif
{
    if (self.movieController.playbackState == MPMoviePlaybackStatePlaying) {
        self.movieController.view.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CTRLSetupCloudOptionViewController *destinationVC = segue.destinationViewController;
    destinationVC.setupCompletionBlock = self.setupCompletionBlock;
}

@end
