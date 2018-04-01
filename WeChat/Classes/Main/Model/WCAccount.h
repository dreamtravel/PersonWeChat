//
//  WCAccount.h
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAccount : NSObject

@property (nonatomic, copy) NSString *account;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *username;

@property (nonatomic, copy) NSString *upassword;
/**
 *  判断用户是否登陆
 */
@property (nonatomic, assign, getter=isLogin) BOOL login;

+ (instancetype)shareAccount;

/**
 *  将账号信息保存到沙盒
 */
- (void)saveToSanBox;
/**
 *  从沙河中读取账号信息
 */
//- (void)readFromSanBox;

@end
