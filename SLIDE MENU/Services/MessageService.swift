//
//  MessageService.swift
//  SLIDE MENU
//
//  Created by Mac on 9/29/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
    
    static let instance = MessageService()
    
    var channels = [Channel]()
    var messages = [Message]()
    var unreadChannels = [String]()
    var selectedChannel : Channel?
    
    func findAllChannel(completion: @escaping CompletionHandler) {
        let BEARER_HEADER = [
            "Authorization": "Bearer \(AuthService.instance.authToken)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        Alamofire.request(URL_GET_CHANNELS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                
                guard let data = response.data else { return }
                
                do {
                    self.channels = try JSONDecoder().decode([Channel].self, from: data)
                    completion(true)
                    NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                    completion(true)
                } catch let error {
                    debugPrint(error as Any)
                }
//                print(self.channels[1].name as Any)
                
                
                
                //                if let json = JSON(data: data).array {
                //                    for item in json {
                //                        let name = item["name"].stringValue
                //                        let channelDescription = item["description"].stringValue
                //                        let id = item["_id"].stringValue
                //                        let channel = Channel(channelTitle: name, channelDescription: channelDescription, id: id)
                //                        self.channels.append(channel)
                //                    }
                //                    completion(true)
                //                }
                
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    func findAllMessageForChannel(channelId: String, completion: @escaping CompletionHandler)  {
        let url = "\(URL_GET_MESSAGES)\(channelId)"
        let headers = [
            "Authorization": "Bearer \(AuthService.instance.authToken)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if response.result.error == nil {
                self.clearMessages()
                
                guard let data = response.data else { return }
                
                do{
                    let json = try JSON(data: data).array
                    for item in json! {
                        let messageBody = item["messageBody"].stringValue
                        let channelId = item["channelId"].stringValue
                        let id = item["_id"].stringValue
                        let userName = item["userName"].stringValue
                        let userAvatar = item["userAvatar"].stringValue
                        let userAvatarColor = item["userAvatarColor"].stringValue
                        let timeStamp = item["timeStamp"].stringValue
                        
                        let message = Message(message: messageBody, userName: userName, channelId: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                        self.messages.append(message)
                    }
                    print(self.messages)
                    completion(true)
                } catch let error {
                    debugPrint(error as Any)
                }
                
                
            } else {
                debugPrint(response.result.error as Any)
                completion(false)
            }
        }
        
    }
    
    func clearMessages()  {
        messages.removeAll()
    }
    func clearChannels() {
        channels.removeAll()
    }
}
