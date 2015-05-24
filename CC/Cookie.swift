//
//  Cookie.swift
//  CC
//
//  Created by csj on 15/5/21.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import Foundation
import SpriteKit

enum CookieType: Int, Printable {
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
    static let spriteNames: [String] = [
        "Croissant",
        "Cupcake",
        "Danish",
        "Donut",
        "Macaroon",
        "SugarCookie"]
    
    var spriteName: String {
        return CookieType.spriteNames[rawValue - 1]
    }
    var description: String {
        return spriteName
    }
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}
func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
class Cookie: Printable, Hashable {
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode!
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
    var description: String {
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    var hashValue: Int{
        return row * 10 + column
    }
}
