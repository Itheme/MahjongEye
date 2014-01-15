//
//  MJPawnInfo.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum EyeEnum {
    eField = 0,
    eGray = 1,
    eBlack = 2
} Eye;

@interface MJPawnInfo : NSObject

@property (nonatomic) CGPoint coordinate;
@property (nonatomic) BOOL noSuiteWhenBlocked;
@property (nonatomic) NSArray *blockedIfExists;
@property (nonatomic) MJPawnInfo *couldBePlacedIfExists;
@property (nonatomic) int currentPawn; // -1 no pawn
@property (nonatomic) Eye eye; // 0 - no eye; 1 - gray; 2 - black;
@property (nonatomic) NSUInteger level;
@property (nonatomic, readonly, getter = getBlocked) BOOL blocked;
@property (nonatomic, readonly, getter = getCouldBePlaced) BOOL couldBePlaced;

- (id) initWithCoordiante:(CGPoint) p Eye:(Eye) e Level:(NSUInteger) lev;
- (BOOL) almostSameCoordinate:(CGPoint) p;
- (BOOL) currentEquals:(MJPawnInfo *)p;
- (BOOL) currentEqualsNumber:(NSNumber *)n;

@end
