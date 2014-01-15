//
//  MJTileManager.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPawnContainer.h"

@interface MJTileManager : NSObject

@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, readonly, strong) NSArray *tiles;
@property (nonatomic, setter = setFieldSize:) CGSize fieldSize;

- (id) initWithTiles:(UIImage *) tiles Field:(NSArray *)field Eye:(NSArray *)eye;

- (void) fillPawnContainer:(MJPawnContainer *) container;
- (void) userDraw:(MJPawnContainer *) container;
- (void) dragonDraws:(MJPawnContainer *) container;
- (void) fillUserHand:(MJPawnContainer *) container;

@end
