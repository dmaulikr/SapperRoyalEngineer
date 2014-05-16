//
//  BGViewController.m
//  Miner
//
//  Created by AndrewShmig on 3/15/14.
//  Copyright (c) 2014 Non Atomic Games. All rights reserved.
//

#import <iAd/iAd.h>
#import <GameKit/GameKit.h>
#import "BGViewController.h"
#import "BGSettingsManager.h"
#import "BGLog.h"
#import "BGResourcePreloader.h"
#import "BGAppDelegate.h"
#import "BGGameViewController.h"


@implementation BGViewController

#pragma mark - View

- (void)viewDidLoad
{
    BGLog();

    [super viewDidLoad];

    self.gameViewController = [BGGameViewController shared];
}

- (void)viewDidAppear:(BOOL)animated
{
    BGLog();

    [super viewDidAppear:animated];

    //    разрешаем на этом экране работать рекламе
    self.canDisplayBannerAds = YES;
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
