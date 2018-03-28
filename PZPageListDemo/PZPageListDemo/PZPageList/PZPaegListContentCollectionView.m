//
//  PZPageListContentCollectionView.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "PZPaegListContentCollectionView.h"

NSString * const kPZPageListContentHitInfoKey_HitPoint = @"hitPoint";
NSString * const kPZPageListContentHitInfoKey_HitView = @"hitView";
NSString * const kPZPageListContentHitInfoKey_HitEvent = @"hitEvent";

@interface PZPaegListContentCollectionView () <UIGestureRecognizerDelegate>

@end

@implementation PZPaegListContentCollectionView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    self.panGestureRecognizer.enabled = YES;
    // 拿到原本应该响应这个事件的view
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pzPageListCollectionView:didHitWithInfo:)]) {
        NSMutableDictionary *hitInfo = [NSMutableDictionary dictionary];
        [hitInfo setValue:[NSValue valueWithCGPoint:point] forKey:kPZPageListContentHitInfoKey_HitPoint];
        [hitInfo setValue:hitView forKey:kPZPageListContentHitInfoKey_HitView];
        [hitInfo setValue:event forKey:kPZPageListContentHitInfoKey_HitEvent];
        UIView *responseView = [self.delegate performSelector:@selector(pzPageListCollectionView:didHitWithInfo:) withObject:self withObject:hitInfo];
        
        hitView = responseView;
    }
    return hitView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStatePossible &&
               [otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]] ) { //tableview可能存在滑动删除问题
            CGPoint touchPoint = [otherGestureRecognizer locationInView:otherGestureRecognizer.view];
            UITableView *tableView = (UITableView *)otherGestureRecognizer.view;
            __block BOOL touchCellCanEdit = NO;
            [tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (CGRectContainsPoint(obj.frame, touchPoint)) {
                    NSIndexPath *indexPath = [tableView indexPathForCell:obj];
                    if ([tableView.dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
                        touchCellCanEdit = [tableView.dataSource tableView:tableView canEditRowAtIndexPath:indexPath];
                    }
                    // 系统的tableView的滑动删除还有另一种实现方式，也需要根据情况判断一下
                    if (!touchCellCanEdit && [tableView.delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
                        NSArray *actionArr = [tableView.delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
                        touchCellCanEdit = actionArr.count > 0;
                    }
                    *stop = YES;
                }
            }];
            // 当点中cell且cell能删除的时候，禁用当前collectionView的滑动手势
            gestureRecognizer.enabled = !touchCellCanEdit || otherGestureRecognizer.state == UIGestureRecognizerStateEnded || otherGestureRecognizer.state == UIGestureRecognizerStateCancelled;
            // 当前滑动手势被禁用，则允许手势继续传递
            return !gestureRecognizer.enabled;
        }
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(pzPageListCollectionViewGestureRecognizer:shouldSimultaneouslyWithGestureRecognizer:)]) {
        return [self.delegate pzPageListCollectionViewGestureRecognizer:gestureRecognizer shouldSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return self.scrollEnabled && self.userInteractionEnabled && self.panGestureRecognizer.enabled;
}

@end
