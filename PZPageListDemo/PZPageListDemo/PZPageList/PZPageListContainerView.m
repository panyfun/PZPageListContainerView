//
//  PZPageListContainerView.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "PZPageListContainerView.h"

#import <objc/runtime.h>

#import "PZPaegListContentCollectionView.h"

typedef struct _PZPageIndex {   // 私有结构,用来简化内部变量
    NSInteger index;
    PZPageListDirection direction;
} PZPageIndex;

#define PZPageIndexEmpty PZMakgePageIndex(NSIntegerMax, NSUIntegerMax)

NS_INLINE PZPageIndex PZMakgePageIndex(NSInteger idx, PZPageListDirection dir) {
    PZPageIndex p;
    p.index = idx;
    p.direction = dir;
    return p;
}

NS_INLINE BOOL PZPageIndexEqualToIndex(PZPageIndex pageIndex1, PZPageIndex pageIndex2) {
    return pageIndex1.index == pageIndex2.index && pageIndex1.direction == pageIndex2.direction;
}

NS_INLINE BOOL PZPageIndexIsEmpty(PZPageIndex pageIndex) {
    return PZPageIndexEqualToIndex(pageIndex, PZPageIndexEmpty);
}


static NSString * const kPZPageListContainerContentCellID = @"kPZPageListContainerContentCellID";
static NSInteger const kPZPageListContainerContentViewTag = 1001;

@interface PZPageListContainerView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PZPageListContentCollectionViewDelegate>

@property (nonatomic, strong) PZPaegListContentCollectionView * horizontalCollectionView;  /**< 用于容纳水平方向展示的vc */
@property (nonatomic, strong) PZPaegListContentCollectionView *verticalCollectionView; /**< 用于容纳垂直方向展示的vc */


@property (nonatomic) NSInteger prepareHorizonalIndex;
@property (nonatomic) NSInteger prepareVerticalIndex;

@property (nonatomic) NSInteger currentHorizontalIndex;
@property (nonatomic) NSInteger currentVerticalIndex;

@property (nonatomic, strong) NSMapTable<NSString *, __kindof UIViewController<PZPageListPageContentProtocol> *> *horizontalVCMap;   /**< 用于以weak方式存放水平方向的vc */
@property (nonatomic, strong) NSMapTable<NSString *, __kindof UIViewController<PZPageListPageContentProtocol> *> *verticalVCMap; /**< 用于以weak方式存放垂直方向的vc */


// 一些记录状态的数据
@property (nonatomic) PZPageIndex lastDisplayPage;
@property (nonatomic) PZPageIndex lastWillDisplayPage;
@property (nonatomic) PZPageIndex lastWillDismissPage;
@property (nonatomic) BOOL scrollWithSkip;  /**< 跨index滑动 */
@property (nonatomic) BOOL enableHorizontalScroll;  /**< 外部是否允许水平滑动 */
@property (nonatomic) BOOL enableVerticalScroll;    /**< 外部是否允许垂直滑动 */

@end

@implementation PZPageListContainerView

#pragma mark - LifeCycle
- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _horizontalScrollableIndex = NSIntegerMax;
        _verticalScrollableIndex = NSIntegerMax;
        _lastWillDisplayPage = PZPageIndexEmpty;
        _autoAdjustPageFitHeader = YES;
        _enableHorizontalScroll = YES;
        _enableVerticalScroll = YES;
        
        _prepareHorizonalIndex = -1;
        _prepareVerticalIndex = -1;
        _currentHorizontalIndex = 0;
        _currentVerticalIndex = 0;
        
        _horizontalVCMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        _verticalVCMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        
        [self initUI];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (_dataSource && self.superview) {
        [self reloadData];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundVC.view.frame = self.bounds;
    
    CGRect updateFrame = CGRectMake(0, _headerView.frame.size.height, self.bounds.size.width, self.bounds.size.height - _headerView.frame.size.height);
    if (_autoAdjustPageFitHeader &&
        (!CGRectEqualToRect(_horizontalCollectionView.frame, updateFrame) ||
        !CGRectEqualToRect(_verticalCollectionView.frame, updateFrame))) {   // frame确定会被更新
        
        _horizontalCollectionView.frame = updateFrame;
        _verticalCollectionView.frame = updateFrame;
        
        [_horizontalCollectionView reloadItemsAtIndexPaths:_horizontalCollectionView.indexPathsForVisibleItems];
        [_verticalCollectionView reloadItemsAtIndexPaths:_verticalCollectionView.indexPathsForVisibleItems];
    } else {
        _horizontalCollectionView.frame = self.bounds;
        _verticalCollectionView.frame = self.bounds;
    }
}

- (void)initUI {
    // 水平collectionView
    UICollectionViewFlowLayout *horizontalLayout = [[UICollectionViewFlowLayout alloc] init];
    horizontalLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    horizontalLayout.estimatedItemSize = [UIScreen mainScreen].bounds.size;
    horizontalLayout.minimumLineSpacing = CGFLOAT_MIN;
    horizontalLayout.minimumInteritemSpacing = CGFLOAT_MIN;
    _horizontalCollectionView = [[PZPaegListContentCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:horizontalLayout];
    if (@available(iOS 11.0, *)) {
        _horizontalCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _horizontalCollectionView.backgroundColor = [UIColor clearColor];
    _horizontalCollectionView.pagingEnabled = YES;
    _horizontalCollectionView.bounces = NO;
    _horizontalCollectionView.showsVerticalScrollIndicator = NO;
    _horizontalCollectionView.showsHorizontalScrollIndicator = NO;
    
    [_horizontalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPZPageListContainerContentCellID];
    
    _horizontalCollectionView.delegate = self;
    _horizontalCollectionView.dataSource = self;
    
    [self addSubview:_horizontalCollectionView];
    [self addGestureRecognizer:_horizontalCollectionView.panGestureRecognizer];
    
    // 垂直collectionView
    UICollectionViewFlowLayout *verticalLayout = [[UICollectionViewFlowLayout alloc] init];
    verticalLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    verticalLayout.estimatedItemSize = [UIScreen mainScreen].bounds.size;
    verticalLayout.minimumLineSpacing = CGFLOAT_MIN;
    verticalLayout.minimumInteritemSpacing = CGFLOAT_MIN;
    _verticalCollectionView = [[PZPaegListContentCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:verticalLayout];
    if (@available(iOS 11.0, *)) {
        _verticalCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _verticalCollectionView.backgroundColor = [UIColor clearColor];
    _verticalCollectionView.pagingEnabled = YES;
    _verticalCollectionView.bounces = NO;
    _verticalCollectionView.showsVerticalScrollIndicator = NO;
    _verticalCollectionView.showsHorizontalScrollIndicator = NO;
    
    [_verticalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPZPageListContainerContentCellID];
    
    _verticalCollectionView.delegate = self;
    _verticalCollectionView.dataSource = self;
    
    [self addSubview:_verticalCollectionView];
    [self addGestureRecognizer:_verticalCollectionView.panGestureRecognizer];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.superview ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = (self.dataSource && [self.dataSource respondsToSelector:@selector(pzPageList:numOfItemsInDirection:)]) ? [self.dataSource pzPageList:self numOfItemsInDirection:(collectionView == _verticalCollectionView ? PZPageListDirection_Vertical : PZPageListDirection_Horizontal)] : 0;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPZPageListContainerContentCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView viewWithTag:kPZPageListContainerContentViewTag] removeFromSuperview];
    
    UIViewController *displayVC;
    PZPageListDirection direction = collectionView == _verticalCollectionView ? PZPageListDirection_Vertical : PZPageListDirection_Horizontal;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pzPageList:itemForIndex:inDirection:)]) {
        displayVC = [self.dataSource pzPageList:self itemForIndex:indexPath.item inDirection:direction];
        if (displayVC) {
            [cell.contentView addSubview:displayVC.view];
            displayVC.view.tag = kPZPageListContainerContentViewTag;
        }
        displayVC.view.frame = cell.contentView.bounds;
    }
    NSMapTable *map = direction == PZPageListDirection_Horizontal ? _horizontalVCMap : _verticalVCMap;
    NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    if (displayVC) {
        [map setObject:displayVC forKey:key];
    } else {
        [map removeObjectForKey:key];
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = self.bounds.size;
    if (_autoAdjustPageFitHeader && _headerView) {
        size.height -= _headerView.bounds.size.height;
    }
    return size;
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    PZPageListDirection direction;
    if (scrollView == _horizontalCollectionView) {
        direction = PZPageListDirection_Horizontal;
        _currentHorizontalIndex = MAX(0, floor(_horizontalCollectionView.contentOffset.x / self.bounds.size.width));
    } else if (scrollView == _verticalCollectionView) {
        direction = PZPageListDirection_Vertical;
        _currentVerticalIndex = MAX(0, floor(_verticalCollectionView.contentOffset.y / self.bounds.size.height));
    } else {
        return;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(pzPageList:didScroll:InDirection:)]) {
        [_delegate pzPageList:self didScroll:scrollView.contentOffset InDirection:direction];
    }
    
    CGPoint lastContentOffset = [objc_getAssociatedObject(scrollView, @"lastOffset") CGPointValue];
    objc_setAssociatedObject(scrollView, @"lastOffset", [NSValue valueWithCGPoint:scrollView.contentOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    if (_scrollWithSkip) {
//        return;
//    }
    
    CGPoint contentOffset = scrollView.contentOffset;
    // 正向滑动：导致contentOffset增加的滑动，这里scrollView的x和y不可能同时增加
    BOOL forwardScroll = contentOffset.x > lastContentOffset.x || contentOffset.y > lastContentOffset.y;
    NSInteger currentIndex = direction == PZPageListDirection_Vertical ? _currentVerticalIndex : _currentHorizontalIndex;
    PZPageIndex willDisplayPage = PZMakgePageIndex(currentIndex + (forwardScroll ? 1 : 0), direction);
    if (!PZPageIndexEqualToIndex(willDisplayPage, _lastWillDisplayPage)) {
        // 误差判断
        CGFloat pageSide = direction == PZPageListDirection_Vertical ? self.bounds.size.height : self.bounds.size.width;
        CGFloat pageOffset = direction == PZPageListDirection_Vertical ? contentOffset.y : contentOffset.x;
        BOOL isValid = fabs(willDisplayPage.index * pageSide - pageOffset) < pageSide - 10;  // 至少划了10像素才开始算
        if (isValid) {
            PZPageIndex willDismissPage = PZPageIndexIsEmpty(_lastWillDisplayPage) ? _lastDisplayPage : _lastWillDisplayPage;
            
            if (!PZPageIndexEqualToIndex(_lastWillDismissPage, willDismissPage) &&
                !PZPageIndexEqualToIndex(_lastWillDismissPage, willDisplayPage)) {
                if (_delegate && [_delegate respondsToSelector:@selector(pzPageList:didEndDisplayIndex:inDirection:)]) {
                    [_delegate pzPageList:self didEndDisplayIndex:_lastWillDismissPage.index inDirection:_lastWillDismissPage.direction];
                }
                [self callbackWithIndex:_lastWillDismissPage.index inDirection:_lastWillDismissPage.direction method:@selector(pz_pageContentDidScrollOut)];
            }
            
            _lastWillDisplayPage = willDisplayPage;
            _lastWillDismissPage = willDismissPage;
            
            if (_delegate && [_delegate respondsToSelector:@selector(pzPageList:willDisplayIndex:inDirection:)]) {
                [_delegate pzPageList:self willDisplayIndex:willDisplayPage.index inDirection:willDisplayPage.direction];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(pzPageList:willEndDisplayIndex:inDirection:)]) {
                [_delegate pzPageList:self willEndDisplayIndex:willDismissPage.index inDirection:willDismissPage.direction];
            }
            UIViewController<PZPageListPageContentProtocol> *willDisplayVC = [self currentVisibleViewControllerAtIndex:willDisplayPage.index inDirection:willDisplayPage.direction];
            if (willDisplayVC && [willDisplayVC respondsToSelector:@selector(pz_pageContentWillScrollIn)]) {
                [willDisplayVC pz_pageContentWillScrollIn];
            }
            
            UIViewController<PZPageListPageContentProtocol> *willDismissVC = [self currentVisibleViewControllerAtIndex:willDismissPage.index inDirection:willDismissPage.direction];
            if (willDismissVC && [willDismissVC respondsToSelector:@selector(pz_pageContentWillScrollOut)]) {
                [willDismissVC pz_pageContentWillScrollOut];
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self _scrollViewDidFinishScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _scrollViewDidFinishScroll:scrollView];
}

#pragma mark - <PZContainerContentCollectionViewDelegate>
- (UIView *)pzPageListCollectionView:(PZPaegListContentCollectionView *)collectionView didHitWithInfo:(NSDictionary *)hitInfo {
    UIView *hitView = [hitInfo valueForKey:kPZPageListContentHitInfoKey_HitView];
    /**
     正常情况下，hitView应当是cell的contentView的subview
     只有当页面存在空白区域的时候，才会点中cell.contentView
     如果点中的是contentView(superview为cell)，返回nil不响应，其它情况均正常响应
     */
    UIView *responseView = [hitView.superview isKindOfClass:[UICollectionViewCell class]] ? nil : hitView;
    return responseView;
}

- (BOOL)pzPageListCollectionViewGestureRecognizer:(UIGestureRecognizer *)recognizer shouldSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherRecognizer {
    return _delegate && [_delegate respondsToSelector:@selector(pzPageList:gestureRecognizer:shouldSimultaneouslyWith:)] && [_delegate pzPageList:self gestureRecognizer:recognizer shouldSimultaneouslyWith:otherRecognizer];
}

#pragma mark - Accessor
- (void)setDataSource:(id<PZPageListContainerViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        // dataSource 发生了变化，则需要reload
        if (_dataSource && self.superview) {
            [self reloadData];
        }
    }
}

- (CGFloat)currentHorizontalOffset {
    return _horizontalCollectionView.contentOffset.x;
}

- (CGFloat)currentVerticalOffset {
    return _verticalCollectionView.contentOffset.y;
}

- (void)setHorizontalScrollableIndex:(NSUInteger)horizontalScrollableIndex {
    if (_horizontalScrollableIndex != horizontalScrollableIndex) {
        _horizontalScrollableIndex = horizontalScrollableIndex;
        [self resetCollectionViewScrollable];
    }
}

- (void)setVerticalScrollableIndex:(NSUInteger)verticalScrollableIndex {
    if (_verticalScrollableIndex != verticalScrollableIndex) {
        _verticalScrollableIndex = verticalScrollableIndex;
        [self resetCollectionViewScrollable];
    }
}

- (void)setBackgroundVC:(__kindof UIViewController<PZPageListPageContentProtocol> *)backgroundVC {
    if (_backgroundVC != backgroundVC) {
        [_backgroundVC.view removeFromSuperview];
        _backgroundVC = backgroundVC;
        _backgroundVC.view.frame = self.bounds;
        [self insertSubview:_backgroundVC.view atIndex:0];
    }
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView != headerView) {
        [_headerView removeFromSuperview];
        _headerView = headerView;
        [self addSubview:_headerView];
        _headerView.center = CGPointMake(self.bounds.size.width/2.0, _headerView.frame.size.height/2.0);
    }
}

#pragma mark - Private
- (void)_scrollViewDidFinishScroll:(__kindof UIScrollView *)scrollView {
    _scrollWithSkip = NO;
    
    _currentHorizontalIndex = MAX(0, floor(_horizontalCollectionView.contentOffset.x / self.bounds.size.width));
    _currentVerticalIndex = MAX(0, floor(_verticalCollectionView.contentOffset.y / self.bounds.size.height));
    
    [self resetCollectionViewScrollable];
    
    PZPageListDirection scrollDirection = scrollView == _verticalCollectionView ? PZPageListDirection_Vertical : PZPageListDirection_Horizontal;
    NSInteger currentIndex = scrollDirection == PZPageListDirection_Horizontal ? _currentHorizontalIndex : _currentVerticalIndex;
    
    PZPageIndex displayPage = PZMakgePageIndex(currentIndex, scrollDirection);
    PZPageIndex dismissPage = PZPageIndexIsEmpty(_lastWillDismissPage) ? _lastDisplayPage : _lastWillDismissPage;
    
    _lastDisplayPage = displayPage;
    
    if (_delegate && [_delegate respondsToSelector:@selector(pzPageList:didEndDisplayIndex:inDirection:)]) {
        [_delegate pzPageList:self didEndDisplayIndex:dismissPage.index inDirection:dismissPage.direction];
    }
    [self callbackWithIndex:dismissPage.index inDirection:dismissPage.direction method:@selector(pz_pageContentDidScrollOut)];

    if (_delegate && [_delegate respondsToSelector:@selector(pzPageList:didDisplayIndex:inDirection:)]) {
        [_delegate pzPageList:self didDisplayIndex:displayPage.index inDirection:displayPage.direction];
    }
    [self callbackWithIndex:displayPage.index inDirection:displayPage.direction method:@selector(pz_pageContentDidScrollIn)];
}

- (void)resetCollectionViewScrollable {
    _horizontalCollectionView.scrollEnabled = _enableHorizontalScroll && (_verticalCollectionView.hidden || _horizontalScrollableIndex == NSIntegerMax || _horizontalScrollableIndex == _currentVerticalIndex);
    _verticalCollectionView.scrollEnabled = _enableVerticalScroll && (_horizontalCollectionView.hidden || _verticalScrollableIndex == NSIntegerMax || _verticalScrollableIndex == _currentHorizontalIndex);
}

- (void)callbackWithIndex:(NSInteger)index inDirection:(PZPageListDirection)direction method:(SEL)selector {
    NSMutableArray<__kindof UIViewController<PZPageListPageContentProtocol> *> *needCallbackArr = [NSMutableArray array];
    if (!_horizontalCollectionView.hidden && !_verticalCollectionView.hidden && index == (direction == PZPageListDirection_Vertical ? _horizontalScrollableIndex : _verticalScrollableIndex)) {
        if (_backgroundVC && [_backgroundVC respondsToSelector:selector]) {
            [needCallbackArr addObject:_backgroundVC];
        }
        UIViewController<PZPageListPageContentProtocol> *horizontalVC = [self viewControllerAtIndex:_verticalScrollableIndex inDirection:PZPageListDirection_Vertical];
        if (horizontalVC && [horizontalVC respondsToSelector:selector]) {
            [needCallbackArr addObject:horizontalVC];
        }
        UIViewController<PZPageListPageContentProtocol> *verticalVC = [self viewControllerAtIndex:_horizontalScrollableIndex inDirection:PZPageListDirection_Horizontal];
        if (verticalVC && [verticalVC respondsToSelector:selector]) {
            [needCallbackArr addObject:verticalVC];
        }
    } else {
        UIViewController<PZPageListPageContentProtocol> *vc = [self viewControllerAtIndex:index inDirection:direction];
        if (vc && [vc respondsToSelector:selector]) {
            [needCallbackArr addObject:vc];
        }
    }
    [needCallbackArr enumerateObjectsUsingBlock:^(__kindof UIViewController<PZPageListPageContentProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj performSelector:selector];
    }];
}

- (__kindof UIViewController<PZPageListPageContentProtocol> *)currentVisibleViewControllerAtIndex:(NSInteger)index inDirection:(PZPageListDirection)direction {
    UIViewController<PZPageListPageContentProtocol> *visibleVC = [self viewControllerAtIndex:index inDirection:direction];
    if (visibleVC == nil && index == (direction == PZPageListDirection_Horizontal ? _verticalScrollableIndex : _horizontalScrollableIndex)) {
        // 当前方向没取到，但是条件允许显示另一个方向的
        visibleVC = [self viewControllerAtIndex:direction == PZPageListDirection_Horizontal ? _currentVerticalIndex : _currentHorizontalIndex inDirection:direction == PZPageListDirection_Horizontal ? PZPageListDirection_Vertical : PZPageListDirection_Horizontal];
        if (visibleVC == nil) {
            visibleVC = _backgroundVC;
        }
    }

    return visibleVC;
}

#pragma mark - Public
- (void)reloadData {
    if (!self.superview) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_dataSource && [_dataSource respondsToSelector:@selector(pzPageList:numOfItemsInDirection:)]) {
            _horizontalCollectionView.hidden = [_dataSource pzPageList:self numOfItemsInDirection:PZPageListDirection_Horizontal] <= 0;
            _verticalCollectionView.hidden = [_dataSource pzPageList:self numOfItemsInDirection:PZPageListDirection_Vertical] <= 0;
        } else {
            _horizontalCollectionView.hidden = NO;
            _verticalCollectionView.hidden = NO;
        }
        [_horizontalCollectionView reloadData];
        [_verticalCollectionView reloadData];
        [_horizontalCollectionView setNeedsDisplay];
        [_verticalCollectionView setNeedsDisplay];
        
        [self resetCollectionViewScrollable];
        
        if (_prepareHorizonalIndex >= 0 && _horizontalCollectionView.superview) {
            [self scrollToIndex:_prepareHorizonalIndex inDirection:PZPageListDirection_Horizontal animated:NO];
            _prepareHorizonalIndex = -1;
        }
        if (_prepareVerticalIndex >= 0 &&  _verticalCollectionView.superview) {
            [self scrollToIndex:_prepareVerticalIndex inDirection:PZPageListDirection_Vertical animated:NO];
            _prepareVerticalIndex = -1;
        }
    });
}

- (void)enableScroll:(BOOL)enable inDirection:(PZPageListDirection)direction {
    BOOL *flag = direction == PZPageListDirection_Vertical ? &_enableVerticalScroll : &_enableHorizontalScroll;
    *flag = enable;
    [self resetCollectionViewScrollable];
}

- (void)scrollToIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        UICollectionView *collectionView = direction == PZPageListDirection_Vertical ? _verticalCollectionView : _horizontalCollectionView;
        if (self.superview && collectionView.superview) {
            if ([collectionView numberOfSections] > 0 && index < [collectionView numberOfItemsInSection:0]) {
                NSInteger currentIndex = direction == PZPageListDirection_Vertical ? _currentVerticalIndex : _currentHorizontalIndex;
                _scrollWithSkip = abs((int)currentIndex - (int)index) > 1.0;
                [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically animated:animated];
                if (!animated) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self _scrollViewDidFinishScroll:collectionView];
                    });
                }
            }
        } else {
            if (direction == PZPageListDirection_Horizontal) {
                _prepareHorizonalIndex = index;
            } else if (direction == PZPageListDirection_Vertical) {
                _prepareVerticalIndex = index;
            }
        }
    });
}

- (__kindof UIViewController<PZPageListPageContentProtocol> *)viewControllerAtIndex:(NSUInteger)index inDirection:(PZPageListDirection)direction {
    NSString *key = [NSString stringWithFormat:@"%ld", (unsigned long)index];
    NSMapTable *map = direction == PZPageListDirection_Vertical ? _verticalVCMap : _horizontalVCMap;
    UIViewController<PZPageListPageContentProtocol> *vc = nil;
    @try {
        vc = [map objectForKey:key];
    } @catch (NSException *exception) {
    } @finally {
    }
    return vc;
}

- (__kindof UIViewController<PZPageListPageContentProtocol> *)currentVisibleViewController {
    if ((_horizontalCollectionView.hidden && _verticalCollectionView.hidden) || (_currentVerticalIndex == _horizontalScrollableIndex && _currentHorizontalIndex == _verticalScrollableIndex)) {
        return _backgroundVC;
    } else if (!_horizontalCollectionView.hidden && (_verticalCollectionView.hidden || _currentVerticalIndex == _horizontalScrollableIndex)) {
        return [self viewControllerAtIndex:_currentHorizontalIndex inDirection:PZPageListDirection_Horizontal];
    } else if (!_verticalCollectionView.hidden && (_horizontalCollectionView.hidden || _currentHorizontalIndex == _verticalScrollableIndex)) {
        return [self viewControllerAtIndex:_currentVerticalIndex inDirection:PZPageListDirection_Vertical];
    } else {
        return nil;
    }
}

@end
