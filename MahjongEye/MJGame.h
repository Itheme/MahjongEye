//
//  MJGame.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJTileManager.h"

typedef enum GameStateEnum {
    sGameIsUninitialized = 0,
    sPlayerTurn = 1,
    sDragonTurn = 3,
    sPlayerTurnWaitingForAnimation = 100,
    sPlayerWon = 4,
    sPlayerLost = 5,
    sGameOver = 6
} GameState;

typedef enum GameAILevelEnum {
    aiStupid = 0,
    aiMedium = 1,
    aiCheater = 2
} GameAILevel;

@interface MJGame : NSObject

- (id) initWithManager:(MJTileManager *) mgr;

@end
