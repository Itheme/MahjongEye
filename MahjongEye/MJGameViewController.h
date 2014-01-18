//
//  MJGameViewController.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJBaseViewController.h"
#import "MJPawnContainer.h"
#import "MJFieldView.h"
#import "MJPawnView.h"

@interface MJGameViewController : MJBaseViewController <FieldDelegate, PawnViewMaster>

@property (nonatomic, strong, setter = setPawnContainer:) MJPawnContainer *pawns;

@property (weak, nonatomic) IBOutlet MJFieldView *field;
@property (weak, nonatomic) IBOutlet UIButton *drawButton;
- (IBAction)drawButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)doneButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *restPawnsCountLabel;
- (IBAction)backPressed:(id)sender;

@end
