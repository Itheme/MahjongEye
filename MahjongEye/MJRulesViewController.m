//
//  MJRulesViewController.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/18/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJRulesViewController.h"

@interface MJRulesViewController ()

@end

@implementation MJRulesViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
