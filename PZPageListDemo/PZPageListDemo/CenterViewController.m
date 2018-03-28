//
//  CenterViewController.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/27.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "CenterViewController.h"

@interface CenterViewController ()

@property (nonatomic, strong) UIView *touchView;
@property (nonatomic, strong) UISwitch *sw;

@end

@implementation CenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [UILabel new];
    label.textColor = [UIColor blackColor];
    label.text = @"嗯，我是相机画面";
    [label sizeToFit];
    [self.view addSubview:label];
    label.center = self.view.center;
    
    _sw = [UISwitch new];
    [self.view addSubview:_sw];
    _sw.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 200);
    [_sw addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    
    _touchView = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 70, 70)];
    _touchView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_touchView];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_sw.isOn) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        _touchView.center = location;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch end");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch cancel");
}

- (void)switchAction {
    if (_delegate && [_delegate respondsToSelector:@selector(centerViewControllerSwitchDidChangeStatus:)]) {
        [_delegate centerViewControllerSwitchDidChangeStatus:_sw.isOn];
    }
    
    if (_sw.isOn) {
        _touchView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _touchView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

@end
