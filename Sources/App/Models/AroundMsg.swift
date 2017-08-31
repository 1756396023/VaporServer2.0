//
//  AroundMsg.swift
//  NHServer
//
//  Created by niuhui on 2017/5/14.
//
//
import Vapor
import Validation
import Crypto
import FluentProvider
import HTTP


final class AroundMsg:Model {
    let storage = Storage()
    /// 用户id
    var uuid   : String = ""
    /// 地铁id
    var subway_id : Int = 0
    /// 创建时间
    var create_at : Int = 0
    /// message
    var message   : String = ""
    /// images ,分割
    var images    : String = ""
    /// 地址
    var address   : String = ""
    /// 点赞数
    var ups_count : Int  = 0
    /// 评论数
    var com_count : Int  = 0
    /// 是否点赞
    var is_up     : Bool = false
    /// 设备名称
    var device    : String = ""
    init(uuid: String) {
        self.uuid = uuid
    }
    init(row: Row) throws {
        uuid = try row.get("uuid")
        subway_id = try row.get("subway_id")
        create_at = try row.get("create_at")
        message = try row.get("message")
        images   = try row.get("images")
        address = try row.get("address")
        ups_count = try row.get("ups_count")
        com_count = try row.get("com_count")
        is_up = try row.get("is_up")
        device = try row.get("device")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("uuid", uuid)
        try row.set("subway_id", subway_id)
        try row.set("create_at", create_at)
        try row.set("message", message)
        try row.set("images", images)
        try row.set("address", address)
        try row.set("ups_count", ups_count)
        try row.set("com_count", com_count)
        try row.set("is_up", is_up)
        try row.set("device", device)
        return row
    }
}
extension AroundMsg {
    func makeJSON(_ type : JsonType) throws -> JSON {
        var json = JSON()
        try json.set("subway_id", subway_id)
        try json.set("create_at", create_at)
        try json.set("message", message)
        try json.set("images", images)
        try json.set("address", address)
        try json.set("ups_count", ups_count)
        try json.set("com_count", com_count)
        try json.set("is_up", is_up)
        try json.set("device", device)
        if type == .user {
            try json.set("user", self.user()?.makeJSON(.user))
        } else if type == .me {
            try json.set("uuid", uuid)
        }
        return json
    }
}
extension AroundMsg {
    func user() throws -> User? {
        if let user = user_caches[uuid] {
            return user
        } else {
            if let user = try User.makeQuery().filter("uuid", self.uuid).limit(1).first() {
                user_caches[uuid] = user
                return user
            } else {
                return nil
            }
        }
    }
}
extension AroundMsg: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { bar in
            bar.id()
            bar.string("uuid")
            bar.int("subway_id")
            bar.int("create_at")
            bar.string("message")
            bar.string("images")
            bar.string("address")
            bar.int("ups_count")
            bar.int("com_count")
            bar.bool("is_up")
            bar.string("device")
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
