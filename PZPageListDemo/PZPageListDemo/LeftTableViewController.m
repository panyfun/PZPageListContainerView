//
//  LeftTableViewController.m
//  PZPageListDemo
//
//  Created by Pany on 2018/3/23.
//  Copyright © 2018年 Pany. All rights reserved.
//

#import "LeftTableViewController.h"

@interface LeftTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation LeftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [NSMutableArray array];
    for (NSInteger idx = 0; idx < 10; idx++) {
        [_dataArr addObject:[NSString stringWithFormat:@"%ld", idx]];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

//- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"view_will_appear");
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    NSLog(@"view_did_appear");
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"view_will_disappear");
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    NSLog(@"view_did_disappear");
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = _dataArr[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_dataArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
