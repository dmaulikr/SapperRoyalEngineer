//
//  BGViewController.m
//  Miner
//
//  Created by AndrewShmig on 3/15/14.
//  Copyright (c) 2014 Non Atomic Games. All rights reserved.
//

#import "BGViewController.h"
#import "BGLog.h"
#import "BGResourcePreloader.h"
#import "BGGameViewController.h"
#import "FlurryAds.h"


@implementation BGViewController

#pragma mark - View

- (void)viewDidLoad
{
    BGLog();

    [super viewDidLoad];

    self.gameViewController = [BGGameViewController shared];
}

- (void)viewWillAppear:(BOOL)animated
{
    BGLog();

    [super viewWillAppear:animated];

    [FlurryAds fetchAndDisplayAdForSpace:@"BANNER_MAIN_VIEW"
                                    view:self.view
                                    size:BANNER_BOTTOM];
}

- (void)viewDidAppear:(BOOL)animated
{
    BGLog();

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    BGLog();

    [super viewDidDisappear:animated];

    [FlurryAds removeAdFromSpace:@"BANNER_MAIN_VIEW"];
}

#pragma mark - Actions

- (IBAction)playButtonTapped:(id)sender
{
    //    проигрываем звук нажатия
    [[[BGResourcePreloader shared]
                           playerFromGameConfigForResource:@"buttonTap.mp3"]
                           play];

    [self.navigationController pushViewController:self.gameViewController
                                         animated:YES];
}

- (IBAction)configButtonTapped:(id)sender
{
    //    проигрываем звук нажатия
    [[[BGResourcePreloader shared]
                           playerFromGameConfigForResource:@"buttonTap.mp3"]
                           play];
}

@end
