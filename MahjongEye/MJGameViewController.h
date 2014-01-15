//
//  MJGameViewController.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPawnContainer.h"

@interface MJGameViewController : UIViewController

@property (nonatomic, strong, setter = setPawnContainer:) MJPawnContainer *pawns;

@end
