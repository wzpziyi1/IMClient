//
//  ViewController.swift
//  Client
//
//  Created by 王志盼 on 16/05/2017.
//  Copyright © 2017 王志盼. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate lazy var socket = ZYSocket(addr: "192.168.99.107", port: 9999)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if socket.connectServe(timeout: 10) {
            
            socket.readMessage()
        }
        
        /*protocolbuffer使用的规范
         syntax = "proto2"; 为定义使用的版本号, 目前常用版本proto2/proto3
         message是消息定义的关键字，等同于C++/Swift中的struct/class，或是Java中的class
         Person为消息的名字，等同于结构体名或类名
         required前缀表示该字段为必要字段，既在序列化和反序列化之前该字段必须已经被赋值
         optional前缀表示该字段为可选字段, 既在序列化和反序列化时可以没有被赋值
         repeated通常被用在数组字段中
         int64和string分别表示整型和字符串型的消息字段
         id和name和email分别表示消息字段名，等同于Swift或是C++中的成员变量名
         标签数字1和2则表示不同的字段在序列化后的二进制数据中的布局位置, 需要注意的是该值在同一message中不能重复
         
         最后：
         protoc IMMessage.proto --swift_out="./"
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func btnClick(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            socket.sendEnterRoom()
        case 1:
            socket.sendLeaveRoom()
        case 2:
            socket.sendTextMsg("你好，服务器~~")
        case 3:
            socket.sendGiftMsg("呜呜呜乌黑的", giftUrlStr: "http://www.baidu.com", giftCount: 90)
        default:
            print("未识别消息")
        }
    }

}

