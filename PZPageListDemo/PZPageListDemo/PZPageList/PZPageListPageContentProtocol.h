//
//  PZPageListPageContentProtocol.h
//  PZPageListDemo
//
//  Created by Pany on 2018/3/26.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PZPageListPageContentProtocol <NSObject>

@optional

/*
 生命周期相关
 - xxxScrollxx系列方法，仅会由滑动产生
 - xxxAppearxx系列方法，仅在PZPageListViewController的系统xxAppearxx回调时回调，如push/pop时
 */
- (void)pz_pageContentWillScrollIn;
- (void)pz_pageContentDidScrollIn;
- (void)pz_pageContentWillScrollOut;
- (void)pz_pageContentDidScrollOut;
// 👇 仅 PZPageListViewController 中可产生此系列回调
- (void)pz_pageContentWillAppear;
- (void)pz_pageContentDidAppear;
- (void)pz_pageContentWillDisappear;
- (void)pz_pageContentDidDisappear;

@end
