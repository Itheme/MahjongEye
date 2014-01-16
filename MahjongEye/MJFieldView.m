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

@implementation MJFieldView

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
#warning add eye here
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
    CGSize ts = appDelegate.tileManager.tileSize;
    for (MJPawnInfo *p in container.pawnsOnField) {
        if (p.level == 0)
            CGContextAddRect(context, CGRectMake(p.coordinate.x * ts.width, p.coordinate.y * ts.height, ts.width, ts.height));
    }
    CGContextStrokePath(context);
}

@end
