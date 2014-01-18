//
//  MJBaseViewController.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/18/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJBaseViewController.h"
#import "MJAppDelegate.h"

@interface MJBaseViewController ()

@end

@implementation MJBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MJAppDelegate *appDelegate = (MJAppDelegate *)[UIApplication sharedApplication].delegate;
    self.manager = appDelegate.tileManager;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
