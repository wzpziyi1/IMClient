//
//  ZYSocket.swift
//  Client
//
//  Created by 王志盼 on 16/05/2017.
//  Copyright © 2017 王志盼. All rights reserved.
//

import UIKit
import ProtocolBuffers

/*
 进入房间 = 0
 离开房间 = 1
 文本 = 2
 礼物 = 3
 心跳包 = 100
 */

enum MessageType : Int {
    case enter = 0
    case leave = 1
    case text = 2
    case gift = 3
    case heartBeat = 100
}

protocol ZYSocketDelegate: class {
    func socket(_ socket: ZYSocket, enterRoom user: UserInfo)
    func socket(_ socket: ZYSocket, leaveRoom user: UserInfo)
    func socket(_ socket: ZYSocket, textMsg: ChatMessage)
    func socket(_ socket: ZYSocket, giftMsg: GiftMessage)
}


class ZYSocket {
    
    weak var delegate: ZYSocketDelegate?
    
    fileprivate var client: TCPClient
    
    fileprivate var isConnected : Bool = false
    
    fileprivate lazy var user : UserInfo.Builder = {
        let user = UserInfo.Builder()
        user.level = Int32(arc4random_uniform(20))
        user.name = "李四\(arc4random_uniform(10))"
        user.iconUrl = "icon\(arc4random_uniform(2))"
        return user
    }()
    
    init(addr: String, port: Int) {
        client = TCPClient(addr: addr, port: port)
    }
    
}

extension ZYSocket {
    
    /// 连接服务器
    func connectServe(timeout t:Int) -> Bool {
        isConnected = true
        return client.connect(timeout: t).0
    }
    
    //从服务器读取消息逻辑处理
    func readMessage() {
        
        DispatchQueue.global().async {
            
            while self.isConnected {
                //读取4个字节的head长度，读出来的是后续这个真实字节流的长度
                guard let lenMsg = self.client.read(4) else {
                    continue
                }
                let msgData = Data(bytes: lenMsg, count: 4)
                var actualMsgLen = 0
                (msgData as NSData).getBytes(&actualMsgLen, length: 4)
                
                //解析type类型
                guard let typeMsg = self.client.read(2) else {
                    return
                }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                //解析发送过来的真实消息
                guard let actualMsg = self.client.read(actualMsgLen) else {
                    return
                }
                let actualMsgData = Data(bytes: actualMsg, count: actualMsgLen)
                
                //转发消息
                DispatchQueue.main.async {
                    self.handleMsg(type, msgData: actualMsgData)
                }
                
                
            }
        }
        
    }
    
    fileprivate func handleMsg(_ type: Int, msgData: Data) {
        
        switch type {
        case 0:
            let user = try! UserInfo.parseFrom(data: msgData)
            delegate?.socket(self, enterRoom: user)
        case 1:
            let user = try! UserInfo.parseFrom(data: msgData)
            delegate?.socket(self, leaveRoom: user)
        case 2:
            let chatMsg = try! ChatMessage.parseFrom(data: msgData)
            delegate?.socket(self, textMsg: chatMsg)
        case 3:
            let giftMsg = try! GiftMessage.parseFrom(data: msgData)
            delegate?.socket(self, giftMsg: giftMsg)
        default:
            print("其他类型消息")
        }
        
    }
    
    
    func sendEnterRoom() {
        let msgData = (try! user.build()).data()
        sendMsg(type: MessageType(rawValue: 0)!, data: msgData)
    }
    
    func sendLeaveRoom() {
        let msgData = (try! user.build()).data()
        sendMsg(type: MessageType(rawValue: 1)!, data: msgData)
    }
    
    func sendTextMsg(_ text: String) {
        //聊天对象
        let chatMsg = ChatMessage.Builder()
        chatMsg.text = text
        chatMsg.user = try! user.build()
        
        let chatData = (try! chatMsg.build()).data()
        sendMsg(type: MessageType(rawValue: 2)!, data: chatData)
        
    }
    
    func sendGiftMsg(_ giftName: String, giftUrlStr: String, giftCount: Int) {
        let giftMsg = GiftMessage.Builder()
        giftMsg.user = try! user.build()
        giftMsg.giftname = giftName
        giftMsg.giftUrl = giftUrlStr
        giftMsg.giftcount = Int32(giftCount)
        
        let giftData = (try! giftMsg.build()).data()
        sendMsg(type: MessageType(rawValue: 3)!, data: giftData)
    }
    
    //发送心跳包
    func sendHeartBeat() {
        let msgData = "heart".data(using: .utf8)!
        sendMsg(type: MessageType(rawValue: 100)!, data: msgData)
    }
    
    //发送消息逻辑处理
    func sendMsg(type: MessageType, data: Data) {
        
        var lenght = data.count
        let headData = Data(bytes: &lenght, count: 4)
        
        var msgType = type.rawValue
        let typeData = Data(bytes: &msgType, count: 2)
        
        let totalData = headData + typeData + data
        client.send(data: totalData)

    }
    
    
}
