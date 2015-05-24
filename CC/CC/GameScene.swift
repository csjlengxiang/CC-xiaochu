//
//  GameScene.swift
//  CC
//
//  Created by csj on 15/5/21.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var level: Level!
    
    //这些与场景绘制有关
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    // 场景里各图层，gameLayer 包含 tilesLayer和cookiesLayer
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let cookiesLayer = SKNode()

    // 交换相关
    var swipeFromColumn: Int!
    var swipeFromRow: Int!
    var swipeHandler: ((Swap) -> ())?
    var selectionSprite = SKSpriteNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
        
        addChild(gameLayer)
    }
    /* 由数据生成sprite */
    func addSpriteToScence(){
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                //level: tile add
                if let tile = level.tileAt(column, row: row) {
                    let position = pointForColumn(column, row: row)
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = position
                    tilesLayer.addChild(tileNode)
                    
                    //level: cookie add
                    let cookie = level.cookieAt(column, row: row)!
                    let cookieNode = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                    cookie.sprite = cookieNode
                    cookieNode.position = position
                    cookiesLayer.addChild(cookieNode)
                }
            }
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension GameScene {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        //println("\(location.x) \(location.y)")
        let (success, column, row) = convertPoint(location)
        if success {
            // 3
            if let cookie = level.cookieAt(column, row: row) {
                // 4
                swipeFromColumn = column
                swipeFromRow = row
                // 显示高亮
                showSelectionIndicatorForCookie(cookie)
                println("\(location.x) \(location.y)")
            }
        }
        
    }
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // 1
        if swipeFromColumn == nil { return }
        
        // 2
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            // 3
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow {         // swipe up
                vertDelta = 1
            }
            
            // 4
            if horzDelta != 0 || vertDelta != 0 {
                let swipeToColumn = swipeFromColumn + horzDelta
                let swipeToRow = swipeFromRow + vertDelta
                
                // 5
                let from = level.cookieAt(swipeFromColumn, row: swipeFromRow)!
                if let to = level.cookieAt(swipeToColumn, row: swipeToRow){
                    
                    if let handler = swipeHandler {
                        let sw = Swap(cf: from, ct: to)
                        
                        println(sw.description)
                        handler(sw)
                    }
                    
                }
                hideSelectionIndicator(tm: 0.3)
                
                swipeFromColumn = nil
            }
        }
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator(tm: 0)
        }
        
        swipeFromColumn = nil
    }
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cf.sprite
        let spriteB = swap.ct.sprite
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(moveA)
        spriteB.runAction(moveB)
        runAction(SKAction.waitForDuration(0.3 + 0.01), completion: completion)
        
    }
    func tryAnimateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cf.sprite
        let spriteB = swap.ct.sprite
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        //spriteA.runAction(, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteA.runAction(SKAction.sequence([moveA, moveB]))
        spriteB.runAction(SKAction.sequence([moveB, moveA]), completion: completion)
        
    }
    func showSelectionIndicatorForCookie(cookie: Cookie) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    func hideSelectionIndicator(tm: NSTimeInterval = 0.2) {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(tm),
            SKAction.removeFromParent()]))
    }
    
//    func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
//        for chain in chains {
//            for cookie in chain.cookies {
//                if let sprite = cookie.sprite {
//                    if sprite.actionForKey("removing") == nil {
//                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
//                        scaleAction.timingMode = .EaseOut
//                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
//                            withKey:"removing")
//                    }
//                }
//            }
//        }
//        //runAction(matchSound)
//        runAction(SKAction.waitForDuration(0.3 + 0.01), completion: completion)
//    }
    func animateMatchedCookies(cookies: Set<Cookie>, completion: () -> ()){
        
        for cookie in cookies {
            if let sprite = cookie.sprite {
                if sprite.actionForKey("removing") == nil {
                    let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                    scaleAction.timingMode = .EaseOut
                    sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                        withKey:"removing")
                }
            }
        }
        
        //runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3 + 0.01), completion: completion)
    }
    
    func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
        // 1
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, cookie) in enumerate(array) {
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                // 2
                let delay = 0.05 + 0.15*NSTimeInterval(idx)
                // 3
                let sprite = cookie.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        moveAction]))
            }
        }
        // 6
        runAction(SKAction.waitForDuration(longestDuration + 0.01), completion: completion)
    }
    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
        // 1
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            // 2
            let startRow = array[0].row + 1
            
            for (idx, cookie) in enumerate(array) {
                // 3
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.position = pointForColumn(cookie.column, row: startRow)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite
                // 4
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                // 5
                let duration = NSTimeInterval(startRow - cookie.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                // 6
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            SKAction.fadeInWithDuration(0.05),
                            moveAction])
                        ]))
            }
        }
        // 7
        runAction(SKAction.waitForDuration(longestDuration + 0.01), completion: completion)
    }
}
