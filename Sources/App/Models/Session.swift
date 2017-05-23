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
    var user_id   : Identifier?
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
        self.user_id = user.id
        self.expire_at = Int(Date().timeIntervalSince1970) + 30 * 24 * 60 * 60
        self.token = generateSignInToken(user.id!.int!)
        self.uuid    = user.uuid
    }
    init(row: Row) throws {
        uuid = try row.get("uuid")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("uuid", uuid)
        return row
    }
    func generateSignInToken(_ userID: Int) -> String {
        do {
            let id = userID + Int(Date().timeIntervalSince1970)
            let userBye =  "\(id)".makeBytes()
            let result = try Hash.make(.md5, userBye)
            let byes =  result.hexString.makeBytes()
            return byes.base64Encoded.hexString.replacingOccurrences(of: "=", with: "")
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
