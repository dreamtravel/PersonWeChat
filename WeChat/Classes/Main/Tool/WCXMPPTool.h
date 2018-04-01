//
//  WCXMPPTool.h
//  WeChat
//
//  Created by Mac on 15/11/3.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

typedef enum {
    XMPPResultTypeLoginSuccess,
    XMPPResultTypeLoginFailure,
    XMPPResultTypeRegisterSuccess,
    XMPPResultTypeRegisterFailure
}XMPPResultType;
/**
 *  与服务器交互的结果
 *
 *  @param type 服务器返回的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType type);

@interface WCXMPPTool : NSObject

singleton_interface(WCXMPPTool)
/**
 *  链接标识：YES--注册、NO--登陆
 */
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

// 电子名片模块
@property (nonatomic, strong, readonly) XMPPvCardTempModule *vCard;
// 电子名片数据存储
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *vCardStoryage;
// 电子名片的头像模块
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *avatar;

// 花名册模块
@property (nonatomic, strong, readonly) XMPPRoster *roster;
// 花名册数据存储
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterStoryage;

/**
 *  XMPP用户登录
 */
- (void)xmpplogin:(XMPPResultBlock)result;
/**
 *  XMPP用户注销
 */
- (void)xmpplogout;

/**
 *  XMPP用户注册
 */
- (void)xmppregister:(XMPPResultBlock)result;

@end
