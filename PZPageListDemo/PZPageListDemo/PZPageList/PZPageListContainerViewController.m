//
//  PZPageListContainerViewController.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "PZPageListContainerViewController.h"

#import "PZPaegListContentCollectionView.h"
#import "PZPageListContainerView.h"

@interface PZPageListContainerViewController ()

@property (nonatomic, strong) PZPageListContainerView *pageContainerView;

@end

@implementation PZPageListContainerViewController

#pragma mark - StatusBar
- (BOOL)prefersStatusBarHidden{
    UIViewController *vc = [self.pageContainerView currentVisibleViewController];
    return vc && [vc respondsToSelector:@selector(prefersStatusBarHidden)] && [vc prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    UIViewController *vc = [self.pageContainerView currentVisibleViewController];
    return (vc && [vc respondsToSelector:@selector(preferredStatusBarUpdateAnimation)]) ? [vc preferredStatusBarUpdateAnimation] : UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *vc = [self.pageContainerView currentVisibleViewController];
    return (vc && [vc respondsToSelector:@selector(preferredStatusBarStyle)]) ? [vc preferredStatusBarStyle] : UIStatusBarStyleDefault;
}

#pragma mark - Rotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = [self.pageContainerView currentVisibleViewController];
    return (vc && [vc respondsToSelector:@selector(supportedInterfaceOrientations)]) ? [vc supportedInterfaceOrientations] : UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = [self.pageContainerView currentVisibleViewController];
    return (vc && [vc respondsToSelector:@selector(preferredInterfaceOrientationForPresentation)]) ? [vc preferredInterfaceOrientationForPresentation] : UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    UIViewController *vc = [self.pageContainerView currentVisibleViewController];
    return (vc && [vc respondsToSelector:@selector(shouldAutorotate)]) ? [vc shouldAutorotate] : YES;
}

#pragma mark - LifeCycle
- (void)loadView {
    _pageContainerView = [PZPageListContainerView new];
    _pageContainerView.frame = [UIScreen mainScreen].bounds;
    _pageContainerView.delegate = self;
    _pageContainerView.dataSource = self;
    self.view = _pageContainerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIViewController<PZPageListPageContentProtocol> *visibleVC = [_pageContainerView currentVisibleViewController];
    if (visibleVC && [visibleVC respondsToSelector:@selector(pz_pageContentWillAppear)]) {
        [visibleVC pz_pageContentWillAppear];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIViewController<PZPageListPageContentProtocol> *visibleVC = [_pageContainerView currentVisibleViewController];
    if (visibleVC && [visibleVC respondsToSelector:@selector(pz_pageContentWillDisappear)]) {
        [visibleVC pz_pageContentWillDisappear];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIViewController<PZPageListPageContentProtocol> *visibleVC = [_pageContainerView currentVisibleViewController];
    if (visibleVC && [visibleVC respondsToSelector:@selector(pz_pageContentDidAppear)]) {
        [visibleVC pz_pageContentDidAppear];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    UIViewController<PZPageListPageContentProtocol> *visibleVC = [_pageContainerView currentVisibleViewController];
    if (visibleVC && [visibleVC respondsToSelector:@selector(pz_pageContentDidDisappear)]) {
        [visibleVC pz_pageContentDidDisappear];
    }
}

#pragma mark - <PZPageListContainerViewDataSource>
- (NSInteger)pzPageList:(PZPageListContainerView *)containerView numOfItemsInDirection:(PZPageListDirection)direction {
    return 0;
}

/**
 @return 需要显示的控制器(请在外部自行保留及添加至子控制器)，支持返回nil用于将该区间留空
 */
- (UIViewController<PZPageListPageContentProtocol> *)pzPageList:(PZPageListContainerView *)containerView itemForIndex:(NSInteger)index inDirection:(PZPageListDirection)direction {
    return nil;
}

#pragma mark - <PZPageListContainerViewDelegate>

@end
