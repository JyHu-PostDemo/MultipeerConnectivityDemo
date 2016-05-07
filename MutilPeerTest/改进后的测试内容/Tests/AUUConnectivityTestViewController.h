//
//  AUUConnectivityTestViewController.h
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/6.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AUUType) {
    AUUTypeAdvertiser,
    AUUTypeReceiver
};

typedef NS_ENUM(NSUInteger, AUUReceiverType){
    AUUReceiverTypeNearbyServiceBrowserWithUI,
    AUUReceiverTypeNearbyServiceBrowserWithoutUI,
    AUUReceiverTypeNormalServiceBrowser,
};

typedef NS_ENUM(NSUInteger, AUUAdvertiserType) {
    AUUAdvertiserTypeAssistant,
    AUUAdvertiserTypeNearby
};

@interface AUUConnectivityTestViewController : UIViewController

- (id)initWithReceiverType:(AUUReceiverType)type;

- (id)initWithAdvertiserType:(AUUAdvertiserType)type;

@end
