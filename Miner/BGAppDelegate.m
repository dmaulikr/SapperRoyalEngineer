//
//  BGAppDelegate.m
//  Miner
//
//  Created by AndrewShmig on 3/15/14.
//  Copyright (c) 2014 Non Atomic Games. All rights reserved.
//

#import "BGAppDelegate.h"
#import "NAGSettingsManager.h"
#import "NAGResourcePreloader.h"
#import "NAGLog.h"
#import "iRate.h"
#import "Flurry.h"
#import "FlurryAds.h"


@implementation BGAppDelegate

+ (void)initialize
{
//    настраиваем окно с вопросом об оценке приложения
    [iRate sharedInstance];
    [iRate sharedInstance].appStoreID = 867507430;
    [iRate sharedInstance].applicationName = @"Sapper: Royal Engineer";
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 3;
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;

//    настройках менеджера настроек
    [[NAGSettingsManager shared] createDefaultSettingsFromDictionary:@{
            @"game" : @{
                    @"settings" : @{
                            @"soundsOn"     : @YES,
                            @"gameCenterOn" : @YES,
                            @"level"        : @1,
                            @"cols"         : @12,
                            @"rows"         : @8
                    },
                    @"field"    : @{
                            @"small"  : @{
                                    @"cols" : @12,
                                    @"rows" : @8
                            },
                            @"medium" : @{
                                    @"cols" : @15,
                                    @"rows" : @10
                            },
                            @"big"    : @{
                                    @"cols" : @24,
                                    @"rows" : @16
                            }
                    }
            }
    }];

    [[NAGSettingsManager shared] resetToDefaultSettingsIfNoneExists];
}

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BGLog();

//    собираем статистику
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"QMG6WRKZD397MK5N728Q"];

//    инициализируем рекламу от Flurry
    [FlurryAds initialize:self.window.rootViewController];

//    предзагрузка звуков в фоновом режиме для избежания затормаживания
    NSArray *audioResources = @[@"switchON.mp3",
                                @"switchOFF.mp3",
                                @"flagTapOn.mp3",
                                @"grassTap.mp3",
                                @"buttonTap.mp3",
                                @"flagTapOff.mp3",
                                @"explosion.wav"];

    for (NSString *audioName in audioResources) {
        [[NAGResourcePreloader shared] preloadAudioResource:audioName];
    }

    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    BGLog();

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BGLog();
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    BGLog();

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BGLog();

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    BGLog();
}

@end
