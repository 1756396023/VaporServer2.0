//
//  TokenMiddleware.swift
//  NHServer
//
//  Created by niuhui on 2017/5/9.
//
//

import Vapor
import HTTP
import Foundation


var session_caches = [String : Session]()
var user_caches    = [String:User]()
final class TokenMiddleware: Middleware {
    
    var user : User?
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        var session : Session
        guard let token = request.data["access_token"]?.string else{
            return try JSON([
                code: 1,
                msg : "未登录"
                ]).makeResponse()

        }
        if let session_cach = session_caches[token] {
            session = session_cach
        } else {
            guard let temp_session = try Session.makeQuery().filter("token", token).first() else {
                return try JSON([
                    code: 1,
                    msg : "未登录"
                    ]).makeResponse()
            }
            session = temp_session
        }
        guard session.expire_at >= Int(Date().timeIntervalSince1970) else {
            try session.delete()
            session_caches.removeValue(forKey: token)
            return try JSON([
                code: 1,
                msg : "登录过期"
                ]).makeResponse()
        }
        session_caches[token] = session
        if let _ = user_caches[session.uuid.string] {
            
        } else {
            guard let user =  try User.makeQuery().filter("id", session.user_id).first() else {
                try session.delete()
                session_caches.removeValue(forKey: token)
                return try JSON([
                    code: 1,
                    msg : "登录过期"
                    ]).makeResponse()
            }
            user_caches[user.uuid.string] = user
        }
        return try next.respond(to: request)
    }
}
