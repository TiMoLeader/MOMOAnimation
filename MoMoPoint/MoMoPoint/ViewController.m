//
//  ViewController.m
//  MoMoPoint
//
//  Created by fighting on 17/5/18.
//  Copyright © 2017年 李鹏举. All rights reserved.
//

#import "ViewController.h"
#import "TransitionViewController.h"


@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];

}
- (IBAction)btnClick:(id)sender {
    [self presentViewController:[[TransitionViewController alloc]init] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
