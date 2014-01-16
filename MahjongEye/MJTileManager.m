//
//  MJTileManager.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJTileManager.h"
#import "MJPawnInfo.h"

@interface MJTileManager () {
    NSUInteger fieldWidth;  // in quaters of pawns
    NSUInteger fieldHeight; // in quaters of pawns
}

@property (nonatomic) CGSize tileSize;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, strong) NSArray *pawns;

@end

@implementation MJTileManager

@synthesize fieldSize;

- (void)setupTiles:(UIImage *)tiles {
    NSMutableArray *t = [[NSMutableArray alloc] init];
    CGSize ts = tiles.size;
    self.tileSize = CGSizeMake(ts.width / 9.0, ts.height / 5.0);
    CGColorSpaceRef cspace = CGColorSpaceCreateDeviceRGB();
    for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {
            if ((y > 2) && (x > 7)) continue;
            CGRect r = CGRectMake(x * self.tileSize.width, y * self.tileSize.height, self.tileSize.width, self.tileSize.height);
            CGImageRef cgIm = CGImageCreateWithImageInRect(tiles.CGImage, r);
            UIImage *im = [UIImage imageWithCGImage:cgIm];
            if ((y > 2) && (x < 4)) { // one image
                [t addObject:im];
            } else {
                [t addObject:im];
                [t addObject:im];
                [t addObject:im];
                [t addObject:im];
            }
        }
    }
    self.tiles = t;
    CGColorSpaceRelease(cspace);
}

- (NSString *)shrinked:(NSString *)string {
    unichar chars[string.length / 2];
    for (int i = 0; i < string.length; i++) {
        chars[i/2] = [string characterAtIndex:i];
        i++;
    }
    return [NSString stringWithCharacters:chars length:string.length/2];
}

- (void)setupPawnRelations:(NSArray *)eye field:(NSArray *)field {
    NSMutableArray *allPawns = [[NSMutableArray alloc] init];
    NSMutableDictionary *pawnAssociations = [[NSMutableDictionary alloc] init];
    fieldWidth = [((NSString *)eye[0]) length];
    fieldHeight = eye.count;
    __block NSString *everyLine0 = @"";
    __block NSString *everyLine1 = @"";
    [field enumerateObjectsUsingBlock:^(NSArray *map, NSUInteger level, BOOL *stop) {
        NSRange r;
        r.length = 1;
        NSArray *level0Field = field[0];
        for (int y = 0; y < fieldHeight; y++) {
            NSString *mapRow = map[y];
            NSString *level0Row = level0Field[y];
            for (int x = 0; x < fieldWidth; x++) {
                r.location = x;
                NSString *pawnKey = [mapRow substringWithRange:r];
                if ([pawnKey isEqualToString:@"."])
                    continue;
                if (pawnAssociations[pawnKey]) continue; // pawn already parsed
                Eye e = eField;
                if (level == 0) {
                    NSString *eyeKey = [eye[y] substringWithRange:r];
                    e = eyeKey.intValue;
                }
                MJPawnInfo *pawn = [[MJPawnInfo alloc] initWithCoordiante:CGPointMake(x * 0.5, y * 0.5) Eye:e Level:level];
                [pawnAssociations setObject:pawn forKey:pawnKey];
                if (level == 1) {
                    pawnKey = [level0Row substringWithRange:r];
                    pawn.couldBePlacedIfExists = pawnAssociations[pawnKey];
                }
                [allPawns addObject:pawn];
            }
            if (level == 0)
                everyLine0 = [NSString stringWithFormat:@"%@..%@", everyLine0, mapRow, nil];
            else
                everyLine1 = [NSString stringWithFormat:@"%@..%@", everyLine1, mapRow, nil];
        }
    }];
    // finding blocking pawns
    NSRange whole = NSMakeRange(0, everyLine0.length);
    [pawnAssociations enumerateKeysAndObjectsUsingBlock:^(NSString *pawnKey, MJPawnInfo *pawn, BOOL *stop) {
        NSRegularExpression *leftExp, *rightExp;
        NSError *err = nil;
        NSString *everyLine = (pawn.level == 0)?everyLine0:everyLine1;
        leftExp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"[^.%@]%@", pawnKey, pawnKey, nil] options:0 error:&err];
        NSRange leftMatch = [leftExp rangeOfFirstMatchInString:everyLine options:0 range:whole];
        if (leftMatch.location != NSNotFound) {
            // has left neighbour. Assuming we have only one blocking neighbour at each side
            rightExp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@[^.%@]", pawnKey, pawnKey, nil] options:0 error:&err];
            NSRange rightMatch = [rightExp rangeOfFirstMatchInString:everyLine options:0 range:whole];
            if (rightMatch.location != NSNotFound) { // blocked by sides
                NSString *matchString = [everyLine substringWithRange:leftMatch];
                NSString *letter = [matchString substringToIndex:1];
                MJPawnInfo *leftBlocker = pawnAssociations[letter];
                matchString = [everyLine substringWithRange:rightMatch];
                letter = [matchString substringFromIndex:1];
                MJPawnInfo *rightBlocker = pawnAssociations[letter];
                if (pawn.level == 0) { // maybe we have top blocker too?
                    MJPawnInfo *topBlocker = nil;
                    for (MJPawnInfo *otherPawn in allPawns)
                        if ([otherPawn.couldBePlacedIfExists isEqual:pawn]) {
                            topBlocker = otherPawn;
                            break;
                        }
                    if (topBlocker) {
                        pawn.blockedIfExists = @[leftBlocker, rightBlocker, topBlocker];
                        pawn.noSuiteWhenBlocked = YES;
                    }
                }
                if (!pawn.blockedIfExists) {
                    pawn.blockedIfExists = @[leftBlocker, rightBlocker];
                    NSLog(@"%@ %.1f:%.1f %.1f:%.1f %.1f:%.1f", pawnKey, leftBlocker.coordinate.x, leftBlocker.coordinate.y, pawn.coordinate.x, pawn.coordinate.y, rightBlocker.coordinate.x, rightBlocker.coordinate.y);
                }
            }
        }
    }];
    self.pawns = allPawns;
}

- (id) initWithTiles:(UIImage *) tiles Field:(NSArray *)field Eye:(NSArray *)eye {
    self = [super init];
    if (self) {
        [self setupTiles:tiles];
        [self setupPawnRelations:eye field:field];
    }
    return self;
}

- (void) fillPawnContainer:(MJPawnContainer *) container {
    NSMutableArray *allPawns = [[NSMutableArray alloc] init];
    for (NSUInteger i = self.tiles.count; i--; )
        [allPawns insertObject:@(i) atIndex:1.0*rand()*allPawns.count/RAND_MAX];
    container.pawnsOnField = [self.pawns copy];
    for (MJPawnInfo *p in container.pawnsOnField) {
        if (p.eye == eField)
            p.currentPawn = -1;
        else {
            NSNumber *n = allPawns.lastObject;
            p.currentPawn = [n integerValue];
            [allPawns removeLastObject];
        }
    }
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (int i = 3; i--; [allPawns removeLastObject]) {
        [a addObject:allPawns.lastObject];
    }
    container.dragonPawns = a;
    a = [[NSMutableArray alloc] init];
    for (int i = 6; i--; [allPawns removeLastObject]) {
        [a addObject:allPawns.lastObject];
    }
    container.slayerPawns = a;
    container.pawnsToDraw = allPawns;
    [container willChangeValueForKey:@"pawnsToDraw"];
    [container didChangeValueForKey:@"pawnsToDraw"];
}

- (void) userDraw:(MJPawnContainer *) container {
    if (container.pawnsToDraw.count > 0) {
        [container.slayerPawns addObject:[container.pawnsToDraw lastObject]];
        [container willChangeValueForKey:@"pawnsToDraw"];
        [container.pawnsToDraw removeLastObject];
        [container didChangeValueForKey:@"pawnsToDraw"];
    }
}

- (void) dragonDraws:(MJPawnContainer *) container {
    if (container.pawnsToDraw.count > 0) {
        [container.dragonPawns addObject:[container.pawnsToDraw lastObject]];
        [container willChangeValueForKey:@"pawnsToDraw"];
        [container.pawnsToDraw removeLastObject];
        [container didChangeValueForKey:@"pawnsToDraw"];
    }
}

- (void) fillUserHand:(MJPawnContainer *) container {
    while ((container.pawnsToDraw.count > 0) && (container.slayerPawns.count < 6)) {
        [self userDraw:container];
    }
}

- (void) setFieldSize:(CGSize)aFieldSize {
    fieldSize = aFieldSize;
    self.tileSize = CGSizeMake(fieldSize.width * 2.0 / fieldWidth, fieldSize.height * 2.0 / fieldHeight);
#warning adjust tile rotation here
}


@end
