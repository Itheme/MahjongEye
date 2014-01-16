//
//  MJFieldView.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJFieldView.h"

@implementation MJFieldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    [self.delegate tryHLiteAtPoint:[t locationInView:self]];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    [self.delegate tryHLiteAtPoint:[t locationInView:self]];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate stopHL];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self];
    [self.delegate tryHLiteAtPoint:p];
    [self.delegate trySelect:p];
}

#warning add eye here
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
