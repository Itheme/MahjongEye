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
@property (nonatomic) HighlightedState highlighState;

@property (nonatomic, strong) NSNumber *hlHandPawn;
@property (nonatomic, strong) MJPawnInfo *hlFieldPawn0;
@property (nonatomic, strong) MJPawnInfo *hlFieldPawn1;

@end

@implementation MJGameViewController

@synthesize pawns;
@synthesize state;

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
    
    self.hlViewHand = [[UIView alloc] initWithFrame:CGRectMake(0, 0, handScale.width, handScale.height)];
    self.hlViewHand.alpha = 0.5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect) pawnRectBy:(MJPawnInfo *)p {
    CGSize fs = self.manager.tileSize;
    return CGRectMake(p.coordinate.x * fs.width, p.coordinate.y * fs.height, fs.width, fs.height);
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
    §
}

- (void)setState:(GameState)aState {
    state = aState;
    self.doneButton.enabled = aState == sPlayerTurnCouldProceed;
    if (aState == sDragonTurn)
        [self performSelectorInBackground:@selector(doAI) withObject:nil];
}

- (MJPawnInfo *) pawnInP:(CGPoint) p Rect:(CGRect *)r{
    CGSize ts = self.manager.tileSize;
    p.x /= ts.width;
    p.y /= ts.height;
    p.x -= 0.5;
    p.y -= 0.5;
    for (MJPawnInfo *pawn in self.pawns.pawnsOnField) {
        if ([pawn almostSameCoordinate:p]) {
            *r = CGRectMake(pawn.coordinate.x * ts.width, pawn.coordinate.y * ts.height, ts.width, ts.height);
            return pawn;
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
    if (self.hlFieldPawn0) {
        v0 = [self pawnViewByPawn:self.hlFieldPawn0];
        [self removeFieldHL:0];
        if (self.hlFieldPawn1) {
            v1 = [self pawnViewByPawn:self.hlFieldPawn1];
            [self removeFieldHL:1];
        } else {
            v1 = [self pawnViewByHandIndex:self.hlHandPawn];
            [self removeHandHL];
        }
        if (!v1) return;
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
    if (self.hlFieldPawn0 && (self.hlFieldPawn0.currentPawn < 0) && self.hlHandPawn) {
        MJPawnView *v = [self pawnViewByHandIndex:self.hlHandPawn];
        v.info = self.hlFieldPawn0;
        v.info.currentPawn = self.hlHandPawn.intValue;
        v.handPawn = nil;
        [pawns.slayerPawns removeObject:self.hlHandPawn];
        CGRect target2 = [self pawnRectBy:self.hlFieldPawn0];
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
#pragma mark - FieldDelegate methods

- (void) tryHLiteAtPoint:(CGPoint) p {
    CGRect r;
    switch (self.state) {
        case sPlayerTurnWaitingForAnimation:
        case sDragonTurn:
            break;
        case sPlayerTurnCouldProceed:
        case sPlayerTurnShouldPlacePawn: {
            switch (self.highlighState) {
                case hlNone:
                case hlHandSelected:
                    self.hlFieldPawn0 = [self pawnInP:p Rect:&r];
                    if (self.hlFieldPawn0) {
                        [self addFieldHL:0 Rect:r];
                        self.highlighState |= hlFieldHL;
                    }
                    break;
                case hlHandSelectedFieldHL:
                case hlFieldHL:
                    self.hlFieldPawn0 = [self pawnInP:p Rect:&r];
                    if (self.hlFieldPawn0) {
                        self.hlViewField0.frame = r;
                    } else {
                        [self removeFieldHL:0];
                    }
                    break;
                case hlFieldSelected:
                    self.hlFieldPawn1 = [self pawnInP:p Rect:&r];
                    if (self.hlFieldPawn1) {
                        [self addFieldHL:1 Rect:r];
                        self.highlighState = hlFieldSelectedFieldHL;
                    }
                    break;
                case hlFieldSelectedFieldHL:
                    self.hlFieldPawn1 = [self pawnInP:p Rect:&r];
                    if (self.hlFieldPawn1) {
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
                case hlHandSelectedFieldHL:
                case hlFieldHL:
                    if (self.hlFieldPawn0) {
                        if ((self.hlFieldPawn0.currentPawn < 0) || (self.hlFieldPawn0.blocked)) { // empty or blocked field could not be selected
                            if (self.highlighState == hlHandSelectedFieldHL) { //
                                if (self.hlFieldPawn0.currentPawn < 0) {
                                    if (self.state == sPlayerTurnShouldPlacePawn) {
                                        [self putSelected];
                                        break;
                                    }
                                }
                            }
                            [self removeFieldHL:0];
                            self.hlFieldPawn0 = nil;
                        } else {
                            if (self.highlighState == hlFieldHL)
                                self.highlighState = hlFieldSelected;
                            else {
                                if ([self.hlFieldPawn0 currentEqualsNumber:self.hlHandPawn]) // valid pair
                                    [self removeSelected];
                                else {
                                    [self removeHandHL];
                                    self.highlighState = hlFieldSelected;
                                }
                            }
                        }
                    } else
                        NSLog(@"Invalid UI state!");
                    break;
                case hlFieldSelectedFieldHL:
                    if (self.hlFieldPawn1) {
                        if ((self.hlFieldPawn1.currentPawn < 0) || (self.hlFieldPawn1.blocked)) { // empty pawn
                            [self removeFieldHL:1];
                            self.hlFieldPawn1 = nil;
                        } else {
                            if ([self.hlFieldPawn0 currentEquals:self.hlFieldPawn1]) // valid pair
                                [self removeSelected];
                            else { // switching hlFieldPawn0 onto hlFieldPawn1
                                self.hlViewField0.frame = self.hlViewField1.frame;
                                self.hlFieldPawn0 = self.hlFieldPawn1;
                                self.hlFieldPawn1 = nil;
                                [self removeFieldHL:1];
                            }
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
                    self.hlFieldPawn0 = nil;
                    [self removeFieldHL:0];
                    break;
                case hlFieldSelected:
                    break;
                case hlFieldSelectedFieldHL:
                    self.hlFieldPawn1 = nil;
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
                case hlFieldSelected:
                    [self addHandHL:v];
                    self.hlHandPawn = v.handPawn;
                    if ([self.hlFieldPawn0 currentEqualsNumber:self.hlHandPawn]) // valid pair
                        [self removeSelected];
                    else {
                        self.hlFieldPawn0 = nil;
                        [self removeFieldHL:0];
                        self.highlighState = hlHandSelected;
                    }
                    break;
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
    if (self.state == sPlayerTurnCouldProceed)
        self.state = sDragonTurn;
}

@end
