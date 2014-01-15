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
    sPlayerTurnShouldPlacePawn = 0,
    sPlayerTurnCouldProceed = 1,
    sDragonTurn = 2,
    //sPlayerTurnFieldHL = 1,
    //sPlayerTurnFieldPawnSelected = 2,
    //sPlayerTurnFieldPawnSelectedHL2 = 3,
    //sPlayerTurnHandPawnSelected = 4,
    sPlayerTurnWaitingForAnimation = 5
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
@property (nonatomic, strong) UIView *hlViewField0;
@property (nonatomic, strong) UIView *hlViewField1;

@property (nonatomic, weak) MJTileManager *manager;

@property (nonatomic, strong) UIImage *suiteImage0;
@property (nonatomic, strong) UIImage *suiteImage1;
@property (nonatomic, setter = setState:) GameState state;
@property (nonatomic, setter = setHighlightState:) HighlightedState highlighState;

@property (nonatomic, strong) NSNumber *hlHandPawn;
@property (nonatomic, strong) NSArray *hlFieldPawns0; // MJPawnInfo
@property (nonatomic, strong) NSArray *hlFieldPawns1; // MJPawnInfo

@property (nonatomic, strong) NSNumber *hlDragonPawn;

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
    self.suiteImage0 = [UIImage imageNamed:@"back0"];
    self.suiteImage1 = [UIImage imageNamed:@"back1"];
    self.field.delegate = self;
    MJAppDelegate *appDelegate = (MJAppDelegate *)[UIApplication sharedApplication].delegate;
    self.manager = appDelegate.tileManager;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.hlViewHand) return;
    self.drawButton.enabled = NO;
    self.doneButton.enabled = NO;
    self.manager.fieldSize = self.field.bounds.size;
    self.pawnViews = [[NSMutableArray alloc] init];
    handScale = CGSizeMake(self.manager.fieldSize.width / 6, 60);
    CGSize fs = self.manager.tileSize;
    MJPawnContainer *c = [[MJPawnContainer alloc] init];
    [self.manager fillPawnContainer:c];
    self.pawns = c;
    self.hlViewField0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    self.hlViewField0.hidden = NO;
    self.hlViewField0.alpha = 0.5;
    self.hlViewField0.opaque = YES;
    self.hlViewField0.backgroundColor = [UIColor yellowColor];
    
    self.hlViewField1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    self.hlViewField1.hidden = NO;
    self.hlViewField1.alpha = 0.5;
    self.hlViewField1.backgroundColor = [UIColor yellowColor];
    
    self.hlViewHand = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    self.hlViewHand.hidden = NO;
    self.hlViewHand.alpha = 0.5;
    self.hlViewHand.backgroundColor = [UIColor yellowColor];
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
        topLeft.x -= 4;
        topLeft.y -= 4;
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
    }
}

- (void) setPawnContainer:(MJPawnContainer *)apawns {
    for (MJPawnView *v in self.pawnViews) {
        [v removeFromSuperview];
    }
    [self.pawnViews removeAllObjects];
    pawns = apawns;
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
    self.hlDragonPawn = nil;
    // Now just stupid pawns fetching
    if (pawns.dragonPawns.count > 0) {
        self.hlDragonPawn = pawns.dragonPawns.lastObject;
    }
    [self performSelectorOnMainThread:@selector(dragonPuts:) withObject:target waitUntilDone:YES];
}

- (BOOL) checkGameIsNotOver {
#warning UNDONE
    return YES;
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
            [self.manager fillUserHand:pawns];
            [self rearrangeHand];
            [self checkGameIsNotOver];
        }
    }
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
#warning ADD MULTILEVEL PARAMS!!
#warning ADD MULTILEVEL PARAMS!!!
#warning ADD MULTILEVEL PARAMS!!!!
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

- (MJPawnView *)pawnViewByHandIndex:(NSNumber *)n {
    for (MJPawnView *v in self.pawnViews) {
        if (v.handPawn && [v.handPawn isEqualToNumber:n])
                return v;
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
            MJPawnView *v = [self pawnViewByHandIndex:n];
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

- (void) removeSelected {
    __block GameState upcomingState = self.state;
    self.state = sPlayerTurnWaitingForAnimation;
    MJPawnView *v0;
    MJPawnView *v1;
    if (self.hlFieldPawns0) {
        v0 = [self pawnViewByPawn:[self selectablePawnIn:self.hlFieldPawns0]];
        [self removeFieldHL:0];
        if ((self.highlighState & hlHandSelected) != 0) {
            v1 = [self pawnViewByHandIndex:self.hlHandPawn];
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
        MJPawnView *v = [self pawnViewByHandIndex:self.hlHandPawn];
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
    self.state = sPlayerTurnWaitingForAnimation;
    if (self.hlDragonPawn && (p.currentPawn < 0)) {
        p.currentPawn = self.hlDragonPawn.intValue;
        [self addPawnViewFor:p];
        MJPawnView *v = [self pawnViewByPawn:p];
        [pawns.dragonPawns removeObject:self.hlDragonPawn];
        [self.manager dragonDraws:pawns];
        CGRect target = [self pawnRectBy:p];
        [UIView animateWithDuration:0.4 animations:^{
            v.frame = target;
        } completion:^(BOOL finished) {
            [self updateTable];
            self.state = sPlayerTurnShouldPlacePawn;
            self.highlighState = hlNone;
        }];
        //self.hlFieldPawn0.currentPawn = self.hlHandPawn.intValue;
        //[self addPawnViewFor:self.hlFieldPawn0];
        //self.hlFieldPawn0 = nil;
    } else
        self.state = sPlayerTurnShouldPlacePawn;
}

#pragma mark - FieldDelegate methods

- (void) tryHLiteAtPoint:(CGPoint) p {
    CGRect r;
    switch (self.state) {
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
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
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
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
                            if (selectable1) {
                                if ([selectable0 currentEquals:selectable1] && (![selectable0 isEqual:selectable1])) { // valid pair
                                    [self removeSelected];
                                    self.highlighState = hlNone;
                                } else { // switching hlFieldPawns0 onto hlFieldPawns1
                                    self.hlViewField0.frame = self.hlViewField1.frame;
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
    switch (self.state) {
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
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
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
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

@end
