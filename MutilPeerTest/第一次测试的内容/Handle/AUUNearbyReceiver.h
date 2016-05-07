//
//  AUUNearbyReceiver.h
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AUUNearbyReceiver : NSObject

- (void)selectBrowserFromVC:(UIViewController *)vc;

- (void)receiveData:(void (^)(UIImage *image))receiver;

@end
