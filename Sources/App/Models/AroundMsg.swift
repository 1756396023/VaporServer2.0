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
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("uuid", uuid)
        try row.set("subway_id", subway_id)
        try row.set("create_at", create_at)
        try row.set("message", message)
        try row.set("images", images)
        try row.set("address", address)
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
        if type == .user {
            try json.set("user", self.user()?.makeJSON(.user))
        } else if type == .me {
            try json.set("uuid", uuid)
        }
        return json
    }
}
extension AroundMsg: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("subway_id", subway_id)
        try node.set("create_at", create_at)
        try node.set("message", message)
        try node.set("images", images)
        try node.set("address", address)
        if let myContext = context as? MyContext{
            if myContext.type == .user {
                try node.set("user", self.user()?.makeJSON(.user))
            }
        } else {

        }
        return node
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
        try database.create(self) { users in
            users.id()
            users.string("uuid")
            users.int("subway_id")
            users.int("create_at")
            users.string("message")
            users.string("images")
            users.string("address")
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
