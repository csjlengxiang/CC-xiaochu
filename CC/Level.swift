//
//  Level.swift
//  CC
//
//  Created by csj on 15/5/21.
//  Copyright (c) 2015 csj. All rights reserved.
//

import Foundation
let NumColumns = 9
let NumRows = 9

class Level {
    //tile not change
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    //cookie change
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    //swap set
    private var possibleSwaps: Set<Swap>!
    
    init(filename: String) {
        initTiles(filename)
        initCookies()
    }
}
// title
extension Level{
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    func initTiles(filename: String){
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {
                    let tileRow = NumRows - row - 1
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
}
// cookie
extension Level{
    func cookieAt(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    func initCookiesByTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil{
                    var cookieType: CookieType
                    do {
                        cookieType = CookieType.random()
                    }
                    while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                            cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    
                    cookies[column, row] = Cookie(column: column, row: row, cookieType: cookieType)
                }
            }
        }
    }
    func initCookies() {
        do {
            initCookiesByTiles()
            detectPossibleSwaps()
        }
        while possibleSwaps.count == 0 || possibleSwaps.count > 10
    }
}
// swap
extension Level{
    func performSwap(swap: Swap) {
        let columnA = swap.cf.column
        let rowA = swap.cf.row
        let columnB = swap.ct.column
        let rowB = swap.ct.row
        
        cookies[columnA, rowA] = swap.ct
        swap.ct.column = columnA
        swap.ct.row = rowA
        
        cookies[columnB, rowB] = swap.cf
        swap.cf.column = columnB
        swap.cf.row = rowB
    }
    func hasChainAt(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        var horzLength = 1
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    if column + 1 < NumColumns {
                        if let other = cookies[column + 1, row] {
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            if hasChainAt(column + 1, row: row) ||
                                hasChainAt(column, row: row) {
                                    set.insert(Swap(cf: cookie, ct: other))
                            }
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    if row + 1 < NumRows {
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            if hasChainAt(column, row: row + 1) ||
                                hasChainAt(column, row: row) {
                                    set.insert(Swap(cf: cookie, ct: other))
                            }
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        possibleSwaps = set
    }
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
}
// 删除消除的cookie
extension Level {
    private func detectHorizontalMatches() -> Set<Cookie> {
        var set = Set<Cookie>()
        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2 ; {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    if cookies[column + 1, row]?.cookieType == matchType &&
                        cookies[column + 2, row]?.cookieType == matchType {
                        do {
                            set.insert(cookies[column, row]!)
                            ++column
                        }
                        while column < NumColumns && cookies[column, row]?.cookieType == matchType
                        continue
                    }
                }
                ++column
            }
        }
        return set
    }
    private func detectVerticalMatches() -> Set<Cookie> {
        var set = Set<Cookie>()
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {
                        do {
                            set.insert(cookies[column, row]!)
                            ++row
                        }
                        while row < NumRows && cookies[column, row]?.cookieType == matchType
                        continue
                    }
                }
                ++row
            }
        }
        return set
    }
    func getRemoveCookies() -> Set<Cookie>{
        let h = detectHorizontalMatches()
        let v = detectVerticalMatches()
        return h.union(v)
    }
    func removeCookies(cookies: Set<Cookie>){
        for cookie in cookies {
            self.cookies[cookie.column, cookie.row] = nil
        }
    }
}
// cookie 掉落
extension Level {
    // 掉落，按照array的顺序掉落
    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()
        for column in 0..<NumColumns {
            var array = [Cookie]()
            for row in 0..<NumRows {
                if tiles[column, row] != nil && cookies[column, row] == nil {
                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] {
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            cookie.column = column
                            array.append(cookie)
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
}
// 最上层空的掉落
extension Level {
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown
        for column in 0..<NumColumns {
            var array = [Cookie]()
            for var row = NumRows - 1; row >= 0 && cookies[column, row] == nil; --row {
                if tiles[column, row] != nil {
                    var newCookieType: CookieType
                    do {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
}