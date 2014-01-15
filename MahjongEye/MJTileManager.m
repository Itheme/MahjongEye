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
    int fieldWidth;  // in quaters of pawns
    int fieldHeight; // in quaters of pawns
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

- (void)setupPawnRelations:(NSArray *)eye field:(NSArray *)field {
    NSMutableArray *allPawns = [[NSMutableArray alloc] init];
    NSMutableDictionary *pawnAssociations = [[NSMutableDictionary alloc] init];
    fieldWidth = [((NSString *)eye[0]) length];
    fieldHeight = eye.count;
    __block NSString *everyLine = @"";
    [field enumerateObjectsUsingBlock:^(NSArray *map, NSUInteger level, BOOL *stop) {
        NSRange r;
        r.length = 1;
        for (int y = 0; y < fieldHeight; y++) {
            for (int x = 0; x < fieldWidth; x++) {
                r.location = x;
                NSString *pawnKey = [map[y] substringWithRange:r];
                if ([pawnKey isEqualToString:@"."])
                    continue;
                Eye e = eField;
                if (level == 0) {
                    NSString *eyeKey = [eye[y] substringWithRange:r];
                    e = eyeKey.intValue;
                }
                if (pawnAssociations[pawnKey]) continue; // pawn already parsed
                MJPawnInfo *pawn = [[MJPawnInfo alloc] initWithCoordiante:CGPointMake(x * 0.5, y * 0.5) Eye:e Level:level];
                [pawnAssociations setObject:pawn forKey:pawnKey];
                if (level == 1) {
                    NSArray *level0Field = field[0];
                    pawnKey = [level0Field[y] substringWithRange:r];
                    pawn.couldBePlacedIfExists = pawnAssociations[pawnKey];
                }
                [allPawns addObject:pawn];
            }
            everyLine = [NSString stringWithFormat:@"%@.%@", everyLine, map[y], nil];
        }
    }];
    // finding blocking pawns
    NSRange whole = NSMakeRange(0, everyLine.length);
    [pawnAssociations enumerateKeysAndObjectsUsingBlock:^(NSString *pawnKey, MJPawnInfo *pawn, BOOL *stop) {
        NSRegularExpression *leftExp, *rightExp;
        NSError *err = nil;
        leftExp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"[^.%@]%@", pawnKey, pawnKey, nil] options:NSRegularExpressionCaseInsensitive error:&err];
        NSRange leftMatch = [leftExp rangeOfFirstMatchInString:everyLine options:0 range:whole];
        if (leftMatch.location != NSNotFound) {
            // has left neighbour. Assuming we have only one blocking neighbour at each side
            rightExp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@[^.%@]", pawnKey, pawnKey, nil] options:NSRegularExpressionCaseInsensitive error:&err];
            NSRange rightMatch = [rightExp rangeOfFirstMatchInString:everyLine options:0 range:whole];
            if (rightMatch.location != NSNotFound) { // blocked by sides
                NSString *letter = [[everyLine substringWithRange:leftMatch] substringToIndex:1];
                MJPawnInfo *leftBlocker = pawnAssociations[letter];
                letter = [[everyLine substringWithRange:rightMatch] substringFromIndex:1];
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
                if (!pawn.blockedIfExists)
                    pawn.blockedIfExists = @[leftBlocker, rightBlocker];
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
    for (int i = self.tiles.count; i--; )
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
}

- (void) userDraw:(MJPawnContainer *) container {
    if (container.pawnsToDraw.count > 0) {
        [container.slayerPawns addObject:[container.pawnsToDraw lastObject]];
        [container.pawnsToDraw removeLastObject];
    }
}

- (void) setFieldSize:(CGSize)aFieldSize {
    fieldSize = aFieldSize;
    self.tileSize = CGSizeMake(fieldSize.width * 2.0 / fieldWidth, fieldSize.height * 2.0 / fieldHeight);
#warning adjust tile rotation here
}


@end
