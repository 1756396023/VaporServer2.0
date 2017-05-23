//
//  UserController.swift
//  NHServer
//
//  Created by niuhui on 2017/5/9.
//
//
import Vapor
import HTTP

class UserController {
    func registeredRouting() {
        let user = token.grouped("user")
        user.get("profile", handler: self.getProfile)
        user.put("profile", handler: self.putProfile)
    }
    func getProfile(_ request: Request) throws -> ResponseRepresentable {
        
        let json = try request.user()?.makeJSON(.me).object
        return try JSON(node: [
            code: 0,
            msg: "success",
            "user": json!
            ])
    }
    func putProfile(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        let user = request.user()
        if let age = request.data["age"]?.int {
            user?.age = age
            print(age)
        }
        if let name = request.data["name"]?.string {
            user?.name = name
            print(name)
        }
        if let overview = request.data["overview"]?.string {
            user?.overview = overview;
            print(overview)
        }
        if let gender = request.data["gender"]?.int {
            user?.gender = gender
        }
        if let address = request.data["address"]?.string {
            user?.address = address
        }
        if let avatar = request.data["avatar"]?.string {
            user?.avatar = avatar
            print(avatar)
        }
        try user?.save()
        user_caches[user!.uuid.string] = user
        return try JSON(node: [
            code: 0,
            msg: "success",
            ])
    }
}
