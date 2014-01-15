//
//  MJFieldView.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FieldDelegate <NSObject>

- (void) tryHLiteAtPoint:(CGPoint) p;
- (void) trySelect:(CGPoint) p;
- (void) stopHL;

@end

@interface MJFieldView : UIView

@property (nonatomic, weak) id<FieldDelegate> delegate;

@end
