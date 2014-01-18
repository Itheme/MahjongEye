//
//  MJPawnContainer.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJGame.h"

@interface MJPawnContainer : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *pawnsOnField; // MJPawnInfos
// numbers
@property (nonatomic, strong) NSMutableArray *pawnsToDraw;
@property (nonatomic, strong) NSMutableArray *slayerPawns;
@property (nonatomic, strong) NSMutableArray *dragonPawns;
@property (nonatomic) GameState lastGameState;
@property (nonatomic) GameAILevel lastGameAI;
@property (nonatomic) BOOL userCouldProceed;

- (void) encodeWithCoder:(NSCoder *) encoder;
- (id) initWithCoder:(NSCoder *) decoder;
- (void) restoreField;

@end
