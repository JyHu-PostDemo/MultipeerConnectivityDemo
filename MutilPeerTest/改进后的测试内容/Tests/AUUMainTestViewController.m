//
//  AUUMainTestViewController.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/6.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUMainTestViewController.h"
#import "AUUConnectivityTestViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Masonry/Masonry.h>
#import "UIViewController+Helper.h"

@interface AUUMainTestViewController ()

@end

@implementation AUUMainTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:13]};
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setup];
}

- (void)setup
{
    UIButton *receiverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    receiverButton.translatesAutoresizingMaskIntoConstraints = NO;
    [receiverButton setTitle:@"Receiver" forState:UIControlStateNormal];
    [receiverButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [receiverButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:receiverButton];
    
    UIButton *advertiserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    advertiserButton.translatesAutoresizingMaskIntoConstraints = NO;
    [advertiserButton setTitle:@"Advertiser" forState:UIControlStateNormal];
    [advertiserButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [advertiserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:advertiserButton];
    
    for (NSString *vfl in @[@"V:|-10-[receiverButton(advertiserButton)]-10-[advertiserButton]-10-|",
                            @"H:|-10-[advertiserButton]-10-|", @"H:|-10-[receiverButton]-10-|"])
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:NSLayoutFormatDirectionMask
                   metrics:nil views:NSDictionaryOfVariableBindings(receiverButton, advertiserButton)]];
    }
    
    [[receiverButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self funcChooseWithTitle:@"选择查找附近设备的方式" funcs:@[@"使用系统列表页面查找附近设备", @"不使用系统列表页面查找附近的人", @"正常查找"] completion:^(NSInteger index) {
            
            [self.navigationController pushViewController:[[AUUConnectivityTestViewController alloc] initWithReceiverType:index] animated:YES];
        }];
    }];
    
    [[advertiserButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self funcChooseWithTitle:@"广播的方式" funcs:@[@"正常的广播", @"向附近的人广播"] completion:^(NSInteger index) {
            [self.navigationController pushViewController:[[AUUConnectivityTestViewController alloc] initWithAdvertiserType:index] animated:YES];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
