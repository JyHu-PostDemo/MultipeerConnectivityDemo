//
//  AUUMultipeerReceiver.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUMultipeerReceiver.h"

@interface AUUMultipeerReceiver() <MCBrowserViewControllerDelegate>

@property (retain, nonatomic) MCBrowserViewController *browserController;

@end

@implementation AUUMultipeerReceiver

- (void)selectBrowserFromVC:(UIViewController *)vc
{
    [vc presentViewController:self.browserController animated:YES completion:nil];
}

- (MCBrowserViewController *)browserController
{
    if (!_browserController)
    {
        _browserController = [[MCBrowserViewController alloc] initWithServiceType:self.mcserviceType session:self.session];
        _browserController.delegate = self;
    }
    
    return _browserController;
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

@end
