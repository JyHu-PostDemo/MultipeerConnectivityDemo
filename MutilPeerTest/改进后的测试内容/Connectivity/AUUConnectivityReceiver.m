//
//  AUUConnectivityReceiver.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/5.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUConnectivityReceiver.h"

@implementation AUUConnectivityReceiver

- (id)initWithServiceType:(NSString *)serviceType
{
    self = [super init];
    
    if (self)
    {
        self.serviceType = serviceType;
        
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    
}

@end
