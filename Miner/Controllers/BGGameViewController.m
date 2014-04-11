//
//  BGGameViewController.m
//  Miner
//
//  Created by AndrewShmig on 3/15/14.
//  Copyright (c) 2014 Bleeding Games. All rights reserved.
//

#import "BGGameViewController.h"
#import "BGMinerField.h"
#import "BGSettingsManager.h"
#import "BGLog.h"


// полезные константы тегов для вьюх
static const NSInteger kBGTimerViewTag = 1;
static const NSInteger kBGMinesCountViewTag = 2;


// игровое поле
BGMinerField *_field;
// кол-во отмеченых бомб
NSUInteger flaggedMines;


#pragma mark - BGGameScene

// дочерний класс для обработки цикла обновления игрового поля
@interface BGGameScene : SKScene
@end

@implementation BGGameScene
@end


#pragma mark - BGGameViewController

// приватные методы
@interface BGGameViewController (Private)
- (void)startNewGame;

- (void)fillGameSceneField;

- (void)startGameTimer;

- (void)destroyGameTimer;

- (void)animateExplosionOnCellWithCol:(NSUInteger)col row:(NSUInteger)row;

- (void)openCellsFromCellWithCol:(NSUInteger)col row:(NSUInteger)row;

- (void)openCellsWithBombs;
@end


// основная реализация
@implementation BGGameViewController

#pragma mark - View

- (void)viewDidLoad
{
    BGLog(@"%s", __FUNCTION__);

    [self startNewGame];
}

- (void)viewDidAppear:(BOOL)animated
{
    BGLog();

    [self startGameTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    BGLog();

    [self destroyGameTimer];
}

#pragma mark - Game & Private

- (void)startGameTimer
{
    BGLog();

//    запускаем таймер игры
    if (self.timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTimerLabel:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)destroyGameTimer
{
    //    убираем таймер
    [_timer invalidate];
    _timer = nil;
}

- (void)startNewGame
{
    //    нет отмеченных бомб
    flaggedMines = 0;

//    генерируем поле
    NSUInteger rows = [BGSettingsManager sharedManager].rows;
    NSUInteger cols = [BGSettingsManager sharedManager].cols;
    NSUInteger bombs = [BGSettingsManager sharedManager].bombs;

    _field = [[BGMinerField alloc] initWithCols:cols
                                           rows:rows
                                          bombs:bombs];

//    добавляем изображение верхней панели
    UIImage *topPanelImage = [UIImage imageNamed:@"top_game"];
    UIImageView *topPanelImageView = [[UIImageView alloc]
                                                   initWithImage:topPanelImage];
    topPanelImageView.frame = CGRectMake(0, 0, topPanelImage.size.width, topPanelImage.size.height);

    [self.view addSubview:topPanelImageView];

//    на панель изображения накладываем надпись с кол-вом прошедшего времени
    UILabel *gameTimerLabel = [[UILabel alloc] init];
    gameTimerLabel.font = [UIFont fontWithName:@"Digital-7 Mono"
                                          size:27];
    gameTimerLabel.textColor = [UIColor colorWithRed:255
                                               green:198
                                                blue:0
                                               alpha:1];
    gameTimerLabel.text = [NSString stringWithFormat:@"%04d", 0];
    gameTimerLabel.frame = CGRectMake(238, 6, 100, 50);
    gameTimerLabel.tag = kBGTimerViewTag;

    [self.view addSubview:gameTimerLabel];

//    на панель изображения накладываем надпись с кол-вом мин
    UILabel *minesCountLabel = [[UILabel alloc] init];
    minesCountLabel.font = [UIFont fontWithName:@"Digital-7 Mono"
                                           size:27];
    minesCountLabel.textColor = [UIColor colorWithRed:255
                                                green:198
                                                 blue:0
                                                alpha:1];
    minesCountLabel.text = [NSString stringWithFormat:@"%04d", _field.bombs];
    minesCountLabel.frame = CGRectMake(237, 36, 100, 50);
    minesCountLabel.tag = kBGMinesCountViewTag;

    [self.view addSubview:minesCountLabel];


//    добавляем кнопку "Назад"
    UIImage *backNormal = [UIImage imageNamed:@"back"];
    UIImage *backHighlighted = [UIImage imageNamed:@"back_down"];
    UIButton *back = [[UIButton alloc]
                                initWithFrame:CGRectMake(14, 22, backNormal.size.width, backNormal.size.height)];
    [back setImage:backNormal forState:UIControlStateNormal];
    [back setImage:backHighlighted forState:UIControlStateHighlighted];
    [back addTarget:self
             action:@selector(back:)
   forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:back];

//    добавляем сцену на SKView
    BGGameScene *scene = [[BGGameScene alloc]
                                       initWithSize:self.skView.bounds.size];
    scene.userInteractionEnabled = NO;
    [self.skView presentScene:scene];

//    добавляем определитель жестов - нажатие
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                            initWithTarget:self
                                                                                    action:@selector(tap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;

    [self.skView addGestureRecognizer:tapGestureRecognizer];

//    добавляем определитель жестов - удержание (для установление флажка)
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                                              initWithTarget:self
                                                                                                      action:@selector(longPress:)];
    longPressGestureRecognizer.numberOfTouchesRequired = 1;

    [self.skView addGestureRecognizer:longPressGestureRecognizer];

#ifdef DEBUG
    self.skView.showsDrawCount = YES;
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    self.skView.showsPhysics = YES;
#endif

//    заполняем SKView спрайтами с бомбами, цифрами и пустыми полями
//    потом накладываем на них траву
    [self fillGameSceneField];

//    запускаем таймер
    [self startGameTimer];
}

- (void)fillGameSceneField
{
    //    нода для хранения слоёв - заднего и переднего
    SKNode *compoundNode = [SKNode node];
    compoundNode.name = @"compoundNode";

//    нода для хранения первого слоя
    SKNode *layer1 = [SKNode node];
    layer1.userInteractionEnabled = NO;

//    нода для хранения второго слоя
    SKNode *layer2 = [SKNode node];
    layer2.name = @"grassTiles";

//    текстура с травой
    SKTexture *grassTexture = [SKTexture textureWithImageNamed:@"grass"];

//    заполняем первый слой - цифры, земля и сами бомбы
    for (NSUInteger indexCol = 0; indexCol < _field.cols; indexCol++) {
        for (NSUInteger indexRow = 0; indexRow < _field.rows; indexRow++) {
            NSInteger fieldValue = [_field valueForCol:indexCol
                                                   row:indexRow];
            SKTexture *texture;

            switch (fieldValue) {
                case BGFieldBomb: // бомба
                    texture = [SKTexture textureWithImageNamed:@"mine"];
                    break;

                case BGFieldEmpty: // земля
                    texture = [SKTexture textureWithImageNamed:@"earth"];
                    break;

                default:
                    texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"earth%d",
                                                                                          fieldValue]];
                    break;
            }

//            спрайт
            SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:texture];

//            устанавливаем размеры спрайта
            if ([BGSettingsManager sharedManager].cols == 12)
                tile.size = CGSizeMake(40, 40);
            else if ([BGSettingsManager sharedManager].cols == 15)
                tile.size = CGSizeMake(32, 32);
            else
                tile.size = CGSizeMake(20, 20);

//            позиционируем
            tile.anchorPoint = CGPointZero;
            CGFloat x = indexRow * tile.size.width;
            CGFloat y = indexCol * tile.size.height;
            tile.position = CGPointMake(x, y);
            tile.zPosition = 0;

//            добавляем на слой
            [layer1 addChild:tile];

//            накладываем слой с травой
            SKSpriteNode *grassTile = [SKSpriteNode spriteNodeWithTexture:grassTexture];
            grassTile.position = tile.position;
            grassTile.size = tile.size;
            grassTile.anchorPoint = CGPointZero;
            grassTile.userData = [@{
                    @"col" : @(indexCol),
                    @"row" : @(indexRow)
            } mutableCopy];
            grassTile.zPosition = 0;
            grassTile.name = [NSString stringWithFormat:@"%d.%d",
                                                        indexCol,
                                                        indexRow];

            [layer2 addChild:grassTile];
        }
    }

//    добавляем на поле первый слой
    [compoundNode addChild:layer1];

//    накладываем второй слой
    [compoundNode addChild:layer2];

//    добавляем всё на сцену
    [self.skView.scene addChild:compoundNode];
}

- (void)animateExplosionOnCellWithCol:(NSUInteger)col
                                  row:(NSUInteger)row
{
    BGLog();

//    TODO
}

- (void)openCellsFromCellWithCol:(NSUInteger)col
                             row:(NSUInteger)row
{
    BGLog();

//    определяем все ячейки, которые необходимо открыть
    NSMutableSet *usedCells = [NSMutableSet new];
    NSMutableArray *queue = [NSMutableArray new];
    NSArray *x = @[@0, @1, @0, @(-1), @1, @1, @(-1), @(-1)];
    NSArray *y = @[@(-1), @0, @1, @0, @(-1), @1, @1, @(-1)];

    [queue addObject:@(col)];
    [queue addObject:@(row)];
    [usedCells addObject:[NSString stringWithFormat:@"%d.%d", col, row]];

    while (queue.count > 0) {
        NSUInteger currentCol = [queue[0] unsignedIntegerValue];
        NSUInteger currentRow = [queue[1] unsignedIntegerValue];

        [queue removeObjectAtIndex:0];
        [queue removeObjectAtIndex:0];

//        удаляем с верхнего слоя тайл с травой
        NSString *nodeName = [NSString stringWithFormat:@"%d.%d",
                                                        currentCol,
                                                        currentRow];
        SKNode *grassNodeToRemoveFromParent = [[[self.skView.scene childNodeWithName:@"compoundNode"]
                                                                   childNodeWithName:@"grassTiles"]
                                                                   childNodeWithName:nodeName];

//        проверим, если на ячейке стоит флажок
//        стоит - не удаляем ячейку
        if ([grassNodeToRemoveFromParent childNodeWithName:@"flag"]) {
            continue;
        }

        [grassNodeToRemoveFromParent removeFromParent];

//        нет смысла продолжать открывать клетки, если текущий тайл с цифрой
        NSInteger value = [_field valueForCol:currentCol
                                          row:currentRow];

        if (value != BGFieldBomb && value != BGFieldEmpty) {
            continue;
        }

        for (NSUInteger k = 0; k < x.count; k++) {
            NSInteger newCol = currentCol + [y[k] integerValue];
            NSInteger newRow = currentRow + [x[k] integerValue];

            if (newCol >= 0 && newRow >= 0 && newCol < _field.cols && newRow < _field.rows) {
                NSString *cellName = [NSString stringWithFormat:@"%d.%d",
                                                                newCol,
                                                                newRow];

//                добавляем еще неиспользованную клетку, если она пустая
                if ([_field valueForCol:(NSUInteger) newCol
                                    row:(NSUInteger) newRow] != BGFieldBomb && ![usedCells containsObject:cellName]) {
                    [queue addObject:@(newCol)];
                    [queue addObject:@(newRow)];

                    [usedCells addObject:cellName];
                }
            }
        }
    }
}

- (void)openCellsWithBombs
{
    BGLog(@"%s", __FUNCTION__);

//    TODO
}

#pragma mark - Actions

- (void)back:(id)sender
{
    BGLog();

//    возвращаемся на главный экран
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tap:(UIGestureRecognizer *)sender
{
    BGLog();

    //    получаем координаты нажатия
    CGPoint touchPointGlobal = [sender locationInView:self.skView];
    CGPoint touchPoint = [self.skView convertPoint:touchPointGlobal
                                           toScene:self.skView.scene];

//    получаем ноду, которая находится в точке нажатия
    SKNode *touchedNode = [self.skView.scene nodeAtPoint:touchPoint];

//    смотрим, что находится под нодой
    if (touchedNode.userData != nil) {
        [touchedNode removeFromParent];

//        проверим значение, которое на поле
        NSUInteger col = [touchedNode.userData[@"col"] unsignedIntegerValue];
        NSUInteger row = [touchedNode.userData[@"row"] unsignedIntegerValue];
        NSInteger value = [_field valueForCol:col
                                          row:row];

        switch (value) {
            case BGFieldBomb:
                [self animateExplosionOnCellWithCol:col
                                                row:row];
                [self openCellsWithBombs];

                break;

            case BGFieldEmpty:
                [self openCellsFromCellWithCol:col
                                           row:row];

                break;

            default:
//                ничего не делаем
                break;
        }
    }
}

- (void)longPress:(UIGestureRecognizer *)sender
{
    BGLog();

//    получаем ноду, которая была нажата
    CGPoint touchPointGlobal = [sender locationInView:self.skView];
    CGPoint touchPoint = [self.skView convertPoint:touchPointGlobal
                                           toScene:self.skView.scene];
    SKNode *touchedNode = [self.skView.scene nodeAtPoint:touchPoint];

//    не обрабатываем начало длинного нажатия, нам нужно только "завершение"
    if (sender.state == UIGestureRecognizerStateBegan) {
        UILabel *minesCountLabel = (UILabel *) [self.view viewWithTag:kBGMinesCountViewTag];
        NSInteger minesRemainedToOpen = _field.bombs - flaggedMines;

        if (touchedNode.userData != nil && minesRemainedToOpen != 0) {
//        устанавливаем
            SKSpriteNode *flagTile = [SKSpriteNode spriteNodeWithImageNamed:@"flag"];
            flagTile.name = @"flag";
            flagTile.anchorPoint = CGPointZero;
            flagTile.size = ((SKSpriteNode *) touchedNode).size;

            [touchedNode addChild:flagTile];

//            обновляем значение кол-ва бомб
            flaggedMines++;
        } else if ([touchedNode.name isEqualToString:@"flag"]) {
//        снимаем
            [touchedNode removeFromParent];

//            обновляем значение кол-ва бомб
            flaggedMines--;
        }

        minesCountLabel.text = [NSString stringWithFormat:@"%04d",
                                                          _field.bombs - flaggedMines];
    }
}

- (void)updateTimerLabel:(id)sender
{
    BGLog();

    UILabel *timerLabel = (UILabel *) [self.view viewWithTag:kBGTimerViewTag];
    NSInteger timerValue = [timerLabel.text integerValue];

    timerValue++;

    timerLabel.text = [NSString stringWithFormat:@"%04d", timerValue];
}

@end
