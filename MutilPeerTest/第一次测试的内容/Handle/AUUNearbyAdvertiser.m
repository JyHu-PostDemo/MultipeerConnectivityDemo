//
//  AUUNearbyAdvertiser.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUNearbyAdvertiser.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface AUUNearbyAdvertiser() <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, NSStreamDelegate>
{
    NSRange outputRange;
}

@property (retain, nonatomic) MCPeerID *peerID;

@property (retain, nonatomic) MCSession *session;

@property (retain, nonatomic) MCNearbyServiceAdvertiser *nearbyAdvertiser;

@property (retain, nonatomic) NSOutputStream *outputStream;

@property (retain, nonatomic) NSData *outputData;

@end

@implementation AUUNearbyAdvertiser

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self.nearbyAdvertiser startAdvertisingPeer];
    }
    
    return self;
}

- (MCNearbyServiceAdvertiser *)nearbyAdvertiser
{
    if (!_nearbyAdvertiser)
    {
        _nearbyAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:@"auu-multipeer"];
        _nearbyAdvertiser.delegate = self;
    }
    
    return _nearbyAdvertiser;
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

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    switch (state) {
        case MCSessionStateConnected:
        {
            NSLog(@"与 %@ 连接成功了", peerID.displayName);
            
//            self->outputRange = NSMakeRange(0, 0);
//            self.outputData = UIImagePNGRepresentation([UIImage imageNamed:@"AdvertiserTestImage.jpg"]);
//            
//            NSLog(@"%@", self.outputData);
//            
//            self.outputStream =  [self.session startStreamWithName:@"test" toPeer:[self.session.connectedPeers firstObject] error:nil];
//            self.outputStream.delegate = self;
//            [self.outputStream open];
//            [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//            
//            [self.session sendData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
            
            [session sendResourceAtURL:[[NSBundle mainBundle] URLForResource:@"AdvertiserTestImage" withExtension:@"jpg"] withName:@"AdvertiserTestImage" toPeer:peerID withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
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
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    // 需要在这里弹窗提示用户是否同意连接
    certificateHandler(YES);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
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
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            NSLog(@"有字节可以发送");
            
            uint8_t outputBuf[1024];
            self->outputRange.length = MIN(1024, self.outputData.length - self->outputRange.location);
            
            [self.outputData getBytes:&outputBuf range:self->outputRange];
            [self.outputStream write:outputBuf maxLength:1024];
            NSLog(@"%@ - 数据总量 ： %lu， 发送状态 ： %.2f", NSStringFromRange(self->outputRange), self.outputData.length, (self->outputRange.location + self->outputRange.length) / (self.outputData.length * 1.0));
            if ((self->outputRange.location + self->outputRange.length) >= [self.outputData length])
            {
                [self.outputStream close];
                [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            }
            self->outputRange.location += self->outputRange.length;
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
            
            [self.outputStream close];
            [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        }
            break;
            
        default:
            break;
    }
}

@end
