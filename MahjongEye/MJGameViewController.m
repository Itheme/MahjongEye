//
//  MJGameViewController.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJGameViewController.h"
#import "MJAppDelegate.h"
#import "MJPawnView.h"
#import "MJPawnInfo.h"
#import "MJTileManager.h"

typedef enum GameStateEnum {
    sPlayerTurn = 0,
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
} HighlightedState;

@interface MJGameViewController () {
    float handScale;
    CGPoint offset;
    
    
}

@property (nonatomic, strong) NSMutableArray *pawnViews;
@property (nonatomic, strong) UIView *hlViewHand;
@property (nonatomic, strong) UIView *hlViewField0;
@property (nonatomic, strong) UIView *hlViewField1;

@property (nonatomic, weak) MJTileManager *manager;

@property (nonatomic, strong) UIImage *suiteImage0;
@property (nonatomic, strong) UIImage *suiteImage1;
@property (nonatomic) GameState state;
@property (nonatomic) HighlightedState highlighState;

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
    self.manager.fieldSize = self.field.bounds.size;
    self.pawnViews = [[NSMutableArray alloc] init];
    handScale = 50;
    CGSize fs = self.manager.tileSize;
    offset = CGPointMake(5, 50);
    MJPawnContainer *c = [[MJPawnContainer alloc] init];
    [self.manager fillPawnContainer:c];
    self.pawns = c;
    self.hlViewField0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    self.hlViewField0.hidden = NO;
    self.hlViewField0.alpha = 0.5;
    self.hlViewField0.opaque = YES;
    self.hlViewField0.backgroundColor = [UIColor yellowColor];
    [self.field addSubview:self.hlViewField0];
    self.hlViewField1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fs.width, fs.height)];
    self.hlViewField1.hidden = NO;
    self.hlViewField1.alpha = 0.5;
    self.hlViewField1.backgroundColor = [UIColor yellowColor];
    self.hlViewHand = [[UIView alloc] initWithFrame:CGRectMake(0, 0, handScale, handScale)];
    self.hlViewHand.alpha = 0.5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (p.currentPawn >= 0) {
            r.origin.x = p.coordinate.x * fs.width;
            r.origin.y = p.coordinate.y * fs.height;
            MJPawnView *v = [[MJPawnView alloc] initWithFrame:r Tile:self.manager.tiles[p.currentPawn] HLImage:p.noSuiteWhenBlocked?self.suiteImage0:self.suiteImage1];
            v.info = p;
            [self.field addSubview:v];
            if (p.blocked)
                v.highlighted = YES;
            [self.pawnViews addObject:v];
        }
    }
    r.size = CGSizeMake(handScale, handScale);
    [pawns.slayerPawns enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
        r.origin.x = idx * r.size.width;
        r.origin.y = 420;
        MJPawnView *v = [[MJPawnView alloc] initWithFrame:r Tile:self.manager.tiles[n.integerValue] HLImage:self.suiteImage1];
        [self.view addSubview:v];
        [self.pawnViews addObject:v];
    }];
}

- (MJPawnInfo *) pawnInP:(CGPoint) p Rect:(CGRect *)r{
    CGSize ts = self.manager.tileSize;
    p.x /= ts.width;
    p.y /= ts.height;
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
        [self.field addSubview:self.hlViewField1];
    }

}

- (void) removeFieldHL:(int) hilitedIndex {
    if (hilitedIndex == 0) {
        [self.hlViewField0 removeFromSuperview];
        if (self.highlighState == hlFieldHL)
            self.highlighState = hlNone;
    } else {
        [self.hlViewField1 removeFromSuperview];
        if (self.highlighState == hlFieldSelectedFieldHL)
            self.highlighState = hlFieldSelected;
    }
}

- (MJPawnView *)pawnViewByPawn:(MJPawnInfo *)pawn {
    for (MJPawnView *v in self.pawnViews)
        if ([v.info isEqual:pawn])
            return v;
    return nil;
}

- (void) updateTable {
    for (MJPawnView *v in self.pawnViews) {
        if (v.info)
            v.highlighted = v.info.blocked;
    }
}

- (void) removeSelected {
    self.state = sPlayerTurnWaitingForAnimation;
    GameState upcomingState = sPlayerTurn;
    MJPawnView *v0;
    MJPawnView *v1;
    if (self.hlFieldPawn0) {
        v0 = [self pawnViewByPawn:self.hlFieldPawn0];
        [self removeFieldHL:0];
        if (self.hlFieldPawn1) {
            v1 = [self pawnViewByPawn:self.hlFieldPawn1];
            [self removeFieldHL:1];
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        v0.alpha = 0;
        v1.alpha = 0;
    } completion:^(BOOL finished) {
        v0.info.currentPawn = -1;
        v1.info.currentPawn = -1;
        [v0 removeFromSuperview];
        [v1 removeFromSuperview];
        [self.pawnViews removeObject:v0];
        [self.pawnViews removeObject:v1];
        [self updateTable];
        self.state = upcomingState;
    }];

}

#pragma mark - FieldDelegate methods

- (void) tryHLiteAtPoint:(CGPoint) p {
    CGRect r;
    switch (self.state) {
        case sPlayerTurn: {
            switch (self.highlighState) {
                case hlNone:
                    self.hlFieldPawn0 = [self pawnInP:p Rect:&r];
                    if (self.hlFieldPawn0) {
                        [self addFieldHL:0 Rect:r];
                        self.highlighState = hlFieldHL;
                    }
                    break;
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
        case sPlayerTurn: {
            switch (self.highlighState) {
                case hlNone: // do not care about these states. Something should be hilited before trySelect
                case hlFieldSelected:
                    break;
                case hlFieldHL:
                    if (self.hlFieldPawn0) {
                        if ((self.hlFieldPawn0.currentPawn < 0) || (self.hlFieldPawn0.blocked)) { // empty or blocked field could not be selected
                            [self removeFieldHL:0];
                            self.hlFieldPawn0 = nil;
                        } else
                            self.highlighState = hlFieldSelected;
                    } else
                        NSLog(@"Invalid UI state!");
                    break;
                case hlFieldSelectedFieldHL:
                    if (self.hlFieldPawn1) {
                        if ((self.hlFieldPawn1.currentPawn < 0) || (self.hlFieldPawn1.blocked)) { // empty pawn
                            [self removeFieldHL:1];
                            self.hlFieldPawn1 = nil;
                        } else {
                            if (self.hlFieldPawn0.currentPawn == self.hlFieldPawn1.currentPawn) // valid pair
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
        case sPlayerTurn: {
            switch (self.highlighState) {
                case hlNone:
                    break;
                case hlFieldHL:
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

@end
