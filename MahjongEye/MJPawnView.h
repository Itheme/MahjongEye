//
//  MJPawnView.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPawnInfo.h"

@interface MJPawnView : UIImageView

@property (nonatomic, strong) MJPawnInfo *info;

- (id)initWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage;

@end
