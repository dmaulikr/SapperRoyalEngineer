//
//  BGGameViewController.h
//  Miner
//
//  Created by AndrewShmig on 3/15/14.
//  Copyright (c) 2014 Non Atomic Games. All rights reserved.
//

@import UIKit;
@import SpriteKit;


@class NAGSKView;


@interface BGGameViewController : UIViewController

// вьюха для отображения игровой сцены
@property (nonatomic, strong) NAGSKView *skView;

// уникальный объект игрового экрана
// используется для того, чтобы ускорить загрузку и отображение содержимого сцены
+ (instancetype)shared;

// Game Center
- (void)authorizeLocalPlayer;

// player score
- (NSUInteger)gameScore;

@end