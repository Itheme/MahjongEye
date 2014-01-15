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

- (id) initWithTiles:(UIImage *) tiles Field:(NSArray *)field Eye:(NSArray *)eye;

- (void) fillPawnContainer:(MJPawnContainer *) container;

@end
