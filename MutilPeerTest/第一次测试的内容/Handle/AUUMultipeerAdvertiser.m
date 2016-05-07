//
//  AUUMultipeerAdvertiser.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUMultipeerAdvertiser.h"

@interface AUUMultipeerAdvertiser() <MCAdvertiserAssistantDelegate>

@property (retain, nonatomic) MCAdvertiserAssistant *advertiserAssistant;

@end

@implementation AUUMultipeerAdvertiser

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self set];
    }
    
    return self;
}

- (void)set
{
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:self.mcserviceType discoveryInfo:nil session:self.session];
    self.advertiserAssistant.delegate = self;
    [self.advertiserAssistant start];
}

#pragma mark - MCAdvertiserAssistantDelegate

- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
