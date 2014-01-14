//
//  MJTileManager.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJTileManager : NSObject

@property (nonatomic, readonly) CGSize tileSize;

- (id) initWithTiles:(UIImage *) tiles Field:(NSArray *)field Eye:(NSArray *)eye;

@end
