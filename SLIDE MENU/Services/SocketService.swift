//
//  SocketService.swift
//  SLIDE MENU
//
//  Created by Mac on 9/30/19.
//  Copyright © 2019 Mac. All rights reserved.
//
//class Bar : Foo {
//    init() {
//        super.init()
//        let foo = Foo()
//        foo.name(1, b: 2)
//    }
//}
import UIKit
import SocketIO

class SocketService: NSObject {
    static let instance = SocketService()
    override init() {
        super.init()
    }
    let manager = SocketManager(socketURL: URL(string: BASE_URL)!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    //     var socket : SocketIOClient = SocketIOClient(socketURL: URL(string: BASE_URL)!)
    
    func establishConnection() {
        self.socket = manager.defaultSocket
        socket.connect()
        
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func addChannel(channelName: String, channelDescription: String, completion: @escaping CompletionHandler) {
        socket.emit("newChannel", channelName, channelDescription)
        completion(true)
    }
    func getChannel(completion: @escaping CompletionHandler) {
        socket.on("channelCreated") { (dataArray, ack) in
            guard let ChannelName = dataArray[0] as? String else { return }
            guard let ChannelDesc = dataArray[1] as? String else { return }
            guard let ChannelId = dataArray[2] as? String else { return }
            
            let newChannel = Channel(_id: ChannelId, name: ChannelName, description: ChannelDesc, __v: 0)
            MessageService.instance.channels.append(newChannel)
            completion(true)
            
        }
    }
    func addMessage (messageBody: String, userId: String, channelId: String, completion: @escaping CompletionHandler) {
        let user = UserDataService.instance
        socket.emit("newMessage", messageBody, userId, channelId, user.name, user.avatarName, user.avatarColor)
        completion(true)
    }
    func getChatMessage(completion: @escaping (_ newMessage: Message) -> Void)  {
        socket.on("messageCreated") { (dataArray, ack) in
            guard let msgBody = dataArray[0] as? String else { return }
            guard let channelId = dataArray[2] as? String else { return }
            guard let userName = dataArray[3] as? String else { return }
            guard let userAvatar = dataArray[4] as? String else { return }
            guard let userAvatarColor = dataArray[5] as? String else { return }
            guard let id = dataArray[6] as? String else { return }
            guard let timeStamp = dataArray[7] as? String else { return }
            
            let newMessage = Message(message: msgBody, userName: userName, channelId: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
            
           completion(newMessage)
        }
    }
    func getTypingUsers(_ completionHandler: @escaping (_ typingUsers:[String: String ]) -> Void) {
        socket.on("userTypingUpdate") { (dataArray, ack) in
            guard let typingUsres = dataArray[0] as? [String: String] else { return }
            completionHandler(typingUsres)
        }
    }
    
}
