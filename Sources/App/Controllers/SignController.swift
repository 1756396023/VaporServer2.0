//
//  SignController.swift
//  NHServer
//
//  Created by niuhui on 2017/5/10.
//
//

import Vapor
import HTTP
import Foundation
class SignController {
    
    let eModel = EModel()
    func registeredRouting() {
        v1.post("signup", handler: self.signup)
        v1.post("signin", handler: self.signin)
        v1.post("signup","validate", handler: self.signupValidate)
        //需要登录验证的
        token.get("signout", handler: self.signout)
    }
    func signup(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        guard let phone = request.data["phone"]?.string else{
            return JSON([
                code: 1,
                msg : "缺少phone"
                ])
        }
        if  phone.isPhone == false {
            return JSON([
                code: 1,
                msg : "请输入正确的手机号"
                ])
        }
        let temp = try User.makeQuery().filter("phone", phone).first()
        guard temp == nil else{
            return JSON([
                code: 1,
                msg : "此电话号码已被注册"
                ])
        }
//        guard let vcode = request.data["vcode"]?.int else {
//            return try JSON(node: [
//                code: 1,
//                msg : "缺少验证码"
//                ])
//        }
//        if vcode != 456321 {
//            
//        }
        guard let pw = request.data["pw"]?.string else{
            return JSON([
                code: 1,
                msg : "缺少密码"
                ])
        }
        if pw.isPassWord == false {
            return JSON([
                code: 1,
                msg : "请输入6-20位数组或字母的密码"
                ])
        }
        let user = User(phone: phone, pw: pw)
        try user.save()
        //是否成功注册环信
        user.isERegister = eModel.registerUser(user.uuid, passWord: user.password)
        let session = Session(user:user)
        try session.save()
        try user.save()
        user_caches[user.uuid.string] = user
        session_caches[session.token!] = session
        try drop.cache.set(user.uuid, user.makeJSON(.me))
        return try JSON(node: [
            code: 0,
            "token": session.token!,
            "uuid" : user.uuid,
            "expire_at" : session.expire_at,
            "em_pw"     : user.password,
            msg : "success"
            ])
    }
    func signin(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        guard let phone = request.data["phone"]?.string else{
            return try JSON(node: [
                code: 1,
                msg : "缺少phone"
                ])
        }
        if  phone.isPhone == false {
            return try JSON(node: [
                code: 1,
                msg : "请输入正确的手机号"
                ])
        }
        guard let user =  try User.makeQuery().filter("phone", phone).first() else {
            return try JSON(node: [
                code: 1,
                msg : "未注册"
                ])
        }
        guard let pw = request.data["pw"]?.string else{
            return JSON([
                code: 1,
                msg : "缺少密码"
                ])
        }
        if pw.isPassWord == false {
            return JSON([
                code: 1,
                msg : "请输入6-20位数组或字母的密码"
                ])
        }
        guard user.password == pw.md5 else {
            return JSON([
                code: 1,
                msg : "密码错误"
                ])
        }
        if user.isERegister == false {
            user.isERegister = eModel.registerUser(user.uuid, passWord: user.password)
            try user.save()
        }
        let session = Session.session(user: user)
        try session.save()
        user_caches[user.uuid.string] = user
        session_caches[session.token!] = session
        return try JSON(node: [
            code: 0,
            "uuid" : user.uuid,
            "expire_at" : session.expire_at,
            "token": session.token ?? "",
            "em_pw"     : user.password,
            msg : "success"
            ])
    }
    func signout(_ request: Request) throws -> ResponseRepresentable {
        let session = request.userSession()
        session?.expire_at = 0
        try session?.save()
        session_caches[(session?.token!)!] = session
        return try JSON(node: [
            code: 0,
            msg : "success"
            ])
    }
    func signupValidate(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        guard let phone = request.data["phone"]?.string else{
            return try JSON(node: [
                code: 1,
                msg : "缺少phone"
                ])
        }
        if  phone.isPhone == false {
            return try JSON(node: [
                code: 1,
                msg : "请输入正确的手机号"
                ])
        }
        let temp = try User.makeQuery().filter("phone", phone).first()
        guard temp == nil else{
            return try JSON(node: [
                code: 0,
                msg : "success",
                "is_signup": true
                ])
        }
        return try JSON(node: [
            code: 0,
            msg : "success",
            "is_signup": false
            ])
    }
}
