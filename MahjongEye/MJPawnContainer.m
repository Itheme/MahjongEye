//
//  MJPawnContainer.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJPawnContainer.h"
#import "MJPawnInfo.h"

@interface MJPawnContainer ()

@property (nonatomic, strong) NSArray *fieldPieces;

@end

@implementation MJPawnContainer

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.pawnsToDraw forKey:@"pawnsToDraw"];
    [encoder encodeObject:self.slayerPawns forKey:@"slayerPawns"];
    [encoder encodeObject:self.dragonPawns forKey:@"dragonPawns"];
    [encoder encodeObject:@((int)self.lastGameState) forKey:@"lastGameState"];
    [encoder encodeObject:@((int)self.lastGameAI) forKey:@"gameAI"];
    [encoder encodeObject:@(self.userCouldProceed) forKey:@"userCouldProceed"];
    
    NSMutableArray *fieldPieces = [[NSMutableArray alloc] init];
    for (MJPawnInfo *p in self.pawnsOnField)
        [fieldPieces addObject:@(p.currentPawn)];
        
    [encoder encodeObject:fieldPieces forKey:@"fieldPieces"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.pawnsToDraw = [decoder decodeObjectForKey:@"pawnsToDraw"];
        self.slayerPawns = [decoder decodeObjectForKey:@"slayerPawns"];
        self.dragonPawns = [decoder decodeObjectForKey:@"dragonPawns"];
        NSNumber *n = [decoder decodeObjectForKey:@"lastGameState"];
        self.lastGameState = (GameState)(n.intValue);
        n = [decoder decodeObjectForKey:@"gameAI"];
        self.lastGameAI = (GameAILevel)(n.intValue);
        n = [decoder decodeObjectForKey:@"userCouldProceed"];
        self.userCouldProceed = n.boolValue;
        self.fieldPieces = [decoder decodeObjectForKey:@"fieldPieces"];
    }
    return self;
}

- (void) restoreField {
    [self.pawnsOnField enumerateObjectsUsingBlock:^(MJPawnInfo *p, NSUInteger idx, BOOL *stop) {
        NSNumber *n = self.fieldPieces[idx];
        p.currentPawn = n.intValue;
    }];
}

@end
