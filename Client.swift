//
//  Client.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/12.
//

import CocoaAsyncSocket
import Foundation

class Client: NSObject {
    
    static let shared = Client()
    
    let serverPort: UInt16 = UInt16(3852)   // Port 3852  1027
    let serveripInput:String = "59.110.163.3"  // IP 59.110.163.3  127.0.0.1
    //var diction : NSDictionary?
    var msg: String?
    var clientSocket:GCDAsyncSocket!
    var noti: Notification?     // Used to send success notifications after receiving data back from the server
    var recv: String = ""
    var recv_dic: [String:String] = [:]

    fileprivate var timer: Timer?
    
    override init() {
        super.init()
//        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector:  #selector(timerAction), userInfo: nil, repeats: true)
//        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
//        self.timer?.fireDate = Date.distantFuture
//        self.connectServer()
    }
    

    /**
     *计时器每秒触发事件
     **/
//    @objc func timerAction() -> Void {
//        sendMessage(self.msg as? String, type: 1001)
//    }
    
    /**
     * 销毁计时器
     **/
//    func destroyTimer(){
//        self.timer?.invalidate()
//        self.timer = nil
//    }

    // Connect Server
    func connectServer(){
        self.recv_dic = [:]
        clientSocket = GCDAsyncSocket()
        clientSocket.delegate = self
        clientSocket.delegateQueue = DispatchQueue.global()
        do {
            try clientSocket.connect(toHost: serveripInput, onPort: serverPort)
        } catch {
            print("try connect error: \(error)")
        }

    }
    
    // Disconnect Server
    func disconnectServer(){
        self.clientSocket?.disconnect()
    }

    // Send Message to Server
    func sendMessage(_ serviceDic:String?,type:Int){
        //print("type---> \(type)")
        let msg: Data? = serviceDic?.data(using: .utf8)
        clientSocket.write(msg, withTimeout: -1, tag: 0)
        print("Try to send msg: \(serviceDic)")
    }
    
    // Receive Msg
    func receiveData() -> [String:Any] {
        return self.recv_dic
    }
}

extension Client: GCDAsyncSocketDelegate{
    
    // Successfully connect Server
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) -> Void {
        print("Socket 连接服务器成功")
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    // Failed connect Server
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Swift.Error?) -> Void {
        print("Socket 连接服务器失败: \(String(describing: err))")
        self.timer?.fireDate = Date.distantFuture
    }
    
    // Send successfully
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("Send successfully!")
    }

    // Handle msg from Server
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msg = String.init(data: data as Data, encoding: String.Encoding.utf8)
        print("Data received：\(msg)")
        self.recv = msg!
        
        var dic: [String:String] = [:]
        var temp = msg!.dropFirst(2)
        temp = temp.dropLast(2)
        let x = temp.components(separatedBy: ", ")
        var y = x[0].components(separatedBy: ":")
        dic[y[0]] = y[1]
        
        y = x[1].components(separatedBy: ":")
        dic[y[0]] = y[1]

        temp = x[2].dropFirst(6)
        temp = temp.dropLast()
        
        let z = temp.components(separatedBy: "; ")
        z.forEach{ i in
            y = i.components(separatedBy: ":")
            if(y.count == 2) {
                dic[y[0]] = y[1]

            }
        }
        self.recv_dic = dic
                        
        // After parsing the data, send a notification to the corresponding place to receive the processing
        noti = Notification(name:NSNotification.Name(rawValue: "SocketManageNotification"), object: nil, userInfo: nil)
        NotificationCenter.default.post(noti!)
        
        // Call the method that listens for data once after each read
        clientSocket.readData(withTimeout: -1, tag: 0)
    }

}

