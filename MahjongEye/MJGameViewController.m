//
//  MJGameViewController.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJGameViewController.h"
#import "MJAppDelegate.h"
#import "MJPawnInfo.h"
#import "MJTileManager.h"

typedef enum GameStateEnum {
    sGameIsUninitialized = 0,
    sPlayerTurnShouldPlacePawn = 1,
    sPlayerTurnCouldProceed = 2,
    sDragonTurn = 3,
    //sPlayerTurnFieldHL = 1,
    //sPlayerTurnFieldPawnSelected = 2,
    //sPlayerTurnFieldPawnSelectedHL2 = 3,
    //sPlayerTurnHandPawnSelected = 4,
    sPlayerTurnWaitingForAnimation = 100,
    sPlayerWon = 4,
    sPlayerLost = 5,
    sGameOver = 6
} GameState;

typedef enum HighlightedStateEnum {
    hlNone = 0,
    hlFieldHL = 1,
    hlFieldSelected = 2,
    hlFieldSelectedFieldHL = 3,
    hlHandSelected = 4,
    hlHandSelectedFieldHL = 5,
} HighlightedState;

typedef enum PawnAvailabilityEnum {
    aToPut = 1,
    aToPeek = 2,
    aToPutOrPeek = 3
} PawnAvailability;

@interface MJGameViewController () {
    CGSize handScale;
}

@property (nonatomic, strong) NSMutableArray *pawnViews;
@property (nonatomic, strong) UIView *hlViewHand;
@property (nonatomic, strong) UIImageView *hlViewField0;
@property (nonatomic, strong) UIImageView *hlViewField1;

@property (nonatomic, weak) MJTileManager *manager;

@property (nonatomic, strong) UIImage *suiteImage0;
@property (nonatomic, strong) UIImage *suiteImage1;
@property (nonatomic, setter = setState:) GameState state;
@property (nonatomic, setter = setHighlightState:) HighlightedState highlighState;

@property (nonatomic, strong) NSNumber *hlHandPawn;
@property (nonatomic, strong) NSArray *hlFieldPawns0; // MJPawnInfo
@property (nonatomic, strong) NSArray *hlFieldPawns1; // MJPawnInfo

@property (nonatomic, strong) NSNumber *hlDragonPawn;

@property (nonatomic, strong) UIAlertView *lastAlert;

@end

@implementation MJGameViewController

@synthesize pawns;
@synthesize state, highlighState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.suiteImage0 = [UIImage imageNamed:@"pawnBack0"];
    self.suiteImage1 = [UIImage imageNamed:@"pawnBack1"];
    self.field.delegate = self;
    MJAppDelegate *appDelegate = (MJAppDelegate *)[UIApplication sharedApplication].delegate;
    self.manager = appDelegate.tileManager;
}

- (UIImageView *) defaultCursorView {
    CGSize fs = self.manager.tileSize;
    UIImageView *res = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    res.image = [UIImage imageNamed:@"cursor.png"];
    //res = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    res.hidden = NO;
    res.alpha = 0.5;
    //res.opaque = YES;
    res.userInteractionEnabled = YES;
    //res.backgroundColor = [UIColor yellowColor];
    return res;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.state == sGameIsUninitialized) {
        self.drawButton.enabled = NO;
        self.doneButton.enabled = NO;
        self.manager.fieldSize = self.field.bounds.size;
        self.pawnViews = [[NSMutableArray alloc] init];
        handScale = CGSizeMake(self.manager.fieldSize.width / 6, 60);
        CGSize fs = self.manager.tileSize;
        MJPawnContainer *c = [[MJPawnContainer alloc] init];
        [self.manager fillPawnContainer:c];
        self.pawns = c;
        self.hlViewField0 = [self defaultCursorView];
        self.hlViewField1 = [self defaultCursorView];
    
        self.hlViewHand = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
        self.hlViewHand.hidden = NO;
        self.hlViewHand.alpha = 0.5;
        self.hlViewHand.userInteractionEnabled = YES;
        self.hlViewHand.backgroundColor = [UIColor yellowColor];
    
        self.field.container = self.pawns;
        self.state = sPlayerTurnShouldPlacePawn;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"pawnsToDraw"])
        self.restPawnsCountLabel.text = [NSString stringWithFormat:@"%d", self.pawns.pawnsToDraw.count, nil];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect) pawnRectBy:(MJPawnInfo *)p {
    CGSize fs = self.manager.tileSize;
    CGPoint topLeft = p.coordinate;
    topLeft.x *= fs.width;
    topLeft.y *= fs.height;
    if (p.level > 0) {
        topLeft.x -= 2;
        topLeft.y -= 2;
    }
    return CGRectMake(topLeft.x, topLeft.y, fs.width, fs.height);
}

- (void) addPawnViewFor:(MJPawnInfo *)p {
    if (p.currentPawn >= 0) {
        MJPawnView *v = [[MJPawnView alloc] initWithFrame:[self pawnRectBy:p] Tile:self.manager.tiles[p.currentPawn] HLImage:p.noSuiteWhenBlocked?self.suiteImage0:self.suiteImage1];
        v.info = p;
        [self.field addSubview:v];
        if (p.blocked)
            v.highlighted = YES;
        [self.pawnViews addObject:v];
        if (p.level > 0) return;
        for (MJPawnView *xv in self.pawnViews) {
            if (xv.info && (xv.info.level > 0)) {
                CGPoint xvp = xv.info.coordinate;
                if (((xvp.y > p.coordinate.y) && (xvp.y < p.coordinate.y + 2)) || ((xvp.y == p.coordinate.y) && (xvp.x > p.coordinate.x)))
                    [self.field bringSubviewToFront:xv];
            }
        }
    }
}

- (void) setPawnContainer:(MJPawnContainer *)apawns {
    for (MJPawnView *v in self.pawnViews) {
        [v removeFromSuperview];
    }
    [self.pawnViews removeAllObjects];
    if (apawns) {
        if (pawns)
            [pawns removeObserver:self forKeyPath:@"pawnsToDraw"];
        [apawns addObserver:self forKeyPath:@"pawnsToDraw" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    pawns = apawns;
    [self observeValueForKeyPath:@"pawnsToDraw" ofObject:pawns change:nil context:nil];
    CGSize fs = self.manager.tileSize;
    __block CGRect r = CGRectMake(0, 0, fs.width, fs.height);
    for (MJPawnInfo *p in pawns.pawnsOnField) {
        [self addPawnViewFor:p];
    }
    r.size = handScale;
    [pawns.slayerPawns enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
        r.origin.x = idx * r.size.width;
        r.origin.y = CGRectGetMaxY(self.field.frame);
        MJPawnView *v = [[MJPawnView alloc] initWithFrame:r Tile:self.manager.tiles[n.integerValue] HLImage:self.suiteImage1 Delegate:self];
#warning update HL image when it comes to field
        v.handPawn = n;
        [self.view addSubview:v];
        [self.pawnViews addObject:v];
    }];
    [pawns.dragonPawns enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
        r.origin.x = CGRectGetMaxX(self.field.frame);
        r.origin.y = CGRectGetMinY(self.field.frame) + (idx * r.size.height);
        MJPawnView *v = [[MJPawnView alloc] initDragonPawnWithFrame:r Tile:self.manager.tiles[n.integerValue] HLImage:self.suiteImage1];
#warning update HL image when it comes to field
        v.handPawn = n;
        [self.view addSubview:v];
        [self.pawnViews addObject:v];
    }];
}

- (void) doAI {
    MJPawnInfo *target = nil;
    // do we need to cover the eye?
    for (MJPawnInfo *p in pawns.pawnsOnField)
        if ((p.eye > eField) && (p.currentPawn < 0)) {
            if (target) {
                if (target.eye < p.eye) {
                    target = p;
                    break;
                }
            } else
                target = p;
        }
    // Now just stupid pawns putting
    if (target == nil) {
        while (true) {
            int i = 1.0*pawns.pawnsOnField.count*rand()/RAND_MAX;
            MJPawnInfo *p = pawns.pawnsOnField[i];
            if ((p.currentPawn < 0) && (p.couldBePlaced)) {
                target = p;
                break;
            }
        }
    }
#warning improve AI here
    self.hlDragonPawn = nil;
    // Now just stupid pawns fetching
    if (pawns.dragonPawns.count > 0) {
        self.hlDragonPawn = pawns.dragonPawns.lastObject;
    }
    [self performSelectorOnMainThread:@selector(dragonPuts:) withObject:target waitUntilDone:YES];
}

- (BOOL) checkGameIsNotOver {
    BOOL win = NO;
    BOOL loose = NO;
    if (pawns.dragonPawns == 0) {
        int opened = 0;
        int total = 0;
        for (MJPawnInfo *p in pawns.pawnsOnField) {
            if (p.eye) {
                if (p.currentPawn < 0)
                    opened++;
                total++;
            }
        }
        if (opened > total / 2)
            win = YES;
    } else {
        loose = YES;
        for (MJPawnInfo *p in pawns.pawnsOnField) {
            if (p.currentPawn < 0) {
                loose = NO;
                break;
            }
        }
    }
    if (win)
        self.state = sPlayerWon;
    else {
        if (loose)
            self.state = sPlayerLost;
    }
    if (win)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lastAlert = [[UIAlertView alloc] initWithTitle:@"You win!" message:@"Congratulations! You have defeated the dragon" delegate:self cancelButtonTitle:@"Good" otherButtonTitles:nil];
        });
    if (loose)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lastAlert = [[UIAlertView alloc] initWithTitle:@"You lost!" message:@"You failed to defeat dragon" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        });
    return !(win || loose);
}

- (void)setState:(GameState)aState {
    if (state == aState) return;
    state = aState;
    self.doneButton.enabled = aState == sPlayerTurnCouldProceed;
    if (aState == sDragonTurn) {
        if ([self checkGameIsNotOver])
            [self performSelectorInBackground:@selector(doAI) withObject:nil];
    } else {
        if (aState == sPlayerTurnShouldPlacePawn) {
#warning switch this state to could proceed if nothing to draw
            [self.manager fillUserHand:pawns];
            [self rearrangeHand];
            [self checkGameIsNotOver];
        }
    }
#warning present helping labels somewhere...
}

- (void) setHighlightState:(HighlightedState)aHighlighState {
    if (aHighlighState == highlighState) return;
    highlighState = aHighlighState;
    switch (aHighlighState) {
        case hlNone:
            [self.hlViewHand removeFromSuperview];
            [self.hlViewField0 removeFromSuperview];
            [self.hlViewField1 removeFromSuperview];
            break;
        case hlFieldHL:
        case hlFieldSelected:
            [self.hlViewField1 removeFromSuperview];
        case hlFieldSelectedFieldHL:
            [self.hlViewHand removeFromSuperview];
            break;
        case hlHandSelected:
            [self.hlViewField0 removeFromSuperview];
        case hlHandSelectedFieldHL:
            [self.hlViewField1 removeFromSuperview];
            break;
    }
}

- (MJPawnInfo *) chooseBestPawnOf:(MJPawnInfo *)p0 P1:(MJPawnInfo *)p1 For:(PawnAvailability) available {
    if (available == aToPutOrPeek) {
        MJPawnInfo *p = [self chooseBestPawnOf:p0 P1:p1 For:aToPeek];
        if (p)
            return p;
        return [self chooseBestPawnOf:p0 P1:p1 For:aToPut];
    }
    if (p0) {
        if (p1) {
            if (available == aToPeek) {
                if (p1.currentPawn >= 0) {
                    if (p1.blocked)
                        return nil;
                    return p1;
                }
                return [self chooseBestPawnOf:p0 P1:nil For:available];
            } else {
                if (p1.currentPawn >= 0)
                    return nil;
                if (p0.currentPawn >= 0)
                    return p1;
                return p0;
            }
        } else {
            if (available == aToPeek) {
                if (p0.currentPawn >= 0) {
                    if (p0.blocked)
                        return nil;
                    return p0;
                }
                return nil;
            } else {
                if (p0.currentPawn >= 0)
                    return nil;
                return p0;
            }
        }
    } else {
        if (p1)
            return [self chooseBestPawnOf:p1 P1:nil For:available];
        return nil;
    }
}

- (NSArray *) pawnsInP:(CGPoint) p Rect:(CGRect *)r Available:(PawnAvailability) available {
#warning ADD MULTILEVEL PARAMS!
    CGSize ts = self.manager.tileSize;
    p.x /= ts.width;
    p.y /= ts.height;
    p.x -= 0.5;
    p.y -= 0.5;
    MJPawnInfo *p0 = nil;
    MJPawnInfo *p1 = nil;
    for (MJPawnInfo *pawn in self.pawns.pawnsOnField) {
        if ([pawn almostSameCoordinate:p]) {
            if (p0) {
                p1 = pawn;
                break;
            } else
                p0 = pawn;
        }
    }
    if ((p0 && p1) && (p0.level > p1.level)) {
        MJPawnInfo *px = p0;
        p0 = p1;
        p1 = px;
    }
    MJPawnInfo *best = [self chooseBestPawnOf:p0 P1:p1 For:available];
    if (best) {
        *r = CGRectMake(best.coordinate.x * ts.width, best.coordinate.y * ts.height, ts.width, ts.height);
        if (p0) {
            if (p1)
                return @[p0, p1];
            return @[p0];
        }
    }
    return nil;
}

#pragma mark - cursor views manipulation methods

- (void) addFieldHL:(int) hilitedIndex Rect:(CGRect)r {
    if (hilitedIndex == 0) {
        self.hlViewField0.frame = r;
        if (!self.hlViewField0.superview) {
            [self.field addSubview:self.hlViewField0];
        }
    } else {
        self.hlViewField1.frame = r;
        if (!self.hlViewField1.superview) {
            [self.field addSubview:self.hlViewField1];
        }
    }
}

- (void)addHandHL:(MJPawnView *)v {
    if (self.hlViewHand.superview)
        [self.hlViewHand removeFromSuperview];
    [self.view addSubview:self.hlViewHand];
    [self.view bringSubviewToFront:self.hlViewHand];
    self.hlViewHand.frame = v.frame;
}

- (void) removeFieldHL:(int) hilitedIndex {
    if (hilitedIndex == 0) {
        [self.hlViewField0 removeFromSuperview];
        if (self.highlighState == hlFieldHL)
            self.highlighState = hlNone;
        else
            if (self.highlighState == hlHandSelectedFieldHL)
                self.highlighState = hlHandSelected;
    } else {
        [self.hlViewField1 removeFromSuperview];
        if (self.highlighState == hlFieldSelectedFieldHL)
            self.highlighState = hlFieldSelected;
    }
}

- (void) removeHandHL {
    [self.hlViewHand removeFromSuperview];
}

- (MJPawnView *)pawnViewByPawn:(MJPawnInfo *)pawn {
    for (MJPawnView *v in self.pawnViews)
        if ([v.info isEqual:pawn])
            return v;
    return nil;
}

- (MJPawnView *)pawnViewByPawnArray:(NSArray *)pawnsArray { //  Topmost one!
    MJPawnView *res = [self pawnViewByPawn:pawnsArray.lastObject];
    if (res)
        return res;
    return [self pawnViewByPawn:pawnsArray.firstObject];
}

- (MJPawnInfo *)emptyPawnIn:(NSArray *)pawnsArray {
    for (MJPawnInfo *p in pawnsArray)
        if (p.currentPawn < 0)
            return p;
    return nil;
}

- (MJPawnInfo *)selectablePawnIn:(NSArray *)pawnsArray {
    for (MJPawnInfo *p in pawnsArray) {
        if ((p.currentPawn >= 0) && (!p.blocked))
            return p;
    }
    return nil;
}

- (MJPawnView *)pawnViewByHandIndex:(NSNumber *)n Slayer:(BOOL)slayer {
    for (MJPawnView *v in self.pawnViews) {
        if (v.handPawn && [v.handPawn isEqualToNumber:n]) {
            if (slayer) {
                if (v.slayer)
                    return v;
            } else {
                if (v.dragon)
                    return v;
            }
        }
    }
    return nil;
}

- (void) updateTable {
    for (MJPawnView *v in self.pawnViews) {
        if (v.info)
            v.highlighted = v.info.blocked;
    }
}

- (void)rearrangeHand {
    CGSize hs = handScale;
    [UIView animateWithDuration:0.4 animations:^{
        [pawns.slayerPawns enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
            MJPawnView *v = [self pawnViewByHandIndex:n Slayer:YES];
            CGRect targetFrame = CGRectMake(idx * hs.width, CGRectGetMaxY(self.field.frame), hs.width, hs.height);
            if (v == nil) {
                MJPawnView *v = [[MJPawnView alloc] initWithFrame:targetFrame Tile:self.manager.tiles[n.integerValue] HLImage:self.suiteImage1 Delegate:self];
                v.handPawn = n;
                [self.view addSubview:v];
                [self.pawnViews addObject:v];
            } else
                v.frame = targetFrame;
        }];
    } completion:^(BOOL finished) {
        self.drawButton.enabled = pawns.slayerPawns.count < 5;
    }];
}

- (void) rearrangeDragonHand {
    CGSize hs = handScale;
    [UIView animateWithDuration:0.4 animations:^{
        [pawns.dragonPawns enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
            MJPawnView *v = [self pawnViewByHandIndex:n Slayer:NO];
            CGRect targetFrame;
            targetFrame.size = hs;
            targetFrame.origin.x = CGRectGetMaxX(self.field.frame);
            targetFrame.origin.y = CGRectGetMinY(self.field.frame) + (idx * hs.height);
            if (v == nil) {
                MJPawnView *v = [[MJPawnView alloc] initDragonPawnWithFrame:targetFrame Tile:self.manager.tiles[n.integerValue] HLImage:self.suiteImage1];
                v.handPawn = n;
                [self.view addSubview:v];
                [self.pawnViews addObject:v];
            } else
                v.frame = targetFrame;
        }];
    } completion:^(BOOL finished) {
    }];

}

- (void) removeSelected {
    __block GameState upcomingState = self.state;
    self.state = sPlayerTurnWaitingForAnimation;
    MJPawnView *v0;
    MJPawnView *v1;
    if (self.hlFieldPawns0) {
        v0 = [self pawnViewByPawn:[self selectablePawnIn:self.hlFieldPawns0]];
        [self removeFieldHL:0];
        if ((self.highlighState & hlHandSelected) != 0) {
            v1 = [self pawnViewByHandIndex:self.hlHandPawn Slayer:YES];
            [self removeHandHL];
        } else {
            v1 = [self pawnViewByPawn:[self selectablePawnIn:self.hlFieldPawns1]];
            [self removeFieldHL:1];
        }
        if (!v1 || !v0) {
            self.state = upcomingState;
            return;
        }
        [UIView animateWithDuration:0.4 animations:^{
            v0.alpha = 0;
            v1.alpha = 0;
        } completion:^(BOOL finished) {
            v0.info.currentPawn = -1;
            if (v1.info)
                v1.info.currentPawn = -1;
            else { // rearrange hand
                [pawns.slayerPawns removeObject:v1.handPawn];
                [self performSelectorOnMainThread:@selector(rearrangeHand) withObject:nil waitUntilDone:YES];
                upcomingState = sPlayerTurnCouldProceed;
            }
            [v0 removeFromSuperview];
            [v1 removeFromSuperview];
            [self.pawnViews removeObject:v0];
            [self.pawnViews removeObject:v1];
            [self updateTable];
            self.state = upcomingState;
            self.highlighState = hlNone;
        }];
    } else
        self.state = upcomingState;
}

- (void) putSelected {
    __block GameState upcomingState = self.state;
    self.state = sPlayerTurnWaitingForAnimation;
    MJPawnInfo *placeOnField = [self emptyPawnIn:self.hlFieldPawns0];
    if (placeOnField && self.hlHandPawn) {
        MJPawnView *v = [self pawnViewByHandIndex:self.hlHandPawn Slayer:YES];
        v.info = placeOnField;
        v.info.currentPawn = self.hlHandPawn.intValue;
        v.handPawn = nil;
        [pawns.slayerPawns removeObject:self.hlHandPawn];
        CGRect target2 = [self pawnRectBy:placeOnField];
        CGRect target1 = CGRectOffset(target2, self.field.frame.origin.x, self.field.frame.origin.y);
        v.delegate = nil;
        v.handPawn = NO;
        [UIView animateWithDuration:0.4 animations:^{
            v.frame = target1;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
            [self.field addSubview:v];
            v.frame = target2;
            v.delegate = nil;
            [self performSelectorOnMainThread:@selector(rearrangeHand) withObject:nil waitUntilDone:YES];
            upcomingState = sPlayerTurnCouldProceed;
            [self updateTable];
            self.state = upcomingState;
            self.highlighState = hlNone;
        }];
        //self.hlFieldPawn0.currentPawn = self.hlHandPawn.intValue;
        //[self addPawnViewFor:self.hlFieldPawn0];
        //self.hlFieldPawn0 = nil;
    } else
        self.state = upcomingState;
}

- (void) dragonPuts:(MJPawnInfo *)p {
    __block GameState upcomingState = self.state;
    self.state = sPlayerTurnWaitingForAnimation;
    if (self.hlDragonPawn && (p.currentPawn < 0)) {
        p.currentPawn = self.hlDragonPawn.intValue;
        //[self addPawnViewFor:p];
        MJPawnView *v = [self pawnViewByHandIndex:self.hlDragonPawn Slayer:NO];
        if (p.noSuiteWhenBlocked)
            v.highlightedImage = self.suiteImage0;
        else
            v.highlightedImage = self.suiteImage1;
        v.highlighted = p.blocked;
        CGRect target2 = [self pawnRectBy:p];
        CGRect target1 = CGRectOffset(target2, self.field.frame.origin.x, self.field.frame.origin.y);
        v.dragon = NO;
        v.handPawn = nil;
        v.slayer = NO;
        v.info = p;
        [pawns.dragonPawns removeObject:self.hlDragonPawn];
        [UIView animateWithDuration:0.4 animations:^{
            v.frame = target1;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
            [self.field addSubview:v];
            v.frame = target2;
            v.delegate = nil;
            [self.manager dragonDraws:pawns];
            [self performSelectorOnMainThread:@selector(rearrangeDragonHand) withObject:nil waitUntilDone:YES];
            upcomingState = sPlayerTurnShouldPlacePawn;
            [self updateTable];
            self.state = upcomingState;
            self.highlighState = hlNone;
        }];
    } else
        self.state = sPlayerTurnShouldPlacePawn;
}

#pragma mark - FieldDelegate methods

- (void) tryHLiteAtPoint:(CGPoint) p {
    CGRect r;
    switch (self.state) {
        case sGameIsUninitialized:
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
        case sPlayerWon:
        case sPlayerLost:
        case sGameOver:
            break;
        case sPlayerTurnCouldProceed:
        case sPlayerTurnShouldPlacePawn: {
            PawnAvailability a;
            if (self.state == sPlayerTurnShouldPlacePawn)
                a = aToPutOrPeek;
            else
                a = aToPeek;
            switch (self.highlighState) {
                case hlNone:
                case hlHandSelected:
                    self.hlFieldPawns0 = [self pawnsInP:p Rect:&r Available:a];
                    if (self.hlFieldPawns0) {
                        [self addFieldHL:0 Rect:r];
                        self.highlighState |= hlFieldHL;
                    }
                    break;
                case hlHandSelectedFieldHL:
                case hlFieldHL:
                    self.hlFieldPawns0 = [self pawnsInP:p Rect:&r Available:a];
                    if (self.hlFieldPawns0) {
                        self.hlViewField0.frame = r;
                    } else {
                        [self removeFieldHL:0];
                    }
                    break;
                case hlFieldSelected:
                    self.hlFieldPawns1 = [self pawnsInP:p Rect:&r Available:a];
                    if (self.hlFieldPawns1) {
                        [self addFieldHL:1 Rect:r];
                        self.highlighState = hlFieldSelectedFieldHL;
                    }
                    break;
                case hlFieldSelectedFieldHL:
                    self.hlFieldPawns1 = [self pawnsInP:p Rect:&r Available:a];
                    if (self.hlFieldPawns1) {
                        self.hlViewField1.frame = r;
                    } else {
                        [self removeFieldHL:1];
                    }
                    break;
            }
            break;
        }
    }
}

- (void) trySelect:(CGPoint) p {
    switch (self.state) {
        case sGameIsUninitialized:
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
        case sPlayerWon:
        case sPlayerLost:
        case sGameOver:
            break;
        case sPlayerTurnCouldProceed:
        case sPlayerTurnShouldPlacePawn: {
            switch (self.highlighState) {
                case hlNone: // do not care about these states. Something should be hilited before trySelect
                case hlFieldSelected:
                case hlHandSelected:
                    break;
                case hlFieldHL:
                case hlHandSelectedFieldHL:
                    if (self.hlFieldPawns0) {
                        MJPawnInfo *selectable = [self selectablePawnIn:self.hlFieldPawns0];
                        if (selectable) {
                            if (self.highlighState == hlFieldHL)
                                self.highlighState = hlFieldSelected;
                            else {
                                if ([selectable currentEqualsNumber:self.hlHandPawn]) // valid pait
                                    [self removeSelected];
                                else {
                                    [self removeHandHL];
                                    self.highlighState = hlFieldSelected;
                                }
                            }
                        } else {
                            if (self.highlighState == hlHandSelectedFieldHL) {
                                MJPawnInfo *empty = [self emptyPawnIn:self.hlFieldPawns0];
                                if (empty) { // we could put here from hand
                                    [self putSelected];
                                    break;
                                } else {
                                    [self removeFieldHL:0];
                                    self.highlighState = hlHandSelected;
                                }
                            } else
                                self.highlighState = hlNone;
                        }
                    } else
                        NSLog(@"Invalid UI state!");
                    break;
                case hlFieldSelectedFieldHL:
                    if (self.hlFieldPawns1) {
                        MJPawnInfo *selectable0 = [self selectablePawnIn:self.hlFieldPawns0];
                        MJPawnInfo *selectable1 = [self selectablePawnIn:self.hlFieldPawns1];
                        if (selectable0) {
                            if (selectable1 && ![selectable0 isEqual:selectable1]) {
                                if ([selectable0 currentEquals:selectable1]) { // valid pair
                                    [self removeSelected];
                                    self.highlighState = hlNone;
                                } else { // switching hlFieldPawns0 onto hlFieldPawns1
                                    [self addFieldHL:0 Rect:self.hlViewField1.frame];
                                    self.hlFieldPawns0 = self.hlFieldPawns1;
                                    self.hlFieldPawns1 = nil;
                                    [self removeFieldHL:1];
                                }
                            } else {
                                [self removeFieldHL:1];
                            }
                        } else {
                            if (selectable1) {
                                self.hlViewField0.frame = self.hlViewField1.frame;
                                self.hlFieldPawns0 = self.hlFieldPawns1;
                                self.hlFieldPawns1 = nil;
                                [self removeFieldHL:1];
                            } else
                                self.highlighState = hlNone;
                        }
                    } else
                        NSLog(@"Invalid UI state!");
                    break;
            }
            break;
        }
    }
}

- (void) stopHL {
    return;
#warning remove return here...
    switch (self.state) {
        case sGameIsUninitialized:
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
        case sPlayerWon:
        case sPlayerLost:
        case sGameOver:
            break;
        case sPlayerTurnCouldProceed:
        case sPlayerTurnShouldPlacePawn: {
            switch (self.highlighState) {
                case hlNone:
                case hlHandSelected:
                    break;
                case hlFieldHL:
                case hlHandSelectedFieldHL:
                    self.hlFieldPawns0 = nil;
                    [self removeFieldHL:0];
                    break;
                case hlFieldSelected:
                    break;
                case hlFieldSelectedFieldHL:
                    self.hlFieldPawns1 = nil;
                    [self removeFieldHL:1];
                    break;
            }
            break;
        }
    }
}

#pragma Mark - PawnViewMaster delegate methods

- (void) userTapped:(MJPawnView *)v {
    switch (self.state) {
        case sGameIsUninitialized:
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
        case sPlayerWon:
        case sPlayerLost:
        case sGameOver:
            break;
        case sPlayerTurnCouldProceed:
        case sPlayerTurnShouldPlacePawn: {
            switch (self.highlighState) {
                case hlNone:
                case hlHandSelected:
                    [self addHandHL:v];
                    self.hlHandPawn = v.handPawn;
                    self.highlighState = hlHandSelected;
                    break;
                case hlFieldHL:
                    [self addHandHL:v];
                    self.hlHandPawn = v.handPawn;
                    self.highlighState = hlHandSelectedFieldHL;
                    break;
                case hlFieldSelected: {
                    [self addHandHL:v];
                    self.hlHandPawn = v.handPawn;
                    MJPawnInfo *selectable = [self selectablePawnIn:self.hlFieldPawns0];
                    self.highlighState = hlHandSelectedFieldHL;
                    if (selectable && [selectable currentEqualsNumber:self.hlHandPawn]) // valid pair
                        [self removeSelected];
                    else {
                        self.hlFieldPawns0 = nil;
                        [self removeFieldHL:0];
                        self.highlighState = hlHandSelected;
                    }
                    break;
                }
                case hlFieldSelectedFieldHL:
                    break;
                case hlHandSelectedFieldHL:
                    [self addHandHL:v];
                    self.hlHandPawn = v.handPawn;
                    break;
            }
            break;
        }
    }
}

#pragma Mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:^{
        self.pawns = nil;
        self.lastAlert = nil;
    }];
}

#pragma Mark - button events

- (IBAction)drawButtonTouched:(id)sender {
    [self.manager userDraw:pawns];
    [self rearrangeHand];
}

- (IBAction)doneButtonTouched:(id)sender {
    if (self.state == sPlayerTurnCouldProceed) {
        self.state = sDragonTurn;
    }
}

- (IBAction)backPressed:(id)sender {
#warning save state or something
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
