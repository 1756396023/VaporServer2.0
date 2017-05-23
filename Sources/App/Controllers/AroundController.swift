//
//  AroundController.swift
//  NHServer
//
//  Created by niuhui on 2017/5/14.
//
//

import Vapor
import HTTP
import Foundation
class AroundController {
    
    func registeredRouting() {
        let tokenAround = token.grouped("around")
        let around      = v1.grouped("around")
        around.get("message", handler: self.getAroundMsgs)
        tokenAround.post("message", handler: self.postAroundMsgs)
        tokenAround.get("user","message", handler: self.getUserAroundMsgs)
    }
    //获取所有动态
    func getAroundMsgs(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        var arounds = [AroundMsg]()
        var aroundQuery = try AroundMsg.makeQuery().sort("create_at", .descending)
        if let subway_id = request.data["subway_id"]?.int {
            aroundQuery = try aroundQuery.filter("subway_id", subway_id)
        }
        
        if var page = request.data["pagenum"]?.int  {
            if page == 0 {
                page = 1
            }
            arounds = try aroundQuery.limit(20, offset: 20*(page - 1)).all()
        } else {
            arounds = try aroundQuery.limit(20, offset: 0).all()
        }
        return try JSON(node: [
            code: 0,
            msg: "success",
            "arounds": arounds.makeNode(in: MyContext(.user)),
            ])
    }
    func getUserAroundMsgs(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        var arounds = [AroundMsg]()

        let user = request.user()!
        let aroundQuery = try AroundMsg.makeQuery().filter("uuid",user.uuid).sort("create_at", .descending)
        if var page = request.data["pagenum"]?.int  {
            if page == 0 {
                page = 1
            }
            arounds = try aroundQuery.limit(20, offset: 20*(page - 1)).all()
        } else {
            arounds = try aroundQuery.limit(20, offset: 0).all()
        }
        return try JSON(node: [
            code: 0,
            msg: "success",
            "arounds": arounds.makeNode(in: nil),
            ])
    }
    //发布动态
    func postAroundMsgs(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")

        let user = request.user()
        let around = AroundMsg(uuid: (user?.uuid)!)
        if let message = request.data["message"]?.string {
            around.message = message
        }
        if let images = request.data["images"]?.string {
            around.images = images
        }
        if let address = request.data["address"]?.string {
            around.address = address;
        }
        if let subway_id = request.data["subway_id"]?.int {
            around.subway_id = subway_id;
        }
        around.create_at = Int(Date().timeIntervalSince1970)
        try around.save()
        return try JSON(node: [
            code: 0,
            msg: "success",
            "id": around.id!
            ])
    }
}
