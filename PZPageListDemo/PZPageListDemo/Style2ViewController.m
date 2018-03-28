//
//  Style2ViewController.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/27.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "Style2ViewController.h"

#import "LeftTableViewController.h"

@interface Style2ViewController ()

@end

@implementation Style2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    headerView.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.5];
    self.pageContainerView.headerView = headerView;
}

#pragma mark - <PZPageListContainerViewDataSource>
- (NSInteger)pzPageList:(PZPageListContainerView *)containerView numOfItemsInDirection:(PZPageListDirection)direction {
    return direction == PZPageListDirection_Horizontal ? 5 : 0;
}

/**
 @return 需要显示的控制器(请在外部自行保留)，支持返回nil，用于将该区间留空
 */
- (UIViewController *)pzPageList:(PZPageListContainerView *)containerView itemForIndex:(NSInteger)index inDirection:(PZPageListDirection)direction {
    UIViewController *vc;
    if (index == 1) {
        vc = [LeftTableViewController new];
    } else {
        vc = [UIViewController new];
    }
    vc.view.backgroundColor = @[[UIColor orangeColor], [UIColor yellowColor]][index%2];
    [self addChildViewController:vc];
    return vc;
}

@end
