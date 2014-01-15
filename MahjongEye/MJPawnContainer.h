//
//  MJPawnContainer.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPawnContainer : NSObject

@property (nonatomic, strong) NSArray *pawnsOnField; // MJPawnInfos
// numbers
@property (nonatomic, strong) NSMutableArray *pawnsToDraw;
@property (nonatomic, strong) NSMutableArray *slayerPawns;
@property (nonatomic, strong) NSMutableArray *dragonPawns;

@end
