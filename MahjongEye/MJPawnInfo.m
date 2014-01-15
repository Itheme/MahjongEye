//
//  MJPawnInfo.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJPawnInfo.h"

@implementation MJPawnInfo

@synthesize coordinate;

- (id) initWithCoordiante:(CGPoint) p Eye:(Eye) e Level:(NSUInteger) lev {
    self = [super init];
    if (self) {
        self.coordinate = p;
        self.eye = e;
        self.level = lev;
        self.currentPawn = -1;
    }
    return self;
}

- (BOOL) getBlocked {
    if (self.blockedIfExists) {
        if (self.blockedIfExists.count > 2) // 0-1 are side blockers, 2 is top blocker
            if (((MJPawnInfo *)self.blockedIfExists[2]).currentPawn >= 0)
                return YES;
        return (((MJPawnInfo *)self.blockedIfExists[0]).currentPawn >= 0) && (((MJPawnInfo *)self.blockedIfExists[1]).currentPawn >= 0);
    }
    return NO;
}

- (BOOL) getCouldBePlaced {
    if (self.couldBePlacedIfExists)
        return self.couldBePlacedIfExists.currentPawn >= 0;
    return YES;
}

- (BOOL) almostSameCoordinate:(CGPoint) p {
    return ((ABS(p.x - coordinate.x) < 0.5) && (ABS(p.y - coordinate.y) < 0.5));
}

@end
