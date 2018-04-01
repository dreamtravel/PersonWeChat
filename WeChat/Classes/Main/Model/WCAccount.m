//
//  WCAccount.m
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCAccount.h"

@implementation WCAccount

+ (instancetype)shareAccount {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static WCAccount *account;
    // 为了线程安全
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        account = [super allocWithZone:zone];
        [account readFromSanBox];
    });
    return account;
}

- (void)saveToSanBox {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_account forKey:@"account"];
    [defaults setObject:_password forKey:@"password"];
    [defaults setBool:_login forKey:@"login"];
    [defaults synchronize];
}

- (void)readFromSanBox {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _account = [defaults stringForKey:@"account"];
    _password = [defaults stringForKey:@"password"];
    _login = [defaults boolForKey:@"login"];
}

@end
