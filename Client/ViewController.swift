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
        
        if socket.connectServe() {
            print("和服务器建立好连接了")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let msg = "文家场三等奖创建那时快借出去创建哪家。。。。。。。。"
        let msgData = msg.data(using: .utf8)!
        var len = msgData.count
        
        
        let headData = Data(bytes: &len, count: 4)
        
        var type: Int = 2
        
        let typeData = Data(bytes: &type, count: 2)
        
        socket.sendMessage(data: headData + typeData + msgData)
        
        
    }

}

