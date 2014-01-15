//
//  MJGameViewController.h
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPawnContainer.h"
#import "MJFieldView.h"

@interface MJGameViewController : UIViewController <FieldDelegate>

@property (nonatomic, strong, setter = setPawnContainer:) MJPawnContainer *pawns;

@property (weak, nonatomic) IBOutlet MJFieldView *field;

@end
