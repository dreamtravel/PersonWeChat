//
//  WCLoginViewController.m
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCLoginViewController.h"
#import "AppDelegate.h"

@interface WCLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)loginButtonClick:(UIButton *)sender;

@end

@implementation WCLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeToMain {
    // 回到主线程更新UI
//    id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];;
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
    [UIStoryboard showInitialVCWithName:@"Main"];
}

- (void)handleXMPPResult:(XMPPResultType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        if (type == XMPPResultTypeLoginSuccess) {
            WCLog(@"登陆成功");
            [self changeToMain];
            // 保存登录账户信息
            [WCAccount shareAccount].login = YES;
            [[WCAccount shareAccount] saveToSanBox];
        } else {
            WCLog(@"登录失败");
            [MBProgressHUD showError:@"账户或密码错误！"];
        }
    });
}

- (IBAction)loginButtonClick:(UIButton *)sender {
    // 判断用户名和密码是否为空
    if (self.accountField.text.length == 0 || self.passwordField.text.length == 0) {
        return;
    }
    [MBProgressHUD showMessage:@"登录中..."];
    // 2、登录服务器
    //2.1 把用户名和密码保存到Account
    [WCAccount shareAccount].account = self.accountField.text;
    [WCAccount shareAccount].password = self.passwordField.text;
    // 2.2 调用AppDlelegate的xmppLogin方法
    __weak typeof(self) vcSelf = self;
    [[WCXMPPTool sharedWCXMPPTool] xmpplogin:^(XMPPResultType type) {
        [vcSelf handleXMPPResult:type];
    }];
}
@end
