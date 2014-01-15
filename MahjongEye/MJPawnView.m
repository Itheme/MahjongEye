//
//  MJPawnView.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJPawnView.h"

@implementation MJPawnView

- (id)initWithFrame:(CGRect)frame Tile:(UIImage *)image HLImage:(UIImage *)hlImage
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.image = image;
        self.highlightedImage = hlImage;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
