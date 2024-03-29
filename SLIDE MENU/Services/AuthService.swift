//
//  AuthService.swift
//  SLIDE MENU
//
//  Created by Mac on 9/21/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AuthService{
    static let instance = AuthService()
    let defaults = UserDefaults.standard
    var isLoggedIN: Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    var authToken: String {
        get {
            if let token = defaults.value(forKey: TOKEN_KEY) as? String{
                return token
            }else{
                defaults.set("", forKey: TOKEN_KEY)
                return ""
            }
        }
        set {
            defaults.set(newValue, forKey: TOKEN_KEY)
        }
    }
    var userEmail: String {
        get {
            return defaults.value(forKey: USER_EMAIL) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_EMAIL)
        }
    }
    //RegisterUserFunction
    func registerUser(email: String, password: String, completion: @escaping CompletionHandler)
    {
        let lowerCaseEmail = email.lowercased()
        
        let body: [String: Any] = [
            
            "email": lowerCaseEmail,
            "password": password
        ]
        Alamofire.request(URL_REGISTER, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    // LoginUserFunction
    func loginUser(email: String, password: String, completion: @escaping CompletionHandler) {
        
        let lowerCaseEmail = email.lowercased()
        
        let body: [String: Any] = [
            "email": lowerCaseEmail,
            "password": password
        ]
        Alamofire.request(URL_LOGIN, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                //                if let json = response.result.value as? Dictionary<String, Any> {
                //                    if let email = json["user"] as? String {
                //                        self.userEmail = email
                //                    }
                //                    if let token = json["token"] as? String {
                //                        self.authToken = token
                //                    }
                //                }
                // Using SwiftyJSON
                guard let data = response.data else {return}
                let json = try! JSON(data: data)
                self.userEmail = json["user"].stringValue
                self.authToken = json["token"].stringValue
                
                self.isLoggedIN = true
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    func createUser(name: String, email: String, avatarName: String, avatarColor: String, completion: @escaping CompletionHandler ) {
        
        let lowerCaseEmail = email.lowercased()
        
        let body: [String: Any] = [
            "name": name,
            "email": lowerCaseEmail,
            "avatarName": avatarName,
            "avatarColor": avatarColor,
        ]
        
        let BEARER_HEADER = [
            "Authorization": "Bearer \(AuthService.instance.authToken)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(URL_USER_ADD, method: .post, parameters: body, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                
                guard let data = response.data else {return}
                self.setUserInfo(data: data)
                completion(true)
                
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    func findUserByEmail(completion: @escaping CompletionHandler) {
        let BEARER_HEADER = [
            "Authorization": "Bearer \(AuthService.instance.authToken)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        Alamofire.request("\(URL_USER_BY_EMAIL)\(userEmail)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                
                guard let data = response.data else {return}
                self.setUserInfo(data: data)
                completion(true)
                
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    func setUserInfo(data: Data) {
        let json = try! JSON(data: data)
        let id = json["_id"].stringValue
        let color = json["avatarColor"].stringValue
        let avatarName = json["avatarName"].stringValue
        let email = json["email"].stringValue
        let name = json["name"].stringValue
        
        UserDataService.instance.setUserData(id: id, color: color, avatarName: avatarName, email: email, name: name)
    }
}

