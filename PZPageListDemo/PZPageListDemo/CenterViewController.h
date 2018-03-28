//
//  CenterViewController.h
//  PZPageListDemo
//
//  Created by Pany on 2018/3/27.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CenterViewControllerDelegate <NSObject>

- (void)centerViewControllerSwitchDidChangeStatus:(BOOL)isOn;

@end

@interface CenterViewController : UIViewController

@property (nonatomic, weak) id<CenterViewControllerDelegate> delegate;

@end
