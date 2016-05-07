//
//  AUUNearbyReceiver.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUNearbyReceiver.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface AUUNearbyReceiver() <MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate, NSStreamDelegate>

@property (retain, nonatomic) MCPeerID *peerID;

@property (retain, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;

@property (retain, nonatomic) MCBrowserViewController *browserViewController;

@property (retain, nonatomic) MCSession *session;

@property (retain, nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdvertiser;

@property (retain, nonatomic) NSInputStream *inputStream;

@property (retain, nonatomic) NSMutableData *inputData;

@property (copy, nonatomic) void (^receiver)(UIImage *);

@end

@implementation AUUNearbyReceiver

- (void)receiveData:(void (^)(UIImage *))receiver
{
    if (receiver)
    {
        self.receiver = receiver;
    }
}

- (void)selectBrowserFromVC:(UIViewController *)vc
{
    [vc presentViewController:self.browserViewController animated:YES completion:^{
        [self.nearbyServiceBrowser startBrowsingForPeers];
    }];
}

- (MCPeerID *)peerID
{
    if (!_peerID)
    {
        _peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    }
    
    return _peerID;
}

- (MCSession *)session
{
    if (!_session)
    {
        _session = [[MCSession alloc] initWithPeer:self.peerID];
        _session.delegate = self;
        
    }
    
    return _session;
}

- (MCNearbyServiceBrowser *)nearbyServiceBrowser
{
    if (!_nearbyServiceBrowser)
    {
        _nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"auu-multipeer"];
        _nearbyServiceBrowser.delegate = self;
    }
    
    return _nearbyServiceBrowser;
}

- (MCBrowserViewController *)browserViewController
{
    if (!_browserViewController)
    {
        _browserViewController = [[MCBrowserViewController alloc] initWithBrowser:self.nearbyServiceBrowser session:self.session];
        _browserViewController.delegate = self;
    }
    
    return _browserViewController;
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    switch (state) {
        case MCSessionStateConnected:
        {
            NSLog(@"与 %@ 连接成功了", peerID.displayName);
            
//            [self.session sendData:[@"你好" dataUsingEncoding:NSUTF8StringEncoding] toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
            
            self.inputData = [[NSMutableData alloc] initWithCapacity:1024];
        }
            break;
        
        case MCSessionStateConnecting:
        {
            NSLog(@"正在连接 %@", peerID.displayName);
        }
            break;
            
        case MCSessionStateNotConnected:
        {
            NSLog(@"与 %@ 连接失败", peerID.displayName);
            
            if (self.inputStream.streamStatus == NSStreamStatusReading)
            {
                [self.inputStream close];
                [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            }
        }
            break;
        
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    self.inputStream = stream;
    self.inputStream.delegate = self;
    [self.inputStream open];
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    certificateHandler(YES);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (self.receiver)
    {
        self.receiver([[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:localURL]]);
    }
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self.nearbyServiceBrowser invitePeer:peerID toSession:self.session withContext:nil timeout:10];
}

// optional
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        [self.nearbyServiceBrowser stopBrowsingForPeers];
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        [self.nearbyServiceBrowser stopBrowsingForPeers];
    }];
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    return YES;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"连接到主机完成");
        }
            break;
            
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"有字节可读");
            uint8_t buff[1024];
            NSUInteger length = [self.inputStream read:buff maxLength:sizeof(buff)];
            [self.inputData appendBytes:buff length:length];
            NSLog(@"Stream 收到 ： %@", [NSData dataWithBytes:buff length:length]);
            if (length == 0)
            {
                [self.inputStream close];
                [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                
                if (self.receiver)
                {
                    UIImage *image = [[UIImage alloc] initWithData:self.inputData];
                    self.receiver(image);
                }
                
                NSLog(@"收到数据结束 ： %@", self.inputData);
            }
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            NSLog(@"有字节可以发送");
        }
            break;
            
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"Stream 连接错误");
        }
            break;
            
        case NSStreamEventEndEncountered:
        {
            NSLog(@"Stream 断开连接");
            
            [self.inputStream close];
            [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        }
            break;
            
        default:
            break;
    }
}

@end
