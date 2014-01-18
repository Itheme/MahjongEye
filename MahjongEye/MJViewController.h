//
//  MJViewController.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJBaseViewController.h"

@interface MJViewController : MJBaseViewController
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continuePressed:(id)sender;
- (IBAction)startNewPressed:(id)sender;

@end
