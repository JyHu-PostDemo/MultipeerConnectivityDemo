//
//  AUUBaseConnectivity.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/5.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUBaseConnectivity.h"
#import <objc/runtime.h>
#import "UIViewController+Helper.h"
#import <mach/mach_time.h>

@interface AUUBaseConnectivity() 
{
    NSRange ouputDataRange;
}

@property (retain, nonatomic) NSArray *p_identity;

@property (assign, nonatomic) MCEncryptionPreference encryptionPreference;

@property (assign, nonatomic) BOOL initWithSecurity;

@property (assign, nonatomic) AUUBrowserType p_browserType;

@property (retain, nonatomic) MCPeerID *p_inputStreamPeerID;

@property (retain, nonatomic) MCPeerID *p_outputStreamPeerID;

@end

@implementation AUUBaseConnectivity

- (id)initWithSecurityIdentity:(NSArray *)identity
          encryptionPreference:(MCEncryptionPreference)encryptionPreference
{
    self = [super init];
    
    if (self)
    {
        self.p_identity = identity;
        self.encryptionPreference = encryptionPreference;
        self.initWithSecurity = YES;
        self->ouputDataRange = NSMakeRange(0, 0);
        self.streamTransferDataPartLength = 1024;
    }
    
    return self;
}

- (id)init
{
    return [self initWithSecurityIdentity:nil
                     encryptionPreference:MCEncryptionRequired];
}

#pragma mark - 一些必要参数的Getter方法
#pragma mark -

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
        _session = [[MCSession alloc] initWithPeer:self.peerID
                                  securityIdentity:self.p_identity
                              encryptionPreference:self.encryptionPreference];
        
        _session.delegate = self;
    }
    
    return _session;
}

- (MCAdvertiserAssistant *)advertiserAssistant
{
    if (!_advertiserAssistant)
    {
        _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:self.serviceType
                                                                    discoveryInfo:nil session:self.session];
        
        _advertiserAssistant.delegate = self;
    }
    
    return _advertiserAssistant;
}

- (MCNearbyServiceAdvertiser *)nearbyServiceAdvertiser
{
    if (!_nearbyServiceBrowser)
    {
        _nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID
                                                                     discoveryInfo:nil serviceType:self.serviceType];
        
        _nearbyServiceAdvertiser.delegate = self;
    }
    
    return _nearbyServiceAdvertiser;
}

- (MCBrowserViewController *)browserViewController
{
    if (!_browserViewController)
    {
        if (self.p_browserType == AUUBrowserTypeCommon)
        {
            _browserViewController = [[MCBrowserViewController alloc] initWithServiceType:self.serviceType
                                                                                  session:self.session];
        }
        else
        {
            _browserViewController = [[MCBrowserViewController alloc] initWithBrowser:self.nearbyServiceBrowser
                                                                              session:self.session];
        }
        
        _browserViewController.delegate = self;
    }
    
    return _browserViewController;
}

- (MCNearbyServiceBrowser *)nearbyServiceBrowser
{
    if (!_nearbyServiceBrowser)
    {
        _nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID
                                                                 serviceType:self.serviceType];
        
        _nearbyServiceBrowser.delegate = self;
    }
    
    return _nearbyServiceBrowser;
}

#pragma mark - 操作方法
#pragma mark -

- (void)cleanup
{
    [self.advertiserAssistant stop];
    [self.nearbyServiceAdvertiser stopAdvertisingPeer];
    [self.nearbyServiceBrowser stopBrowsingForPeers];
    [self.session disconnect];
    [self cleanStream];
}

#pragma mark - MCSessionDelegate
#pragma mark -

// 会话状态改变
- (void)session:(MCSession *)session  peer:(MCPeerID *)peerID
                            didChangeState:(MCSessionState)state
{
    AUULog(@"");
    
    self.writeable = self.session.connectedPeers.count > 0;
    
    switch (state)
    {
        case MCSessionStateConnected:
        {
            AUULog(@"与 %@ 成功连接", peerID.displayName);
        }
            break;
            
        case MCSessionStateConnecting:
        {
            AUULog(@"与 %@ 正在连接", peerID.displayName);
        }
            break;
            
        case MCSessionStateNotConnected:
        {
            AUULog(@"与 %@ 失去连接", peerID.displayName);
            
            [self cleanStream];
        }
            break;
            
        default:
            break;
    }
}

// 收到数据
- (void)session:(MCSession *)session  didReceiveData:(NSData *)data
                                            fromPeer:(MCPeerID *)peerID
{
    AUULog(@"收到 %@ 发送来的数据", peerID.displayName);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.receiveData)
        {
            self.receiveData(data, nil, peerID);
        }
    });
}

// 收到写入的数据流
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    [self.inputData setLength:0];
    self->ouputDataRange = NSMakeRange(0, 0);
    
    self.p_inputStreamPeerID = peerID;
    
    self.inputStream = stream;
    self.inputStream.delegate = self;
    [self.inputStream open];
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    AUULog(@"收到 %@ 发送的数据流", peerID.displayName);
}

// 发送文件资源开始
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    CGFloat prog = (progress.completedUnitCount / (progress.totalUnitCount * 1.0));
    
    AUULog(@"收到 %@ 名为 %@ 的文件，进度为 %.2f", peerID.displayName, resourceName, prog);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.dataTransferProgress)
        {
            self.dataTransferProgress(peerID, prog);
        }
    });
}

// 发送文件资源结束
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    AUULog(@"成功收到 %@ 名为 %@ 的文件，保存在本地的路径为 %@", peerID.displayName, resourceName, [localURL absoluteString]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.receiveData)
        {
            self.receiveData(nil, localURL, peerID);
        }
    });
}

// 收到验证，通过在block中设置来回复是否同意加入会话
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate
       fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
    
    AUULog(@"收到 %@ 的连接请求", peerID.displayName);
}

#pragma mark - MCNearbyServiceBrowserDelegate

// 查找到附近的设备
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
                withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    AUULog(@"查找附近的设备，发现 %@， 正在请求加入会话", peerID.displayName);
    
    [self.nearbyServiceBrowser invitePeer:peerID toSession:self.session
                              withContext:nil timeout:10];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    AUULog(@"查找附近的设备，丢失了 %@", peerID.displayName);
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    AUULog(@"查找附近的设备，没有启动成功");
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    AUULog(@"取消了设备浏览界面");
    
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        
        if (self.p_browserType == AUUBrowserTypeNearby)
        {
            [self.nearbyServiceBrowser stopBrowsingForPeers];
        }
    }];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    AUULog(@"选取会话设备结束");
    
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        
        if (self.p_browserType == AUUBrowserTypeNearby)
        {
            [self.nearbyServiceBrowser stopBrowsingForPeers];
        }
    }];
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController
      shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    AUULog(@"是否要在发现外设的时候呈现给用户查看，选择了呈现");
    
    return YES;
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
        didReceiveInvitationFromPeer:(MCPeerID *)peerID
        withContext:(NSData *)context
        invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler
{
    invitationHandler(YES, self.session);
    
    AUULog(@"收到了 %@ 的会话邀请", peerID.displayName);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    AUULog(@"发生了错误，没有成功的启动发现周边设备的服务");
}

#pragma mark - MCAdvertiserAssistantDelegate

- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    AUULog(@"会话邀请将要呈现给用户");
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    AUULog(@"会话邀请将要从呈现给用户的界面消失");
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    AUULog(@"数据流的状态变动");
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            AUULog(@"成功连接到主机/从机");
            break;
            
        case NSStreamEventErrorOccurred:
            AUULog(@"数据流连接错误");
            [self cleanStream];
            break;
            
        case NSStreamEventEndEncountered:
            AUULog(@"断开数据流连接");
            [self cleanStream];
            break;
            
        case NSStreamEventHasBytesAvailable:
        {
            AUULog(@"数据流中有可以接收的字节数据");
            uint8_t buff[self.streamTransferDataPartLength];
            NSUInteger length = [self.inputStream read:buff maxLength:sizeof(buff)];
            [self.inputData appendBytes:buff length:length];    // 将接收到的数据缓存到全局变量 self.inputData 中
            
            if (length == 0)
            {
                // 说明发送方的数据发送完成，这边也接收完成了。
                [self cleanInputStream];
                
                if (self.receiveData)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.receiveData(self.inputData, nil, self.p_inputStreamPeerID);
                    });
                }
            }
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            AUULog(@"数据流中有字节集可以发送");
            
            uint8_t ouputBuff[self.streamTransferDataPartLength];
            // 避免最后一次读取的时候越界，需要每次写数据前算出最大可取的字节长度，默认的是1024
            self->ouputDataRange.length = MIN(self.streamTransferDataPartLength,
                                              self.outputData.length - self->ouputDataRange.location);
            
            if (self->ouputDataRange.location > self.outputData.length)
            {
                // 如果越界了，说明出错
                self->ouputDataRange.location = 0;
            }
            
            [self.outputData getBytes:&ouputBuff range:self->ouputDataRange];
            [self.outputStream write:ouputBuff maxLength:self.streamTransferDataPartLength];
            
            CGFloat progress = (self->ouputDataRange.location + self->ouputDataRange.length) / (self.outputData.length * 1.0);
            
            AUULog(@"数据流中发送数据进度 - 数据位置:%@，总长度:%lu，发送进度:%.2f", NSStringFromRange(self->ouputDataRange), self.outputData.length, progress);
            
            if (self->ouputDataRange.location + self->ouputDataRange.length >= self.outputData.length)
            {
                [self cleanOutputStream];
                
                AUULog(@"数据流中发送数据完成");
            }
            
            self->ouputDataRange.location += self->ouputDataRange.length;
        }
            break;
            
        default:
            [self cleanStream];
            AUULog(@"未知的数据流错误");
            break;
    }
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wincomplete-implementation"

@implementation AUUBaseConnectivity (AUUConnectivitySearch)

const void *serviceTypeAssociatedKey = (void *)@"serviceTypeAssociatedKey";

- (NSString *)serviceType
{
    NSString *tempServiceType = objc_getAssociatedObject(self, serviceTypeAssociatedKey);
    
    if (tempServiceType)
    {
        return tempServiceType;
    }
    
    return AUUDefaultServiceType;
}

- (void)setServiceType:(NSString *)serviceType
{
    objc_setAssociatedObject(self, serviceTypeAssociatedKey,
                             serviceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)selectAdvertiserFromViewController:(id)viewController
{
    AUULog(@"");
    
    [self selectAdvertiserWithType:AUUBrowserTypeCommon fromViewController:viewController];
}

- (void)selectAdvertiserWithSystemPage:(BOOL)withSystemPage fromViewController:(id)viewController
{
    AUULog(@"");
    
    [self.nearbyServiceBrowser startBrowsingForPeers];
}

- (void)selectAdvertiserWithType:(AUUBrowserType)browserType fromViewController:(id)viewController
{
    AUULog(@"");
    
    self.p_browserType = browserType;
    
    [viewController presentViewController:self.browserViewController animated:YES completion:^{
        
        if (self.p_browserType == AUUBrowserTypeNearby)
        {
            [self.nearbyServiceBrowser startBrowsingForPeers];
        }
    }];
}

@end

#pragma clang diagnostic pop

@implementation AUUBaseConnectivity (AUUDataTransferWithData)

- (void)sendData:(NSData *)data
{
    AUULog(@"");
    
    [self sendData:data withMode:MCSessionSendDataReliable];
}

- (void)sendData:(NSData *)data withMode:(MCSessionSendDataMode)mode
{
    AUULog(@"");
    
    if (self.session.connectedPeers.count > 0)
    {
        NSError *error;
        
        [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        
        if (error)
        {
#warning - Should alert error
            
            AUULog(@"%@", [error userInfo]);
        }
    }
}

@end

@implementation AUUBaseConnectivity (AUUDataTransferWithStream)

- (void)updateOutputStreamWithData:(NSData *)data
{
    [self updateOutputStreamWithName:@"DefaultStream" connectedPeerID:[self.session.connectedPeers firstObject] Data:data];
}

- (void)updateOutputStreamWithName:(NSString *)name connectedPeerID:(MCPeerID *)peerID Data:(NSData *)data
{
    self.p_outputStreamPeerID = peerID;
    
    self.outputData = data;
    self.outputStream = [self.session startStreamWithName:@"Stream" toPeer:peerID error:nil];
    
    self.outputStream.delegate = self;
    [self.outputStream open];
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)cleanInputStream
{
    if (self.inputStream)
    {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)cleanOutputStream
{
    if (self.outputStream)
    {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)cleanStream
{
    [self cleanInputStream];
    [self cleanOutputStream];
}

const void *inputStreamAssociatedKey = (void *)@"inputStreamAssociatedKey";

- (NSInputStream *)inputStream
{
    return objc_getAssociatedObject(self, inputStreamAssociatedKey);
}

- (void)setInputStream:(NSInputStream *)inputStream
{
    objc_setAssociatedObject(self, inputStreamAssociatedKey,
                             inputStream, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

const void *outputStreamAssociateKey = (void *)@"outputStreamAssociateKey";

- (NSOutputStream *)outputStream
{
    return objc_getAssociatedObject(self, outputStreamAssociateKey);
}

- (void)setOutputStream:(NSOutputStream *)outputStream
{
    objc_setAssociatedObject(self, outputStreamAssociateKey,
                             outputStream, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

const void *inputDataAsociateKey = (void *)@"inputDataAsociateKey";

- (NSMutableData *)inputData
{
    NSMutableData *tempInputData = objc_getAssociatedObject(self, inputDataAsociateKey);
    
    if (tempInputData == nil)
    {
        tempInputData = [[NSMutableData alloc] init];
        
        [self setInputData:tempInputData];
    }
    
    return tempInputData;
}

- (void)setInputData:(NSMutableData *)inputData
{
    objc_setAssociatedObject(self, inputDataAsociateKey, inputData,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

const void *outputDataAssociateKey = (void *)@"outputDataAssociateKey";

- (NSData *)outputData
{
    return objc_getAssociatedObject(self, outputDataAssociateKey);
}

- (void)setOutputData:(NSData *)outputData
{
    objc_setAssociatedObject(self, outputDataAssociateKey, outputData,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

const void *streamTransferDataPartLengthAssociateKey = (void *)@"streamTransferDataPartLengthAssociateKey";

- (NSUInteger)streamTransferDataPartLength
{
    NSNumber *number = objc_getAssociatedObject(self, streamTransferDataPartLengthAssociateKey);
    
    if (number)
    {
        return [number unsignedIntegerValue];
    }
    
    return 1024;
}

- (void)setStreamTransferDataPartLength:(NSUInteger)streamTransferDataPartLength
{
    objc_setAssociatedObject(self, streamTransferDataPartLengthAssociateKey, @(streamTransferDataPartLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

const void *dataStreamSendProgressAssociateKey = (void *)@"dataStreamSendProgressAssociateKey";

- (void (^)(MCPeerID *, CGFloat))dataStreamSendProgress
{
    return objc_getAssociatedObject(self, dataStreamSendProgressAssociateKey);
}

- (void)setDataStreamSendProgress:(void (^)(MCPeerID *, CGFloat))dataStreamSendProgress
{
    objc_setAssociatedObject(self, dataStreamSendProgressAssociateKey, dataStreamSendProgress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation AUUBaseConnectivity (AUUDataTransferWithResource)

- (void)sendResourceAtURL:(NSURL *)resourceURL
{
    AUULog(@"");
    
    [self sendResourceAtURL:resourceURL WithCompletionHandler:nil];
}

- (void)sendResourceAtURL:(NSURL *)resourceURL WithCompletionHandler:(void (^)(NSError *))completionHandler
{
    AUULog(@"");
    
    NSString *resourcePathString = [resourceURL absoluteString];
    
    NSRange range = [resourcePathString rangeOfString:@"/" options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
    {
        resourcePathString = [resourcePathString substringFromIndex:range.location + 1];
    }
    
    [self sendResourceAtURL:resourceURL withName:resourcePathString toPeer:[self.session.connectedPeers firstObject] withCompletionHandler:completionHandler];
}

- (void)sendResourceAtURL:(NSURL *)resourceURL withName:(NSString *)resourceName toPeer:(MCPeerID *)peerID withCompletionHandler:(void (^)(NSError *))completionHandler
{
    AUULog(@"");
    
    [self.session sendResourceAtURL:resourceURL withName:resourceName
                             toPeer:peerID withCompletionHandler:completionHandler];
}

@end

NSString *const AUUDefaultServiceType = @"AUUDefaultServiceType";






