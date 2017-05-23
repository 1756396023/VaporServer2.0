//
//  ContextTool.swift
//  WalkingServer2.0
//
//  Created by niuhui on 2017/5/23.
//
//


import Vapor



import Node

final class MyContext: Context {
    
    var type : JsonType = .me
    public init(_ type: JsonType) {
        self.type = type
    }

}

