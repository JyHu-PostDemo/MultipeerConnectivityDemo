//
//  AUUBaseMultipeer.h
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface AUUBaseMultipeer : NSObject

@property (retain, nonatomic, readonly) MCSession *session;

@property (retain, nonatomic, readonly) MCPeerID *peer;

- (void)sendData:(NSData *)data;

- (void)sendResourceAtURL:(NSURL *)resourceURL withName:(NSString *)resourceName toPeer:(MCPeerID *)peerID withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (void)receiveData:(void (^)(NSData *data, MCPeerID *peer))receiveData;

- (void)receiveingResource:(void (^)(NSString *resourceName, MCPeerID *fromPeer, NSProgress *progress, NSURL *localURL))receiveingResource;

- (void)remoteCertificate:(BOOL (^)(NSArray *certificate, MCPeerID *peerID))remoteCertificate;

/*
 It should be in the same format as a
 Bonjour service type: up to 15 characters long and valid characters
 include ASCII lowercase letters, numbers, and the hyphen. A short name
 that distinguishes itself from unrelated services is recommended;
 for example, a text chat app made by ABC company could use the service
 type "abc-txtchat".

 */
@property (retain, nonatomic) NSString *mcserviceType;

@end


extern NSString *const AUUDefaultServicType;