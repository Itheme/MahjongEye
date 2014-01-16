//
//  MJFieldView.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPawnContainer.h"

@protocol FieldDelegate <NSObject>

- (void) tryHLiteAtPoint:(CGPoint) p;
- (void) trySelect:(CGPoint) p;
- (void) stopHL;

@end

@interface MJFieldView : UIView

@property (nonatomic, strong) UIImage *dragonImage;
@property (nonatomic, strong, setter = setContainer:) MJPawnContainer *container;
@property (nonatomic, weak) id<FieldDelegate> delegate;

@end
