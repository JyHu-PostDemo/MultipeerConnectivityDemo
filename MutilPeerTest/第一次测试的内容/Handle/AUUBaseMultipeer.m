//
//  AUUBaseMultipeer.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUBaseMultipeer.h"

@interface AUUBaseMultipeer()<MCSessionDelegate>

@property (retain, nonatomic) MCSession *p_session;

@property (retain, nonatomic) MCPeerID *p_peer;

@property (copy, nonatomic) void (^receiveData)(NSData *, MCPeerID *);

@property (copy, nonatomic) void (^receiveingResource)(NSString *, MCPeerID *, NSProgress *, NSURL *);

@property (copy, nonatomic) BOOL (^remoteCertificate)(NSArray *, MCPeerID *);

@end

@implementation AUUBaseMultipeer

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.p_peer = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    self.p_session = [[MCSession alloc] initWithPeer:self.p_peer];
    self.p_session.delegate = self;
}

- (void)sendData:(NSData *)data
{
    NSError *error;
    
    [self.p_session sendData:data toPeers:[self.p_session connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
    
    if (error)
    {
        NSLog(@"error : %@", [error userInfo]);
    }
}

- (void)sendResourceAtURL:(NSURL *)resourceURL withName:(NSString *)resourceName toPeer:(MCPeerID *)peerID withCompletionHandler:(void (^)(NSError *))completionHandler
{
    [self.p_session sendResourceAtURL:resourceURL withName:resourceName toPeer:self.session.myPeerID withCompletionHandler:completionHandler];
}

- (void)receiveData:(void (^)(NSData *, MCPeerID *))receiveData
{
    if (receiveData)
    {
        self.receiveData = receiveData;
    }
}

- (void)receiveingResource:(void (^)(NSString *, MCPeerID *, NSProgress *, NSURL *))receiveingResource
{
    if (receiveingResource)
    {
        self.receiveingResource = receiveingResource;
    }
}

- (void)remoteCertificate:(BOOL (^)(NSArray *, MCPeerID *))remoteCertificate
{
    if (remoteCertificate)
    {
        self.remoteCertificate = remoteCertificate;
    }
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    switch (state)
    {
        case MCSessionStateConnected:
            NSLog(@"连接成功");
            break;
            
        case MCSessionStateConnecting:
            NSLog(@"正在连接");
            break;
            
        default:
            NSLog(@"连接失败");
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (self.receiveData)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.receiveData(data, peerID);
        });
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (self.receiveingResource)
    {
        self.receiveingResource(resourceName, peerID, progress, nil);
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (self.receiveingResource)
    {
        self.receiveingResource(resourceName, peerID, nil, localURL);
    }
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (self.remoteCertificate)
    {
        certificateHandler(self.remoteCertificate(certificate, peerID));
    }
    else
    {
        certificateHandler(YES);
    }
}

#pragma mark - Getter

- (NSString *)mcserviceType
{
    if (!_mcserviceType)
    {
        return AUUDefaultServicType;
    }
    
    return _mcserviceType;
}

- (MCSession *)session
{
    return _p_session;
}

- (MCPeerID *)peer
{
    return self.p_peer;
}

@end

NSString *const AUUDefaultServicType = @"default-service";
