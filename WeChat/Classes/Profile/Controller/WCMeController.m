//
//  WCMeController.m
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCMeController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface WCMeController ()

- (IBAction)logoutButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *wechatNumberLabel;

@end

@implementation WCMeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 显示头像和微信号
    // 从数据库中取用户信息
    // 获取登录用户信息，使用电子名片模块
    XMPPvCardTemp *model = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    if (model.photo) {
        self.avatarImageView.image = [UIImage imageWithData:model.photo];
    }
    self.wechatNumberLabel.text = [NSString stringWithFormat:@"微信号 : %@", [WCAccount shareAccount].account];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonClick:(id)sender {
    // 注销
    [[WCXMPPTool sharedWCXMPPTool] xmpplogout];
    [UIStoryboard showInitialVCWithName:@"Login"];
    
    [WCAccount shareAccount].login = NO;
    [[WCAccount shareAccount] saveToSanBox];
}
@end
