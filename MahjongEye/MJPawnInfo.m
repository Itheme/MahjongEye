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
        self.possiblePawn = -1;
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

- (BOOL) currentEquals:(MJPawnInfo *)p {
    if (p) {
        int p0 = self.currentPawn;
        int p1 = p.currentPawn;
        return (p0 >> 2) == (p1 >> 2);
    }
    return NO;
}

- (BOOL) currentEqualsNumber:(NSNumber *)n {
    if (n) {
        int p0 = self.currentPawn;
        int p1 = n.intValue;
        return (p0 >> 2) == (p1 >> 2);
    }
    return NO;
}

@end

@implementation MJPawnInfo (PossibilityResearch)

- (BOOL) getPossibleBlocked {
    if (self.blockedIfExists) {
        if (self.blockedIfExists.count > 2) {// 0-1 are side blockers, 2 is top blocker
            MJPawnInfo *topmostBlocker = self.blockedIfExists[2];
            if ((topmostBlocker.currentPawn >= 0) || (topmostBlocker.possiblePawn >= 0))
                return YES;
        }
        MJPawnInfo *leftBlocker = self.blockedIfExists[0];
        MJPawnInfo *rightBlocker = self.blockedIfExists[1];
        return ((leftBlocker.currentPawn >= 0) || (leftBlocker.possiblePawn >= 0)) && ((rightBlocker.currentPawn >= 0) || (rightBlocker.possiblePawn >= 0));
    }
    return NO;
}

- (BOOL) getCouldBePossiblePlaced {
    if (self.couldBePlacedIfExists)
        return (self.couldBePlacedIfExists.currentPawn >= 0) || (self.couldBePlacedIfExists.possiblePawn >= 0);
    return YES;
}

- (BOOL) currentOrPossibleEqualsNumber:(NSNumber *)n {
    if (n) {
        int p0;
        if (self.currentPawn >= 0)
            p0 = self.currentPawn;
        else
            p0 = self.possiblePawn;
        int p1 = n.intValue;
        return (p0 >> 2) == (p1 >> 2);
    }
    return NO;
}


@end
