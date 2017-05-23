//
//  User.swift
//  WalkingServer2.0
//
//  Created by niuhui on 2017/5/23.
//
//

import Vapor
import Validation
import Crypto
import FluentProvider
import HTTP

final class User: Model {
    
    let storage = Storage()
    //uuid
    var uuid    : String = ""
    /// 电话
    var phone   : String = ""
    /// 密码
    var password: String = ""
    /// 名字
    var name    : String = ""
    /// 头像
    var avatar  : String = ""
    /// 年龄
    var age     : Int    = 0
    /// 性别
    var gender  : Int    = 0
    /// 简介
    var overview: String = ""
    /// 地址
    var address   : String = ""
    ///是否注册环信
    var isERegister : Bool  = false
    //注册时间
    var create_at        = 0

    init(phone:String, pw:String) {
        self.phone = phone;
        self.create_at = Int(Date().timeIntervalSince1970)
    }
    init(row: Row) throws {
        id = try row.get("id")
        uuid = try row.get("uuid")
        phone = try row.get("phone")
        password = try row.get("password")
        avatar = try row.get("avatar")
        age = try row.get("age")
        gender = try row.get("gender")
        overview = try row.get("overview")
        address = try row.get("address")
        isERegister = try row.get("isERegister")
        create_at = try row.get("create_at")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("uuid", uuid)
        try row.set("phone", phone)
        try row.set("password", password)
        try row.set("avatar", avatar)
        try row.set("age", age)
        try row.set("gender", gender)
        try row.set("overview", overview)
        try row.set("address", address)
        try row.set("isERegister", isERegister)
        try row.set("create_at", create_at)
        return row
    }
}
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("phone")
            users.string("password")
            users.string("name")
            users.string("avatar")
            users.string("uuid")
            users.string("overview")
            users.int("age")
            users.int("gender")
            users.int("create_at")
            users.bool("isERegister")
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension User {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("uuid", uuid)
        return json
    }
}
extension Request {
    func user() -> User? {
        do {
            guard let token = self.data["access_token"]?.string else{return nil}
            guard let session = session_caches[token] else {return nil}
            var user : User?
            if let user_cach = user_caches[session.uuid.string] {
                user = user_cach
            } else {
                guard let user_db = try User.makeQuery().filter("id", session.user_id!).first() else {
                    return nil;
                }
                user_caches[session.uuid.string] = user_db
                user = user_db
            }
            return user
        } catch {
            return nil
        }
    }
}


