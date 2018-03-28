//
//  ViewController.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "ViewController.h"

#import "Style1ViewController.h"
#import "Style2ViewController.h"
#import "LeftTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button1 = [UIButton new];
    [button1 setTitle:@"style1_SnapChat>" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button1 sizeToFit];
    [button1 addTarget:self action:@selector(bt1Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    button1.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 200);
    
    UIButton *button2 = [UIButton new];
    [button2 setTitle:@"style2_TouTiao>" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button2 sizeToFit];
    [button2 addTarget:self action:@selector(bt2Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    button2.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 300);
}

- (void)bt1Action {
    Style1ViewController *vc = [Style1ViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)bt2Action {
    Style2ViewController *vc = [Style2ViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
