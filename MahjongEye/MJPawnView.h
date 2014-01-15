//
//  MJPawnView.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPawnInfo.h"

@class MJPawnView;

@protocol PawnViewMaster

- (void) userTapped:(MJPawnView *)v;

@end

@interface MJPawnView : UIImageView

@property (nonatomic, strong) MJPawnInfo *info;
@property (nonatomic, strong) NSNumber *handPawn;
@property (nonatomic) BOOL dragon; // this pawn is dragon's
@property (nonatomic) BOOL slayer; // this pawn is slayer's
@property (nonatomic, weak) id<PawnViewMaster> delegate;

// field pawn views
- (id)initWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage;

// hand pawn views
- (id)initWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage Delegate:(id<PawnViewMaster>)master;

// dragon pawn views
- (id)initDragonPawnWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage;

@end
