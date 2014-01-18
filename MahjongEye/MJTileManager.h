//
//  MJTileManager.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJGame.h"

@class MJPawnContainer;

@protocol BackupDelegate

- (id) backupData;
//- (void) restoreFrom:(id)backup;

@end

@interface MJTileManager : NSObject

@property (nonatomic, readonly, getter = getTileSize) CGSize tileSize;
//@property (nonatomic, readonly, strong) NSArray *tiles;
@property (nonatomic, setter = setFieldSize:) CGSize fieldSize;
@property (nonatomic, setter = setHorizontal:) BOOL horizontal;
@property (nonatomic, strong) MJPawnContainer *lastPawnContainer;
@property (nonatomic, weak) id<BackupDelegate> backupDelegate;
@property (nonatomic) GameAILevel gameDifficultyPresentedInUI;

- (id) initWithTiles:(UIImage *) tiles Field:(NSArray *)field Eye:(NSArray *)eye Horizontal:(BOOL) horizontalTiles;

- (void) fillPawnContainer:(MJPawnContainer *) container;
- (void) userDraw:(MJPawnContainer *) container;
- (void) dragonDraws:(MJPawnContainer *) container;
- (void) fillUserHand:(MJPawnContainer *) container;
- (UIImage *)getTileAtIndex:(NSUInteger) index;

// state management
- (void) tryToLoad;
- (void) saveCurrentState;

@end
