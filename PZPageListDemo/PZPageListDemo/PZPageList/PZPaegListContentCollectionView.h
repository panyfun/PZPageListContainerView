//
//  PZPageListContentCollectionView.h
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PZPageListContentCollectionView;

UIKIT_EXTERN NSString * const kPZPageListContentHitInfoKey_HitPoint;
UIKIT_EXTERN NSString * const kPZPageListContentHitInfoKey_HitView;
UIKIT_EXTERN NSString * const kPZPageListContentHitInfoKey_HitEvent;

@protocol PZPageListContentCollectionViewDelegate<UICollectionViewDelegate>
@optional
- (UIView *)pzPageListCollectionView:(PZPageListContentCollectionView *)collectionView didHitWithInfo:(NSDictionary *)hitInfo;

- (BOOL)pzPageListCollectionViewGestureRecognizer:(UIGestureRecognizer *)recognizer shouldSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherRecognizer;

@end

// 用于承载controller的view
@interface PZPaegListContentCollectionView : UICollectionView

@property (nonatomic, weak) id<PZPageListContentCollectionViewDelegate> delegate;

@end
