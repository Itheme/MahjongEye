//
//  MJFieldView.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJFieldView.h"
#import "MJAppDelegate.h"
#import "MJPawnInfo.h"

@implementation MJFieldView {
    CGSize ts;
    BOOL horizontal;
}

@synthesize container;

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

- (void) setContainer:(MJPawnContainer *)aContainer {
    self.dragonImage = [UIImage imageNamed:@"tempDragon.jpg"];
    #warning Replace it with original artwork!
    container = aContainer;
    [self setNeedsDisplay];
}

- (CGRect)tileRect:(MJPawnInfo *)p {
    if (horizontal)
        return CGRectMake(p.coordinate.y * ts.width, p.coordinate.x * ts.height, ts.width, ts.height);
    return CGRectMake(p.coordinate.x * ts.width, p.coordinate.y * ts.height, ts.width, ts.height);
}

- (void)drawRect:(CGRect)rect
{
    if (self.dragonImage == nil) return;
    CGRect b = self.bounds;
    CGSize dragonSize = self.dragonImage.size;
    float ratioB = b.size.width / b.size.height;
    float ratioD = dragonSize.width / dragonSize.height;
    float dragonScale;
    if (ratioB > ratioD) // field is wider
        dragonScale = b.size.width / dragonSize.width;
    else // dragon is wider
        dragonScale = b.size.height / dragonSize.height;
    [self.dragonImage drawInRect:b];
    MJAppDelegate *appDelegate = (MJAppDelegate *)([UIApplication sharedApplication].delegate);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
    CGContextSetLineWidth(context, 0.5);
    //UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    horizontal = NO;//(o == UIDeviceOrientationLandscapeLeft) || (o == UIDeviceOrientationLandscapeRight);
    ts = appDelegate.tileManager.tileSize;
    for (MJPawnInfo *p in container.pawnsOnField) {
        if (p.level == 0)
            CGContextAddRect(context, [self tileRect:p]);
    }
    CGContextStrokePath(context);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0, 1.0);
    for (MJPawnInfo *p in container.pawnsOnField) {
        if (p.eye == eGray)
            CGContextAddRect(context, CGRectInset([self tileRect:p], 5, 5));
    }
    CGContextStrokePath(context);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0, 1.0);
    for (MJPawnInfo *p in container.pawnsOnField) {
        if (p.eye == eBlack)
            CGContextAddRect(context, CGRectInset([self tileRect:p], 5, 5));
    }
    CGContextStrokePath(context);
}

@end
