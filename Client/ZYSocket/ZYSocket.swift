//
//  ZYSocket.swift
//  Client
//
//  Created by 王志盼 on 16/05/2017.
//  Copyright © 2017 王志盼. All rights reserved.
//

import UIKit

class ZYSocket {
    
    fileprivate var client: TCPClient
    
    init(addr: String, port: Int) {
        client = TCPClient(addr: addr, port: port)
    }
    
}

extension ZYSocket {
    
    /// 连接服务器
    func connectServe() -> Bool {
        return client.connect(timeout: 5).0
    }
    
    func readMessage() {
        
        DispatchQueue.global().async {
            
            
            
            while true {
                //读取4个字节的head长度，读出来的是后续这个真实字节流的长度
                guard let msgLen = self.client.read(4) else {
                    continue
                }
                
//                let msg =
            }
        }
        
    }
    
    func sendMessage(data: Data) {
        client.send(data: data)
    }
}
