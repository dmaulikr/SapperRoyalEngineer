//
//  BGOptionsViewController.m
//  Miner
//
//  Created by AndrewShmig on 3/15/14.
//  Copyright (c) 2014 Bleeding Games. All rights reserved.
//

#import <iAd/iAd.h>
#import <GameKit/GameKit.h>
#import "BGOptionsViewController.h"
#import "BGUISwitch.h"
#import "BGSettingsManager.h"
#import "BGResourcePreloader.h"
#import "BGUISegmentedControl.h"
#import "BGLog.h"
#import "BGSKView.h"
#import "BGGameViewController.h"
#import "Flurry.h"
#import "BGAppDelegate.h"
#import "FlurryAds.h"


@interface BGOptionsViewController ()
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) BGUISwitch *soundSwitch;
@property (nonatomic) BGUISwitch *gameCenterSwitch;
@end


@implementation BGOptionsViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];

    //    кнопка назад
    UIImage *backNormal = [UIImage imageNamed:@"back"];
    UIImage *backHighlighted = [UIImage imageNamed:@"back_down"];
    UIButton *back = [[UIButton alloc]
                                initWithFrame:CGRectMake(14, 22, backNormal.size
                                        .width, backNormal.size.height)];
    [back setImage:backNormal forState:UIControlStateNormal];
    [back setImage:backHighlighted forState:UIControlStateHighlighted];
    [back addTarget:self
             action:@selector(back:)
   forControlEvents:UIControlEventTouchUpInside];

    [self.originalContentView addSubview:back];

    //    создаем подпись к элементу изменения размера поля
    UIImageView *fieldSizeImageView = [[UIImageView alloc]
                                                    initWithImage:[UIImage imageNamed:@"field_size"]];
    CGRect fieldSizeRect = fieldSizeImageView.bounds;
    fieldSizeImageView.frame = CGRectMake(88, 70, fieldSizeRect.size
            .width, fieldSizeRect.size.height);

    [self.originalContentView addSubview:fieldSizeImageView];

    //    переключение размера поля
    UIImage *backgroundImageFieldSize = [UIImage imageNamed:@"field_deafult"];
    CGRect frameFieldSize = CGRectMake(35, 97, backgroundImageFieldSize.size
            .width, backgroundImageFieldSize.size.height);
    BGUISegmentedControl *fieldSizeSCView = [[BGUISegmentedControl alloc]
                                                                   initWithFrame:frameFieldSize];
    fieldSizeSCView.backgroundImage = backgroundImageFieldSize;
    [fieldSizeSCView addNewSegmentImage:[UIImage imageNamed:@"button_down_128"]];
    [fieldSizeSCView addNewSegmentImage:[UIImage imageNamed:@"button_down_1510"]];
    [fieldSizeSCView addNewSegmentImage:[UIImage imageNamed:@"button_down_2416"]];

    if ([BGSettingsManager sharedManager].cols == kSmallFieldCols)
        fieldSizeSCView.selectedSegmentIndex = 0;
    else if ([BGSettingsManager sharedManager].cols == kMediumFieldCols)
        fieldSizeSCView.selectedSegmentIndex = 1;
    else
        fieldSizeSCView.selectedSegmentIndex = 2;

    [fieldSizeSCView addTarget:self
                        action:@selector(fieldSizeChanged:)];

    [self.originalContentView addSubview:fieldSizeSCView];

    //    создаем подпись к элементу изменения сложности игры
    UIImageView *difficultyImageView = [[UIImageView alloc]
                                                     initWithImage:[UIImage imageNamed:@"difficulty"]];
    CGRect difficultyRect = difficultyImageView.bounds;
    difficultyImageView.frame = CGRectMake(102, 169, difficultyRect.size
            .width, difficultyRect.size.height);

    [self.originalContentView addSubview:difficultyImageView];

    //    переключение сложности игры
    UIImage *backgroundImageDifficulty = [UIImage imageNamed:@"difficult_default"];
    CGRect frame = CGRectMake(35, 195, backgroundImageDifficulty.size
            .width, backgroundImageDifficulty.size.height);
    BGUISegmentedControl *fieldDifficultySCView = [[BGUISegmentedControl alloc]
                                                                         initWithFrame:frame];
    fieldDifficultySCView.backgroundImage = backgroundImageDifficulty;
    [fieldDifficultySCView addNewSegmentImage:[UIImage imageNamed:@"button_down_easy"]];
    [fieldDifficultySCView addNewSegmentImage:[UIImage imageNamed:@"button_down_norm"]];
    [fieldDifficultySCView addNewSegmentImage:[UIImage imageNamed:@"button_down_hard"]];

    if ([BGSettingsManager sharedManager].level == BGMinerLevelOne)
        fieldDifficultySCView.selectedSegmentIndex = 0; // easy
    else if ([BGSettingsManager sharedManager].level == BGMinerLevelTwo)
        fieldDifficultySCView.selectedSegmentIndex = 1; // norm
    else
        fieldDifficultySCView.selectedSegmentIndex = 2; // hard

    [fieldDifficultySCView addTarget:self
                              action:@selector(levelChanged:)];

    [self.originalContentView addSubview:fieldDifficultySCView];

//    кол-во точек, на которые надо поднять переключатели, если запускается на 4 iPhone
    CGFloat pointsToSubstract = 0.0;

    if ([UIScreen mainScreen].bounds.size.height == 480)
        pointsToSubstract = 30;

    //    создаем подпись к переключателю звука
    UIImageView *soundImageView = [[UIImageView alloc]
                                                initWithImage:[UIImage imageNamed:@"sounds"]];
    CGRect soundsBounds = soundImageView.bounds;
    soundImageView
            .frame = CGRectMake(55.5, (CGFloat) 372.5 - pointsToSubstract, soundsBounds
            .size.width, soundsBounds.size.height);

    [self.originalContentView addSubview:soundImageView];

    //    создаем переключатель для звука
    self.soundSwitch = [[BGUISwitch alloc]
            initWithPosition:CGPointMake(48, (CGFloat) 398.0 - pointsToSubstract)
                                             onImage:[UIImage imageNamed:@"switch_1"]
                                            offImage:[UIImage imageNamed:@"switch_0"]];
    self.soundSwitch.on = ([BGSettingsManager sharedManager]
            .soundStatus == BGMinerSoundStatusOn);
    self.soundSwitch.tag = kBGUISwitchSoundTag;
    [self.soundSwitch addTarget:self
                         action:@selector(soundButtonTapped:)];

    [self.originalContentView addSubview:self.soundSwitch];

    //    создаем подпись к переключателю Game Center
    UIImageView *gameCenterImageView = [[UIImageView alloc]
                                                     initWithImage:[UIImage imageNamed:@"game_center"]];
    CGRect gameCenterBounds = gameCenterImageView.bounds;
    gameCenterImageView
            .frame = CGRectMake(187.5, (CGFloat) 348.5 - pointsToSubstract, gameCenterBounds
            .size.width, gameCenterBounds.size.height);

    [self.originalContentView addSubview:gameCenterImageView];

    //    создаем переключатель для Гейм Центра
    self.gameCenterSwitch = [[BGUISwitch alloc]
            initWithPosition:CGPointMake(181, (CGFloat) 398.0 - pointsToSubstract)
                                                  onImage:[UIImage imageNamed:@"switch_1"]
                                                 offImage:[UIImage imageNamed:@"switch_0"]];
    self.gameCenterSwitch.on = ([BGSettingsManager sharedManager]
            .gameCenterStatus == BGMinerGameCenterStatusOn);
    self.gameCenterSwitch.tag = kBGUISwitchGameCenterTag;
    [self.gameCenterSwitch addTarget:self
                              action:@selector(gameCenterButtonTapped:)];

    [self.originalContentView addSubview:self.gameCenterSwitch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [FlurryAds fetchAndDisplayAdForSpace:@"BANNER_OPTIONS_VIEW"
                                    view:self.view
                                    size:BANNER_BOTTOM];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [FlurryAds removeAdFromSpace:@"BANNER_OPTIONS_VIEW"];
}

#pragma mark - Target actions

- (void)levelChanged:(id)newlySelectedIndexNumber
{
    BGLog();

    //    изменяем сложность игры
    NSUInteger selected = [((NSNumber *) newlySelectedIndexNumber) unsignedIntegerValue] + 1;
    BGMinerLevel newLevel = (BGMinerLevel) selected;

    [BGSettingsManager sharedManager].level = newLevel;

    //    обновим поле
    [[BGGameViewController shared].skView startNewGame];
}

- (void)fieldSizeChanged:(id)newlySelectedIndexNumber
{
    BGLog();

    //    изменяем размеры поля
    NSUInteger selected = [((NSNumber *) newlySelectedIndexNumber) unsignedIntegerValue];
    NSUInteger cols;
    NSUInteger rows;

    switch (selected) {
        default:

        case 0: // размер поля 12х8
            cols = kSmallFieldCols;
            rows = kSmallFieldRows;
            break;

        case 1: // размер поля 15х10
            cols = kMediumFieldCols;
            rows = kMediumFieldRows;
            break;

        case 2: // размер поля 24х16
            cols = kBigFieldCols;
            rows = kBigFieldRows;
            break;
    }

    [BGSettingsManager sharedManager].cols = cols;
    [BGSettingsManager sharedManager].rows = rows;

    //    обновим поле
    [[BGGameViewController shared].skView startNewGame];
}

- (void)soundButtonTapped:(id)sender
{
    BGLog();

    //    при переключении тумблера звука меняем настройки
    BGMinerSoundStatus soundStatus = [BGSettingsManager sharedManager].soundStatus;

    if (soundStatus == BGMinerSoundStatusOn && self.soundSwitch.activeRegion == BGUISwitchLeftRegion) {
        [BGSettingsManager sharedManager].soundStatus = BGMinerSoundStatusOff;

        //        фиксируем пользователей, которые играют без звука
        [Flurry logEvent:@"UserTurnsSoundsOff"];
    } else if (soundStatus == BGMinerSoundStatusOff && self.soundSwitch.activeRegion == BGUISwitchRightRegion) {
        [BGSettingsManager sharedManager].soundStatus = BGMinerSoundStatusOn;

        //        фиксируем пользователей, которые играют со звуком
        [Flurry logEvent:@"UserTurnsSoundsOn"];
    }
}

- (void)gameCenterButtonTapped:(id)sender
{
    BGLog();

    BGMinerGameCenterStatus gcStatus = [BGSettingsManager sharedManager].gameCenterStatus;

    if (gcStatus == BGMinerGameCenterStatusOn && self.gameCenterSwitch.activeRegion == BGUISwitchLeftRegion) {
        [BGSettingsManager sharedManager].gameCenterStatus = BGMinerGameCenterStatusOff;

        //        фиксируем пользователей, которые выключают гейм центр
        [Flurry logEvent:@"UserTurnsGameCenterOff"];
    } else {
        [BGSettingsManager sharedManager].gameCenterStatus = BGMinerGameCenterStatusOn;

        //    запрашиваем у пользователя авторизацию в ГЦ, если надо
        [[BGGameViewController shared] authorizeLocalPlayer];

        //        фиксируем пользователей, которые включают гейм центр
        [Flurry logEvent:@"userTurnsGameCenterOn"];
    }
}

- (void)back:(id)sender
{
    [[[BGResourcePreloader shared]
                           playerFromGameConfigForResource:@"buttonTap.mp3"]
                           play];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
