//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCRegisterViewController.h"

@interface WCRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)registerClick:(UIButton *)sender;

@end

@implementation WCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleXMPPResult:(XMPPResultType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        if (type == XMPPResultTypeRegisterSuccess) {
            WCLog(@"注册成功");
            //[self changeToMain];
            // 保存登录账户信息
        } else {
            WCLog(@"注册失败");
            [MBProgressHUD showError:@"用户名重复！"];
        }
    });
}

- (IBAction)registerClick:(UIButton *)sender {
    // 1、判断用户名和密码是否为空
    if (self.accountField.text.length == 0 || self.passwordField.text.length == 0) {
        return;
    }
    //注册
    //保存注册的用户名和密码
    [WCAccount shareAccount].username = self.accountField.text;
    [WCAccount shareAccount].upassword = self.passwordField.text;
    [MBProgressHUD showMessage:@"注册中..."];
    //调用注册方法
    __weak typeof(self) vcSelf = self;
    [[WCXMPPTool sharedWCXMPPTool] xmppregister:^(XMPPResultType type) {
        [vcSelf handleXMPPResult:type];
    }];
}

@end
