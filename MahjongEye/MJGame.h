//
//  MJGame.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJTileManager.h"

@interface MJGame : NSObject

- (id) initWithManager:(MJTileManager *) mgr;
- (void) start;

@end
