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

@interface MJGameViewController () {
    float scale;
    CGPoint offset;
}

@property (nonatomic, strong) NSMutableArray *pawnViews;
@property (nonatomic, weak) MJTileManager *manager;

@property (nonatomic, strong) UIImage *suiteImage0;
@property (nonatomic, strong) UIImage *suiteImage1;

@end

@implementation MJGameViewController

@synthesize pawns;

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
    MJAppDelegate *appDelegate = (MJAppDelegate *)[UIApplication sharedApplication].delegate;
    self.manager = appDelegate.tileManager;
    self.pawnViews = [[NSMutableArray alloc] init];
    scale = 40;
    offset = CGPointMake(5, 50);
    MJPawnContainer *c = [[MJPawnContainer alloc] init];
    [self.manager fillPawnContainer:c];
    self.pawns = c;
	// Do any additional setup after loading the view.
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
    __block CGRect r = CGRectMake(0, 0, scale, scale);
    for (MJPawnInfo *p in pawns.pawnsOnField) {
        if (p.currentPawn >= 0) {
            r.origin.x = p.coordinate.x * scale + offset.x;
            r.origin.y = p.coordinate.y * scale + offset.y;
            MJPawnView *v = [[MJPawnView alloc] initWithFrame:r Tile:self.manager.tiles[p.currentPawn] HLImage:p.noSuiteWhenBlocked?self.suiteImage0:self.suiteImage1];
            v.info = p;
            [self.view addSubview:v];
            if (p.blocked)
                v.highlighted = YES;
            [self.pawnViews addObject:v];
        }
    }
    [pawns.dragonPawns enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
        r.origin.x = idx * r.size.width;
        r.origin.y = 500;
        MJPawnView *v = [[MJPawnView alloc] initWithFrame:r Tile:self.manager.tiles[n.integerValue] HLImage:self.suiteImage1];
        [self.view addSubview:v];
        [self.pawnViews addObject:v];
    }];
}

@end
