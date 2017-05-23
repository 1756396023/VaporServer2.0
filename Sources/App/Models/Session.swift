//
//  Session.swift
//  WalkingServer2.0
//
//  Created by niuhui on 2017/5/23.
//
//

import Vapor
import FluentProvider
import Crypto
final class Session: Model {
    let storage = Storage()
    /// 用户id
    var user_id   : Int    = 0
    var uuid      : String = ""
    /// token
    var token     : String?
    /// 过期时间
    var expire_at : Int = 0
    /// 推送token
    var push_token: String = ""
    class func session(user: User) -> Session {
        do {
            guard let session = try Session.makeQuery().filter("user_id", user.id!).first() else {
                return Session(user:user)
            }
            session.expire_at = Int(Date().timeIntervalSince1970) + 30 * 24 * 60 * 60
            return session
        } catch {
            return Session(user:user)
        }
    }
    init(user: User) {
        self.user_id = user.id!.int!
        self.expire_at = Int(Date().timeIntervalSince1970) + 30 * 24 * 60 * 60
        self.token = generateSignInToken(user.id!.int!)
        self.uuid    = user.uuid
    }
    init(row: Row) throws {
        user_id = try row.get("user_id")
        uuid = try row.get("uuid")
        token = try row.get("token")
        expire_at = try row.get("expire_at")
        push_token = try row.get("push_token")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("user_id", user_id)
        try row.set("uuid", uuid)
        try row.set("token", token)
        try row.set("expire_at", expire_at)
        try row.set("push_token", push_token)
        return row
    }
    func generateSignInToken(_ userID: Int) -> String {
        do {
            let id = userID + Int(Date().timeIntervalSince1970)
            let userBye =  "\(id)".makeBytes()
            let result = try Hash.make(.md5, userBye)
            let byes =  result.hexString.makeBytes()
            return byes.base64Encoded.makeString().replacingOccurrences(of: "=", with: "")
        } catch let error {
            print(error)
        }
        return ""
    }
}
extension Session {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("uuid", uuid)
        try json.set("user_id", user_id)
        try json.set("token", token)
        try json.set("push_token", push_token)
        try json.set("expire_at", expire_at)
        return json
    }
}
extension Session: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.int("user_id")
            users.string("token")
            users.int("expire_at")
            users.string("push_token")
            users.string("uuid")
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension Request {
    func userSession() -> Session? {
        guard let token = self.data["access_token"]?.string else{
            return nil
        }
        var session : Session?
        if let session_cach = session_caches[token] {
            session = session_cach
        } else {
            guard let temp_session = try? Session.makeQuery().filter("token", token).first() else {
                return nil
            }
            session = temp_session
        }
        return session
    }
}
