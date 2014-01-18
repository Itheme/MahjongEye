//
//  MJBaseViewController.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/18/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJTileManager.h"

@interface MJBaseViewController : UIViewController

@property (nonatomic, weak) MJTileManager *manager;

@end
