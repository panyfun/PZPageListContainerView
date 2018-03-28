//
//  PZPageListContainerViewController.h
//  PZPageListDemo
//
//  Created by Pany on 2018/3/20.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PZPageListContainerView.h"

@interface PZPageListContainerViewController : UIViewController <PZPageListContainerViewDelegate, PZPageListContainerViewDataSource>

@property (nonatomic, strong, readonly) PZPageListContainerView *pageContainerView; /**< 请自行实现delegate和dataSource方法 */

@end
