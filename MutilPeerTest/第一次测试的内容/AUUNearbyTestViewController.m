//
//  AUUNearbyTestViewController.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/4.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUNearbyTestViewController.h"
#import "AUUNearbyReceiver.h"
#import "AUUNearbyAdvertiser.h"

@interface AUUNearbyTestViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (retain, nonatomic) AUUNearbyReceiver *receiver;

@property (retain, nonatomic) AUUNearbyAdvertiser *advertiser;

@property (retain, nonatomic) UIImagePickerController *pickerController;

@property (retain, nonatomic) UIImageView *originalImageView;

@property (retain, nonatomic) UIImageView *receiveImageView;

@end

@implementation AUUNearbyTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setup];
}

- (void)setup
{
    self.originalImageView = [[UIImageView alloc] init];
    self.originalImageView.backgroundColor = [UIColor redColor];
    self.originalImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.originalImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.originalImageView];
    
    self.receiveImageView = [[UIImageView alloc] init];
    self.receiveImageView.backgroundColor = [UIColor greenColor];
    self.receiveImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.receiveImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.receiveImageView];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_originalImageView, _receiveImageView);
    
    NSString *VVFL = @"V:|-0-[_originalImageView(_receiveImageView)]-0-[_receiveImageView]-0-|";
    NSString *OHVFL = @"H:|-0-[_originalImageView]-0-|";
    NSString *RHVFL = @"H:|-0-[_receiveImageView]-0-|";
    
    for (NSString *vfl in @[VVFL, OHVFL, RHVFL])
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:NSLayoutFormatDirectionMask metrics:nil views:dict]];
    }
}

- (void)setType:(AUUType)type
{
    _type = type;
    
    UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"SendTestData" style:UIBarButtonItemStyleDone target:self action:@selector(sendTestData)];
    
    if (type == AUUTypeAdvertiser)
    {
        self.advertiser = [[AUUNearbyAdvertiser alloc] init];
//        [self.advertiser receiveData:^(NSData *data, MCPeerID *peer) {
//            self.receiveImageView.image = [UIImage imageWithData:data];
//        }];
        self.navigationItem.rightBarButtonItem = testButton;
    }
    else
    {
        self.receiver = [[AUUNearbyReceiver alloc] init];
//        [self.receiver receiveData:^(NSData *data, MCPeerID *peer) {
//            self.receiveImageView.image = [UIImage imageWithData:data];
//        }];
        [self.receiver receiveData:^(UIImage *image) {
            if (image)
            {
                self.receiveImageView.image = image;
            }
        }];
        UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(selectAdvertiser)];
        
        self.navigationItem.rightBarButtonItems = @[selectButton, testButton];
    }
}

- (void)selectAdvertiser
{
    [self.receiver selectBrowserFromVC:self];
}

- (void)sendTestData
{
//    if (self.type == AUUTypeAdvertiser)
//    {
//        [self.advertiser sendResourceAtURL:[[NSBundle mainBundle] URLForResource:@"AdvertiserTestImage" withExtension:@"png"] withName:@"AdvertiserTestImage" toPeer:nil withCompletionHandler:^(NSError *error) {
//            NSLog(@"%@", error);
//        }];
//    }
//    else
//    {
//        [self.receiver sendResourceAtURL:[[NSBundle mainBundle] URLForResource:@"ReceiverTestImage" withExtension:@"jpg"] withName:@"ReceiverTestImage" toPeer:nil withCompletionHandler:^(NSError *error) {
//            NSLog(@"%@", error);
//        }];
//    }
    
//    self.pickerController = [[UIImagePickerController alloc] init];
//    self.pickerController.delegate = self;
//    [self presentViewController:self.pickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.originalImageView.image = image;
    
//    if (self.type == AUUTypeAdvertiser)
//    {
//        [self.advertiser sendData:UIImagePNGRepresentation(image)];
//    }
//    else
//    {
//        [self.receiver sendData:UIImagePNGRepresentation(image)];
//    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
