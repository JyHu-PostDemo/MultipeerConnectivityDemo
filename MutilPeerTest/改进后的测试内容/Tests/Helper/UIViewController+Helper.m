//
//  UIViewController+Helper.m
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/6.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "UIViewController+Helper.h"

@implementation UIViewController (Helper)

- (void)funcChooseWithTitle:(NSString *)title funcs:(NSArray *)funcs
                 completion:(void (^)(NSInteger index))completion
{
    [self funcChooseWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert funcs:funcs completion:completion];
}

- (void)booleanChooiceWithTitle:(NSString *)title message:(NSString *)message chooice:(void (^)(BOOL b))chooice
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        chooice(YES);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        chooice(NO);
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)funcChooseWithTitle:(NSString *)title message:(NSString *)message
             preferredStyle:(UIAlertControllerStyle)style funcs:(NSArray *)funcs
                 completion:(void (^)(NSInteger))completion
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    
    for (NSInteger i = 0; i < funcs.count; i ++)
    {
        NSString *title = funcs[i];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            completion(i);
        }];
        
        [alertController addAction:action];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)textInputWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(NSString *text))completion
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completion(((UITextField *)[alertController.textFields firstObject]).text);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
}

@end
