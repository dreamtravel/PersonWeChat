//
//  WCXMPPTool.m
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCXMPPTool.h"

/* 用户登录流程
 1、初始化XMPPStream
 2、连接服务器（传一个jid）
 3、连接成功，之后发送密码
 • 默认登陆成功是不在线的
 4、发送一个“在线消息”给服务器，通知其他用户你上线
 */
@interface WCXMPPTool () <XMPPStreamDelegate>
{
    XMPPStream *_xmppStream; // 与服务器交互的核心类
    XMPPResultBlock _resultBlock; // 结果回调
}

// 初始化XMPPStream
- (void)setupStream;
// 释放资源
- (void)teardownStream;
// 连接到服务器
- (void)connectToServer;
// 发送密码
- (void)sendPasswordToServer;
// 发送一个在线消息给服务器
- (void)sendOnline;
// 发送一个离线消息给服务器
- (void)sendOffline;
// 断开连接
- (void)disconnectToServer;
@end

@implementation WCXMPPTool
singleton_implementation(WCXMPPTool)

#pragma mark - 私有方法
- (void)setupStream {
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc] init];
    
    // 添加XMPP电子名片模块
    _vCardStoryage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStoryage];
    // 激活电子名片
    [_vCard activate:_xmppStream];
    // 电子名片模块还会配合“头像模块”一起使用
    // 添加头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    // 添加花名册模块
    _rosterStoryage = [XMPPRosterCoreDataStorage sharedInstance];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStoryage];
    [_roster activate:_xmppStream];
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)teardownStream {
    // 移除代理
    [_xmppStream removeDelegate:self];
    // 取消模块
    [_vCard deactivate];
    [_avatar deactivate];
    [_roster deactivate];
    // 断开连接
    [_xmppStream disconnect];
    // 清空资源
    _xmppStream = nil;
    
    _vCard = nil;
    _avatar = nil;
    _vCardStoryage = nil;
    
    _roster = nil;
    _rosterStoryage = nil;
}

- (void)connectToServer {
    // 初始化XMPPStream
    if (_xmppStream == nil) {
        [self setupStream];
    }
    //判断用户连接类型
    NSString *account = nil;
    if (self.isRegisterOperation) {
        account = [WCAccount shareAccount].username;
    } else {
        account = [WCAccount shareAccount].account;
    }
    // 1、设置链接用户jid
    // resource：用于用户客户端设备链接的类型
    XMPPJID *myjid = [XMPPJID jidWithUser:account domain:WCDomain resource:WCDeviceModel];
    _xmppStream.myJID = myjid;
    // 2、设置主机地址
    _xmppStream.hostName = WCHostName;
    // 3、设置主机端口号（默认5222，可以不用设置）
    _xmppStream.hostPort = WCHostPort;
    // 4、发起链接
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        WCLog(@"%@", error);
    } else {
        //WCLog(@"发起链接成功");
    }
}

- (void)sendPasswordToServer {
    NSError *error = nil;
    //判断用户连接类型
    NSString *password = nil;
    if (self.isRegisterOperation) {
        password = [WCAccount shareAccount].upassword;
        [_xmppStream registerWithPassword:password error:&error];
    } else {
        password = [WCAccount shareAccount].password;
        [_xmppStream authenticateWithPassword:password error:&error];
    }
    if (error) {
        WCLog(@"%@", error);
    }
}

- (void)sendOnline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [_xmppStream sendElement:presence];
}

- (void)sendOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

- (void)disconnectToServer {
    [_xmppStream disconnect];
}

#pragma mark - 公共方法
//用户登录
- (void)xmpplogin:(XMPPResultBlock)result {
    // 1、保存block
    _resultBlock = result;
    // 2、断开连接
    [_xmppStream disconnect];
    // 3、设置连接类型
    _registerOperation = NO;
    // 3、连接服务器
    [self connectToServer];
}
// 用户注销
- (void)xmpplogout {
    // 1、发送离线消息给服务器
    [self sendOffline];
    // 2、断开连接
    [self disconnectToServer];
}
//用户注册
- (void)xmppregister:(XMPPResultBlock)result {
    // 1、保存block
    _resultBlock = result;
    // 设置连接类型
    _registerOperation = YES;
    // 断开连接
    [_xmppStream disconnect];
    // 发送一个“注册jid”给服务器，请求一个长连接
    [self connectToServer];
}

#pragma mark - XMPPStreamDelegate
//连接建立成功调用
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    // 发送密码
    [self sendPasswordToServer];
    WCLog(@"连接建立成功");
}

// 与服务器断开连接调用
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    WCLog(@"连接断开:%@", error);
}

//登陆成功调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
    WCLog(@"登陆成功");
}
//登陆失败调用
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
    WCLog(@"登录失败");
}
//注册成功调用
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
    WCLog(@"注册成功");
}
// 注册失败调用
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
    WCLog(@"注册失败");
}

- (void)dealloc {
    [self teardownStream];
}

@end
