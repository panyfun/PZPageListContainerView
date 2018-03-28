//
//  PZPageListContainerView.h
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PZPageListPageContentProtocol.h"

typedef enum : NSUInteger {
    PZPageListDirection_Horizontal,
    PZPageListDirection_Vertical,
} PZPageListDirection;

@class PZPageListContainerView;

@protocol PZPageListContainerViewDataSource<NSObject>

@required
- (NSInteger)pzPageList:(PZPageListContainerView *)containerView numOfItemsInDirection:(PZPageListDirection)direction;

/**
 @return 需要显示的控制器(请在外部自行保留及添加至子控制器)，支持返回nil用于将该区间留空
 */
- (UIViewController<PZPageListPageContentProtocol> *)pzPageList:(PZPageListContainerView *)containerView itemForIndex:(NSInteger)index inDirection:(PZPageListDirection)direction;

@optional

@end

@protocol PZPageListContainerViewDelegate<NSObject>
@optional
- (void)pzPageList:(PZPageListContainerView *)containerView didScroll:(CGPoint)contentOffset InDirection:(PZPageListDirection)direction;

- (void)pzPageList:(PZPageListContainerView *)containerView willDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction;
- (void)pzPageList:(PZPageListContainerView *)containerView didDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction;
- (void)pzPageList:(PZPageListContainerView *)containerView willEndDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction;
- (void)pzPageList:(PZPageListContainerView *)containerView didEndDisplayIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction;

- (BOOL)pzPageList:(PZPageListContainerView *)containerView gestureRecognizer:(UIGestureRecognizer *)recognizer shouldSimultaneouslyWith:(UIGestureRecognizer *)otherRecognizer;

@end

/* 一般建议作为最底层视图使用
 * 除非有不需要手势的视图，可以放在本视图下层
 */
@interface PZPageListContainerView : UIView

@property (nonatomic, weak) id<PZPageListContainerViewDataSource> dataSource; /**< 建议先设置数据源，避免一些异常 */
@property (nonatomic, weak) id<PZPageListContainerViewDelegate> delegate;

@property (nonatomic, strong) __kindof UIViewController<PZPageListPageContentProtocol> *backgroundVC;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic) BOOL autoAdjustPageFitHeader;  /**< default = YES, 设置header以后，自动调整page的位置至header下方，如果设置NO，请在被显示的controller内调整inset避免遮挡 */

// 如果只是单项列表，设置无效
@property (nonatomic) NSUInteger horizontalScrollableIndex;  /**< default = NSUIntegerMax, 当垂直list处在该index时，水平list可以滑动，NSUIntegerMax表示不限制 */
@property (nonatomic) NSUInteger verticalScrollableIndex;    /**< default = NSUIntegerMax, 当水平list处在该index时，垂直list可以滑动，NSUIntegerMax表示不限制 */

// 描述当前list所处位置
@property (nonatomic, readonly) CGFloat currentHorizontalOffset;
@property (nonatomic, readonly) CGFloat currentVerticalOffset;
@property (nonatomic, readonly) NSInteger currentHorizontalIndex;
@property (nonatomic, readonly) NSInteger currentVerticalIndex;


- (void)reloadData;

- (void)enableScroll:(BOOL)enable inDirection:(PZPageListDirection)direction;

- (void)scrollToIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction animated:(BOOL)animated;

- (__kindof UIViewController<PZPageListPageContentProtocol> *)viewControllerAtIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction;

- (__kindof UIViewController<PZPageListPageContentProtocol> *)currentVisibleViewController;

@end
