//
//  MJAppDelegate.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJTileManager.h"

@interface MJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MJTileManager *tileManager;

@end
