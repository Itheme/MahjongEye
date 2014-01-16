//
//  MJPawnView.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJPawnView.h"

@interface MJPawnView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation MJPawnView

@synthesize delegate;

- (void) setupWithTile:(UIImage *)image HLImage:(UIImage *)hlImage Hand:(BOOL)inHand Delegate:(id<PawnViewMaster>) master
{
    self.userInteractionEnabled = YES;
    self.image = image;
    self.highlightedImage = hlImage;
    if (inHand) {
        if (master) {
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
            self.tapGesture.numberOfTapsRequired = 1;
            self.tapGesture.numberOfTouchesRequired = 1;
            self.slayer = YES;
            self.tapGesture.enabled = YES;
            [self addGestureRecognizer:self.tapGesture];
        } else
            self.dragon = YES;
    }
    self.delegate = master;
}

- (void) userTapped:(id)tapInfo {
    [self.delegate userTapped:self];
}

- (void) setDelegate:(id<PawnViewMaster>)aDelegate {
    delegate = aDelegate;
    if (aDelegate) {
        self.slayer = YES;
        self.tapGesture.enabled = YES;
    } else {
        self.slayer = NO;
        self.tapGesture.enabled = NO;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// field pawn views
- (id)initWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithTile:image HLImage:hlImage Hand:NO Delegate:nil];
    }
    return self;
}

// hand pawn views
- (id)initWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage Delegate:(id<PawnViewMaster>)master {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithTile:image HLImage:hlImage Hand:YES Delegate:master];
    }
    return self;
}

// dragon pawn views
- (id)initDragonPawnWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithTile:image HLImage:hlImage Hand:YES Delegate:nil];
        self.highlighted = YES;
    }
    return self;
}

@end
