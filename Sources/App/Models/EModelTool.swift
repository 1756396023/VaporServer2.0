//
//  EModelTool.swift
//  NHServer
//
//  Created by niuhui on 2017/5/12.
//
//
import Vapor
import HTTP
import Foundation
import Crypto
let eUrl : String = "https://a1.easemob.com/niuhuisunny/walkinglove/"
class EModel: NSObject {
    var access_token: String    = ""
    var expires_in  : Int       = 0
    var application : String    = ""
    func registerToken() -> Bool {
        if expires_in == 0 || (expires_in - 48*60*60) > Int(Date().timeIntervalSince1970) {
            do {
                let json = try JSON(node: [
                    "grant_type": "client_credentials",
                    "client_id" : "YXA68d7PsDb4EeecvlX547Wfkw",
                    "client_secret": "YXA6FmadCqIU4Ja0OU-eD8K-x8LHoXQ"
                    ])
                let req = try drop.client.post(eUrl+"token",[:],json.makeBody())
                if req.status.hashValue == 200 {
                    access_token = (req.data["access_token"]?.string)!
                    expires_in   = (req.data["expires_in"]?.int)!
                    application  = (req.data["application"]?.string)!
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        } else {
            return true
        }
    }
    func registerUser(_ userName: String,passWord: String)-> Bool {
        
        if registerToken() {
            do {
                let json = try JSON(node: [
                    "username": userName,
                    "password" : passWord
                    ])
                let users = try [json].makeJSON()
                let req = try drop.client.post(eUrl+"users",["Authorization":"Bearer \(access_token)"],users.makeBody())
                if req.status.hashValue == 200 {
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
            
        } else {
            return false
        }
    }
    
}
