//
//  MJAppDelegate.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJAppDelegate.h"

@implementation MJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *field = @[@[@"..aabbccddee..",
                         @"ffaabbccddeegg",
                         @"ffhhiijjkkllgg",
                         @"..hhiijjkkll..",
                         @"....mmnnoo....",
                         @"....mmnnoo....",
                         @"..ppqqrrsstt..",
                         @"uuppqqrrssttvv",
                         @"uuwwxxyyzzAAvv",
                         @"..wwxxyyzzAA..",
                         @"....BBCCDD....",
                         @"....BBCCDD....",
                         @"..EEFFGGHHII..",
                         @"KKEEFFGGHHIILL",
                         @"KKMMNNOOPPQQLL",
                         @"..MMNNOOPPQQ.."],
                       @[@"..............",
                         @"..............",
                         @"..............",
                         @"..............",
                         @"......RR......",
                         @"......RR......",
                         @"....SSTTUU....",
                         @"....SSTTUU....",
                         @"....VVWWXX....",
                         @"....VVWWXX....",
                         @"......YY......",
                         @"......YY......",
                         @"..............",
                         @"..............",
                         @"..............",
                         @".............."]
                       ];
    NSArray *eye =   @[@"..............",
                       @"..............",
                       @"..............",
                       @"..............",
                       @"......11......",
                       @"......11......",
                       @"....112211....",
                       @"....112211....",
                       @"....112211....",
                       @"....112211....",
                       @"......11......",
                       @"......11......",
                       @"..............",
                       @"..............",
                       @"..............",
                       @".............."];

    //UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    self.tileManager = [[MJTileManager alloc] initWithTiles:[UIImage imageNamed:@"tradactual.jpg"] Field:field Eye:eye Horizontal:NO];//(o == UIDeviceOrientationLandscapeLeft) || (o == UIDeviceOrientationLandscapeRight)];
    [self.tileManager tryToLoad];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.tileManager saveCurrentState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.tileManager saveCurrentState];
}

@end
