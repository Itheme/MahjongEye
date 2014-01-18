//
//  MJViewController.m
//  MahjongEye
//
//  Created by Danila Parhomenko on 1/15/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "MJViewController.h"
#import "MJGame.h"

@interface MJViewController ()

@property (nonatomic, strong) UIImageView *stupidDragon;
@property (nonatomic, strong) UIImageView *midDragon;
@property (nonatomic, strong) UIImageView *evilDragon;

@end

@implementation MJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect b = self.scrollView.bounds;
    self.scrollView.contentSize = CGSizeMake(b.size.width * 3, b.size.height);
    self.stupidDragon = [[UIImageView alloc] initWithFrame:b];
    self.stupidDragon.image = [UIImage imageNamed:@"stupidDragon.jpg"];
    [self.scrollView addSubview:self.stupidDragon];
    b = CGRectOffset(b, b.size.width, 0);
    self.midDragon = [[UIImageView alloc] initWithFrame:b];
    self.midDragon.image = [UIImage imageNamed:@"midDragon.jpg"];
    [self.scrollView addSubview:self.midDragon];
    b = CGRectOffset(b, b.size.width, 0);
    self.evilDragon = [[UIImageView alloc] initWithFrame:b];
    self.evilDragon.image = [UIImage imageNamed:@"evilDragon.jpg"];
    [self.scrollView addSubview:self.evilDragon];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    switch (self.manager.gameDifficultyPresentedInUI) {
        case aiStupid:
            [self.scrollView bringSubviewToFront:self.stupidDragon];
            break;
        case aiMedium:
            [self.scrollView bringSubviewToFront:self.midDragon];
            break;
        case aiCheater:
            [self.scrollView bringSubviewToFront:self.evilDragon];
            break;
    }
    self.continueButton.hidden = self.manager.lastPawnContainer == nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateGameDifficulty {
    float x = self.scrollView.contentOffset.x/self.scrollView.bounds.size.width;
    if (x < 0.5)
        self.manager.gameDifficultyPresentedInUI = aiStupid;
    else {
        if (x < 1.5)
            self.manager.gameDifficultyPresentedInUI = aiMedium;
        else
            self.manager.gameDifficultyPresentedInUI = aiCheater;
    }
}

- (IBAction)continuePressed:(id)sender {
    [self updateGameDifficulty];
}

- (IBAction)startNewPressed:(id)sender {
    [self updateGameDifficulty];
    self.manager.lastPawnContainer = nil;
}

@end
