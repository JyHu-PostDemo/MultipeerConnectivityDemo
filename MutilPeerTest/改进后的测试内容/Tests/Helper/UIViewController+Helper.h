//
//  UIViewController+Helper.h
//  MutilPeerTest
//
//  Created by 胡金友 on 16/5/6.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helper)

- (void)funcChooseWithTitle:(NSString *)title funcs:(NSArray *)funcs
               completion:(void (^)(NSInteger index))completion;

- (void)funcChooseWithTitle:(NSString *)title message:(NSString *)message
           preferredStyle:(UIAlertControllerStyle)style funcs:(NSArray *)funcs
               completion:(void (^)(NSInteger))completion;

- (void)booleanChooiceWithTitle:(NSString *)title message:(NSString *)message chooice:(void (^)(BOOL b))chooice;

- (void)textInputWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(NSString *text))completion;

@end
