//
//  LoadController.swift
//  NHServer
//
//  Created by niuhui on 2017/5/11.
//
//
import Vapor
import HTTP
import Crypto
import Foundation
class LoadController {
    func registeredRouting() {
        //需要登录验证的
        token.post("upload", handler: self.upload)
        drop.get("download", String.parameter, handler: self.download)
    }
    
    /// 上传图片接口
    func upload(_ request: Request) throws -> ResponseRepresentable {
        print(request.query ?? "没有参数")
        guard let image = request.formData?["file"]?.part.body else{
            return try JSON(node: [
                code: 1,
                msg : "缺少图片"
                ])
        }
        //设定路径
        let result = try Hash.make(.md5, image)
        let name  =  result.hexString + ".png";
        let url = URL(fileURLWithPath: config.workDir + "Public/images/file/"+name)
        let data = Data(bytes: image)
        do {
            try data.write(to: url)
            return try JSON(node: [
                code: 0,
                msg : "success",
                "url" : "http://59.110.223.55:8080/download/\(name)"
                ])
        } catch {
            return try JSON(node: [
                code: 1,
                msg : "上传失败"
                ])
        }
    }
    func download(_ request: Request) throws -> ResponseRepresentable {
        let iamgeName = try request.parameters.next(String.self)
        return Response(redirect: "http://59.110.223.55:8080/images/file/\(iamgeName)")
    }
}
