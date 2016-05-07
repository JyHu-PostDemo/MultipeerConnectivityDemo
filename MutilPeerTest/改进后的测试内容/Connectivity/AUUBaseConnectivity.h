//
//  AUUBaseConnectivity.h
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/5.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <UIKit/UIKit.h>

#define AUULog(fmt, ...) printf("%s\n", [[NSString stringWithFormat:@" %s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(fmt), ##__VA_ARGS__]] UTF8String]);

@interface AUUBaseConnectivity : NSObject
<
MCSessionDelegate,
MCNearbyServiceBrowserDelegate,
MCBrowserViewControllerDelegate,
MCNearbyServiceAdvertiserDelegate,
MCAdvertiserAssistantDelegate,
NSStreamDelegate
>

- (id)initWithSecurityIdentity:(NSArray *)identity encryptionPreference:(MCEncryptionPreference)encryptionPreference;

@property (retain, nonatomic) MCPeerID *peerID; // 表明一个用户，不管是在扫描他人还是在向外广播都需要一个身份

@property (retain, nonatomic) MCSession *session;   // 表明一个会话

@property (assign, nonatomic) BOOL writeable;

@property (weak, nonatomic) UIViewController *fromViewController;


@property (copy, nonatomic) void (^dataTransferProgress)(MCPeerID *peerID, CGFloat progress);

@property (copy, nonatomic) void (^receiveData)(NSData *data, NSURL *localURL, MCPeerID *peerID);



@property (retain, nonatomic) MCAdvertiserAssistant *advertiserAssistant;

@property (retain, nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdvertiser;

@property (retain, nonatomic) MCBrowserViewController *browserViewController;

@property (retain, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;

- (void)cleanup;

@end

typedef NS_ENUM(NSUInteger, AUUBrowserType) {
    AUUBrowserTypeCommon,
    AUUBrowserTypeNearby
};

@interface AUUBaseConnectivity (AUUConnectivitySearch)

- (id)initWithServiceType:(NSString *)serviceType;

/*
 It should be in the same format as a
 Bonjour service type: up to 15 characters long and valid characters
 include ASCII lowercase letters, numbers, and the hyphen.
 */
@property (retain, nonatomic) NSString *serviceType;

- (void)selectAdvertiserFromViewController:(id)viewController;

- (void)selectAdvertiserWithSystemPage:(BOOL)withSystemPage fromViewController:(id)viewController;

- (void)selectAdvertiserWithType:(AUUBrowserType)browserType fromViewController:(id)viewController;

@end

@interface AUUBaseConnectivity (AUUDataTransferWithData)

- (void)sendData:(NSData *)data;

- (void)sendData:(NSData *)data withMode:(MCSessionSendDataMode)mode;

@end

@interface AUUBaseConnectivity (AUUDataTransferWithStream)

- (void)updateOutputStreamWithData:(NSData *)data;

- (void)updateOutputStreamWithName:(NSString *)name connectedPeerID:(MCPeerID *)peerID Data:(NSData *)data;

@property (retain, nonatomic) NSInputStream *inputStream;

@property (retain, nonatomic) NSOutputStream *outputStream;

@property (retain, nonatomic) NSMutableData *inputData;

@property (retain, nonatomic) NSData *outputData;

@property (assign, nonatomic) NSUInteger streamTransferDataPartLength;

@property void (^dataStreamSendProgress)(MCPeerID *peerID, CGFloat progress);

- (void)cleanInputStream;

- (void)cleanOutputStream;

- (void)cleanStream;

@end

@interface AUUBaseConnectivity (AUUDataTransferWithResource)

- (void)sendResourceAtURL:(NSURL *)resourceURL;

- (void)sendResourceAtURL:(NSURL *)resourceURL WithCompletionHandler:(void (^)(NSError *))completionHandler;

- (void)sendResourceAtURL:(NSURL *)resourceURL withName:(NSString *)resourceName
                   toPeer:(MCPeerID *)peerID withCompletionHandler:(void (^)(NSError *))completionHandler;

@end

extern NSString *const AUUDefaultServiceType;






