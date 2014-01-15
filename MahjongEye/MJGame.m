//
//  MJGame.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJGame.h"

@interface MJGame () {
}

@property (nonatomic, weak) MJTileManager *manager;

@end

@implementation MJGame

- (id) initWithManager:(MJTileManager *) mgr {
    self = [super init];
    if (self) {
        self.manager = mgr;
    }
    return self;
}

- (void) start {
#warning class not used yet
}
@end
