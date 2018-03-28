//
//  Style1ViewController.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/27.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "Style1ViewController.h"

#import "CenterViewController.h"
#import "LeftTableViewController.h"

@interface Style1ViewController ()

@property (nonatomic, strong) CenterViewController *centerVC;

// 水平方向
@property (nonatomic, strong) LeftTableViewController *h1;
@property (nonatomic, strong) UIViewController *h3;

// 垂直方向
@property (nonatomic, strong) UIViewController *v1;
@property (nonatomic, strong) UIViewController *v3;


@end

@implementation Style1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageContainerView.backgroundVC = self.centerVC;
    [self addChildViewController:self.centerVC];
    
    self.pageContainerView.horizontalScrollableIndex = 1;
    self.pageContainerView.verticalScrollableIndex = 1;
    
    [self.pageContainerView scrollToIndex:1 inDirection:PZPageListDirection_Horizontal animated:NO];
    [self.pageContainerView scrollToIndex:1 inDirection:PZPageListDirection_Vertical animated:NO];
}

#pragma mark - <PZPageListContainerViewDataSource>
- (NSInteger)pzPageList:(PZPageListContainerView *)containerView numOfItemsInDirection:(PZPageListDirection)direction {
    return 3;
}

/**
 @return 需要显示的控制器(请在外部自行保留)，支持返回nil，用于将该区间留空
 */
- (UIViewController *)pzPageList:(PZPageListContainerView *)containerView itemForIndex:(NSInteger)index inDirection:(PZPageListDirection)direction {
    NSString *vcName = direction == PZPageListDirection_Horizontal ? @"h" : @"v";
    vcName = [vcName stringByAppendingFormat:@"%ld", index+1];
    if ([self respondsToSelector:NSSelectorFromString(vcName)]) {
        // TODO: 建议将controller添加到self.childViewControllers
        return [self performSelector:NSSelectorFromString(vcName)];
    } else {
        return nil;
    }
}

#pragma mark - <PZPageListContainerViewDelegate>
- (void)pzPageList:(PZPageListContainerView *)containerView willDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction {
    NSLog(@"container willDisplay %ld", index);
}
- (void)pzPageList:(PZPageListContainerView *)containerView didDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction {
    NSLog(@"container didDisplay %ld", index);
}
- (void)pzPageList:(PZPageListContainerView *)containerView willEndDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction {
    NSLog(@"container willEndDisplay %ld", index);
}
- (void)pzPageList:(PZPageListContainerView *)containerView didEndDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction {
    NSLog(@"container didEndDisplay %ld", index);
}

#pragma mark - <CenterViewControllerDelegate>
- (void)centerViewControllerSwitchDidChangeStatus:(BOOL)isOn {
    [self.pageContainerView enableScroll:!isOn inDirection:PZPageListDirection_Horizontal];
    [self.pageContainerView enableScroll:!isOn inDirection:PZPageListDirection_Vertical];
}

#pragma mark - Accessor
- (CenterViewController *)centerVC {
    if (_centerVC == nil) {
        _centerVC = [CenterViewController new];
        _centerVC.delegate = self;
    }
    return _centerVC;
}

- (LeftTableViewController *)h1 {
    if (_h1 == nil) {
        _h1 = [LeftTableViewController new];
        _h1.view.backgroundColor = [UIColor orangeColor];
    }
    return _h1;
}

- (UIViewController *)h3 {
    if (_h3 == nil) {
        _h3 = [UIViewController new];
        _h3.view.backgroundColor = [UIColor yellowColor];
        UILabel *label = [UILabel new];
        label.textColor = [UIColor blackColor];
        label.text = @"右";
        [label sizeToFit];
        [_h3.view addSubview:label];
        label.center = _h3.view.center;
    }
    return _h3;
}

- (UIViewController *)v1 {
    if (_v1 == nil) {
        _v1 = [UIViewController new];
        _v1.view.backgroundColor = [UIColor greenColor];
        UILabel *label = [UILabel new];
        label.textColor = [UIColor blackColor];
        label.text = @"上";
        [label sizeToFit];
        [_v1.view addSubview:label];
        label.center = _v1.view.center;
    }
    return _v1;
}

- (UIViewController *)v3 {
    if (_v3 == nil) {
        _v3 = [UIViewController new];
        _v3.view.backgroundColor = [UIColor cyanColor];
        UILabel *label = [UILabel new];
        label.textColor = [UIColor blackColor];
        label.text = @"下";
        [label sizeToFit];
        [_v3.view addSubview:label];
        label.center = _v3.view.center;
    }
    return _v3;
}

@end
