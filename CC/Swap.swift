//
//  Swap.swift
//  CC
//
//  Created by csj on 15/5/23.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import Foundation


func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cf == rhs.cf && lhs.ct == rhs.ct) ||
        (lhs.ct == rhs.cf && lhs.cf == rhs.ct)
}
struct Swap: Printable, Hashable {
    let cf: Cookie
    let ct: Cookie
    init (cf: Cookie, ct: Cookie){
        self.cf = cf
        self.ct = ct
    }
    var description: String{
        return "swap \(cf.description) \(ct.description)"
    }
    var hashValue: Int {
        return cf.hashValue ^ ct.hashValue
    }
}