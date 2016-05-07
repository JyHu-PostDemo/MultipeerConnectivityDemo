//
//  ViewController.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//


#define kTestVC 0

#import "ViewController.h"

#if kTestVC == 1
#import "AUUTestViewController.h"
#else
#import "AUUNearbyTestViewController.h"
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)receiver:(id)sender
{
#if kTestVC == 1
    AUUTestViewController *testVC = [[AUUTestViewController alloc] init];
#else
    AUUNearbyTestViewController *testVC  = [[AUUNearbyTestViewController alloc] init];
#endif
    testVC.type = AUUTypeReceiver;
    [self.navigationController pushViewController:testVC animated:YES];
}

- (IBAction)advertiser:(id)sender
{
#if kTestVC == 1
    AUUTestViewController *testVC = [[AUUTestViewController alloc] init];
#else
    AUUNearbyTestViewController *testVC = [[AUUNearbyTestViewController alloc] init];
#endif
    testVC.type = AUUTypeAdvertiser;
    [self.navigationController pushViewController:testVC animated:YES];
    
#undef kTestVC
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
