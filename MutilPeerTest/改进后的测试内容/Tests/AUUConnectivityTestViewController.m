//
//  AUUConnectivityTestViewController.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/6.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUConnectivityTestViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "AUUConnectivityReceiver.h"
#import "AUUConnectivityAdvertiser.h"
#import "UIViewController+Helper.h"

@interface AUUConnectivityTestViewController () <UIImagePickerControllerDelegate>

@property (assign, nonatomic) AUUType type;

@property (assign, nonatomic) AUUReceiverType receiverType;

@property (retain, nonatomic) AUUConnectivityReceiver *connectivityReceiver;

@property (retain, nonatomic) AUUConnectivityAdvertiser *connectivityAdvertiser;

@property (retain, nonatomic) UIImagePickerController *imagePickerController;

@end

static NSString *serviceType = @"auu-service";

@implementation AUUConnectivityTestViewController

- (id)initWithType:(AUUType)type
{
    self = [super init];
    
    if (self)
    {
        self.type = type;
    }
    
    return self;
}

- (id)initWithReceiverType:(AUUReceiverType)type
{
    self = [super init];
    
    if (self)
    {
        self.type = AUUTypeReceiver;
        
        self.receiverType = type;
        
        self.connectivityReceiver = [[AUUConnectivityReceiver alloc] initWithServiceType:serviceType];
        
        self.connectivityReceiver.fromViewController = self;
        
        [self advertiserChoose];
    }
    
    return self;
}

- (id)initWithAdvertiserType:(AUUAdvertiserType)type
{
    self = [super init];
    
    if (self)
    {
        self.type = AUUTypeAdvertiser;
        
        [self setupAdvertiserWithType:type];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setup];
}

- (void)setupAdvertiserWithType:(AUUAdvertiserType)type
{
    self.connectivityAdvertiser = [[AUUConnectivityAdvertiser alloc] initWithServiceType:serviceType];
    
    self.connectivityAdvertiser.fromViewController = self;
    
    if (type == AUUAdvertiserTypeAssistant)
    {
        [self.connectivityAdvertiser.advertiserAssistant start];
    }
    else
    {
        [self.connectivityAdvertiser.nearbyServiceAdvertiser startAdvertisingPeer];
    }
}

- (void)advertiserChoose
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"Choose" forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        if (self.receiverType == AUUReceiverTypeNearbyServiceBrowserWithUI)
        {
            [self.connectivityReceiver selectAdvertiserWithType:AUUBrowserTypeNearby fromViewController:self];
        }
        else if (self.receiverType == AUUReceiverTypeNearbyServiceBrowserWithoutUI)
        {
            [self.connectivityReceiver.nearbyServiceBrowser startBrowsingForPeers];
        }
        else if (self.receiverType == AUUReceiverTypeNormalServiceBrowser)
        {
            [self.connectivityReceiver selectAdvertiserWithType:AUUBrowserTypeCommon fromViewController:self];
        }
    }];
}

- (void)setup
{
    UISegmentedControl *sendTypeControl = [[UISegmentedControl alloc] initWithItems:@[@"Data", @"Stream", @"Resource"]];
    sendTypeControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = sendTypeControl;
    
    UIImageView *sendedImageView = [[UIImageView alloc] init];
    sendedImageView.backgroundColor = [UIColor redColor];
    sendedImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:sendedImageView];
    
    UIImageView *receivedImageView = [[UIImageView alloc] init];
    receivedImageView.backgroundColor = [UIColor greenColor];
    receivedImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:receivedImageView];
    
    UIButton *sendImageButton = [self buttonWithTitle:@"发送图片"];
    UIButton *sendTextButton = [self buttonWithTitle:@"发送文字"];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:textView];
    
    UILabel *progressLabel = [[UILabel alloc] init];
    progressLabel.font = [UIFont systemFontOfSize:12];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:progressLabel];
    
    // 自动布局
    {
        [sendedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(textView.mas_top);
            make.height.equalTo(receivedImageView.mas_height);
        }];
        
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@60);
            make.left.equalTo(sendImageButton.mas_right);
        }];
        
        [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(textView.mas_right);
            make.top.equalTo(textView.mas_top);
            make.bottom.equalTo(textView.mas_bottom);
            make.right.equalTo(self.view.mas_right);
            make.width.equalTo(textView.mas_height);
        }];
        
        [receivedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sendedImageView.mas_left);
            make.right.equalTo(sendedImageView.mas_right);
            make.top.equalTo(textView.mas_bottom);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        
        [sendImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(sendedImageView.mas_bottom);
            make.bottom.equalTo(sendTextButton.mas_top).offset(-2);
            make.width.equalTo(@90);
        }];
        
        [sendTextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sendImageButton.mas_left);
            make.bottom.equalTo(receivedImageView.mas_top);
            make.width.equalTo(sendImageButton.mas_width);
        }];
    }
    
    [[sendImageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        if ([self writeable])
        {
            if (sendTypeControl.selectedSegmentIndex != 2)
            {
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
            }
            else
            {
                NSURL *pathURL = [[NSBundle mainBundle] URLForResource:(arc4random_uniform(2) ? @"AdvertiserTestImage" : @"ReceiverTestImage") withExtension:@"jpg"];
                [self sendData:nil localURL:pathURL withType:2];
                sendedImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pathURL]];
            }
        }
    }];
    
    [[self rac_signalForSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:) fromProtocol:@protocol(UIImagePickerControllerDelegate)] subscribeNext:^(RACTuple *tuple) {
        
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
        NSDictionary *info = [tuple second];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        sendedImageView.image = image;
        
        [self sendData:UIImagePNGRepresentation(image)
              localURL:[info objectForKey:UIImagePickerControllerMediaURL]
              withType:sendTypeControl.selectedSegmentIndex];
    }];
    
    [[self rac_signalForSelector:@selector(imagePickerControllerDidCancel:) fromProtocol:@protocol(UIImagePickerControllerDelegate)] subscribeNext:^(RACTuple *tuple) {
        
        [(UIImagePickerController *)[tuple first] dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [[sendTextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        if ([self writeable])
        {
            [self textInputWithTitle:@"请输入要发送的文字内容" message:nil completion:^(NSString *text) {
                
                [self sendData:[text dataUsingEncoding:NSUTF8StringEncoding] localURL:nil withType:sendTypeControl.selectedSegmentIndex];
            }];
        }
    }];
    
   
    if (self.connectivityReceiver)
    {
        [self.connectivityReceiver setReceiveData:^(NSData *data, NSURL *localURL, MCPeerID *peerID) {
            if (data)
            {
                receivedImageView.image = [UIImage imageWithData:data];
            }
            else
            {
                receivedImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];
            }
        }];
        
        [self.connectivityReceiver setDataTransferProgress:^(MCPeerID *peerID, CGFloat progress) {
            
            NSLog(@"收到数据进度%.2f", progress);
            
            progressLabel.text = [NSString stringWithFormat:@"%.2f", progress];
        }];
        
        [self.connectivityReceiver setDataStreamSendProgress:^(MCPeerID *peerID, CGFloat progress) {
            
            NSLog(@"数据流中发送数据的进度 %.2f", progress);
            
            progressLabel.text = [NSString stringWithFormat:@"%.2f", progress];
        }];
    }
    
    if (self.connectivityAdvertiser)
    {
        [self.connectivityAdvertiser setReceiveData:^(NSData *data, NSURL *localURL, MCPeerID *peerID) {
            
            if (data)
            {
                receivedImageView.image = [UIImage imageWithData:data];
            }
            else
            {
                receivedImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];
            }
        }];
        
        [self.connectivityAdvertiser setDataTransferProgress:^(MCPeerID *peerID, CGFloat progress) {
            
            NSLog(@"收到数据的进度%.2f", progress);
            
            progressLabel.text = [NSString stringWithFormat:@"%.2f", progress];
        }];
        
        [self.connectivityAdvertiser setDataStreamSendProgress:^(MCPeerID *peerID, CGFloat progress) {
            
            NSLog(@"数据流中发送数据的进度 %.2f", progress);
            
            progressLabel.text = [NSString stringWithFormat:@"%.2f", progress];
        }];
    }
}

- (void)sendData:(NSData *)data localURL:(NSURL *)localURL withType:(NSInteger)type
{
    if (self.connectivityAdvertiser)
    {
        if (type == 0)
        {
            [self.connectivityAdvertiser sendData:data];
        }
        else if (type == 1)
        {
            [self.connectivityAdvertiser updateOutputStreamWithData:data];
        }
        else if (type == 2)
        {
            [self.connectivityAdvertiser sendResourceAtURL:localURL];
        }
    }
    
    if (self.connectivityReceiver)
    {
        if (type == 0)
        {
            [self.connectivityReceiver sendData:data];
        }
        else if (type == 1)
        {
            [self.connectivityReceiver updateOutputStreamWithData:data];
        }
        else if (type == 2)
        {
            [self.connectivityReceiver sendResourceAtURL:localURL];
        }
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:button];
    return button;
}

- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController)
    {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    
    return _imagePickerController;
}

- (BOOL)writeable
{
    BOOL writeable = NO;
    
    if (self.type == AUUTypeReceiver)
    {
        writeable = self.connectivityReceiver.writeable;
    }
    else
    {
        writeable = self.connectivityAdvertiser.writeable;
    }
    
    return writeable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
