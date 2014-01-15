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
@property (nonatomic, strong) NSArray *pawnsToDraw;
@property (nonatomic, strong) NSArray *slayerPawns;
@property (nonatomic, strong) NSArray *dragonPawns;

@end
