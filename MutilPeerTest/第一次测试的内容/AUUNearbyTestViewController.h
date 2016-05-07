//
//  AUUNearbyTestViewController.h
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AUUType) {
    AUUTypeAdvertiser,
    AUUTypeReceiver
};

@interface AUUNearbyTestViewController : UIViewController

@property (assign, nonatomic) AUUType type;

@end
