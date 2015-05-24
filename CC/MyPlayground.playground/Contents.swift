//: Playground - noun: a place where people can play

import UIKit

class A{
    var a: B?
    var aa = 1
    class B{
        var b = 1
    }
}

var a = A()

a.aa


//a.a = A.B()

a.a?.b


if a.a?.b == 1{
    a
}else {
    a
}
