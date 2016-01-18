//
//  IMClass.swift
//  Nian iOS
//
//  Created by Sa on 16/1/8.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
class IMClass: AnyObject {
    
    /* 连接 IM 服务器 */
    class func IMConnect() {
        // todo: 修改为生产环境
        Api.getRongTokenDevelopment() { json in
            if json != nil {
                if let j = json as? NSDictionary {
                    let token = j.stringAttributeForKey("data")
                    RCIMClient.sharedRCIMClient().connectWithToken(token, success: { (string) -> Void in
                        /* 登录成功 */
                        }, error: { (err) -> Void in
                            /* 登录失败 */
                        }, tokenIncorrect: { () -> Void in
                            /* token 错误 */
                    })
                }
            }
        }
    }
    
    /* 将 RCMessage 解析为梦境支持的字典 */
    func messageToDictionay(message: RCMessage) -> NSDictionary {
        if let text = message.content as? RCTextMessage {
            let time = ("\(message.sentTime / 1000)" as NSString).doubleValue
            let lastdate = V.absoluteTime(time)
            let extra = text.extra.componentsSeparatedByString(":")
            let messageid = "\(message.messageId)"
            let senderUserid = message.senderUserId
            
            /* 发起者的昵称 */
            let nameSender = extra[1]
            return NSDictionary(objects: [text.content, messageid, lastdate, senderUserid, nameSender, "1", "", "0"], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
        } else if let text = message.content as? RCImageMessage {
            let time = ("\(message.sentTime / 1000)" as NSString).doubleValue
            let lastdate = V.absoluteTime(time)
            let extra = text.extra.componentsSeparatedByString(":")
            let messageid = "\(message.messageId)"
            let senderUserid = message.senderUserId
            
            /* 发起者的昵称 */
            let nameSender = extra[1]
            return NSDictionary(objects: [text.imageUrl, messageid, lastdate, senderUserid, nameSender, "2", "", "0"], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
        } else {
            return NSDictionary()
        }
    }
}