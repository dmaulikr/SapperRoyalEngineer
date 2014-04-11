//
// Copyright (C) 4/11/14  Andrew Shmig ( andrewshmig@yandex.ru )
// Russian Bleeding Games. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

#import <SpriteKit/SpriteKit.h>
#import "BGTexturePreloader.h"
#import "BGLog.h"


@implementation BGTexturePreloader

#pragma mark - Class

+ (id)shared
{
    static dispatch_once_t once;
    static BGTexturePreloader *shared;

    dispatch_once(&once, ^
    {
        shared = [[self alloc] init];
    });

    return shared;
}

#pragma mark - Preloading

- (void)preloadAllAtlases
{
    BGLog();

    SKTextureAtlas *tilesAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
    _tilesAtlas = tilesAtlas;

    [SKTextureAtlas preloadTextureAtlases:@[tilesAtlas]
                    withCompletionHandler:^
                    {
                    }];
}

@end