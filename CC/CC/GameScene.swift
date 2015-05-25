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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
// 根据模型初始化
extension GameScene {
    /* 由数据模型生成sprite */
    func addSpriteToScence(level: Level) {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                //level: tile add
                if let tile = level.tileAt(column, row: row) {
                    let position = pointForColumn(column, row: row)
                    let tileSprite = SKSpriteNode(imageNamed: "Tile")
                    tileSprite.position = position
                    tilesLayer.addChild(tileSprite)
                    
                    //level: cookie add
                    let cookie = level.cookieAt(column, row: row)!
                    let cookieSprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                    cookie.sprite = cookieSprite
                    cookieSprite.position = position
                    cookiesLayer.addChild(cookieSprite)
                }
            }
        }
    }
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)
        }
    }
}
/*
    触摸判定swap相关
    高亮消除才消失，错误交换和非法交换保持高亮
*/
extension GameScene {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 单点触控
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        let (success, column, row) = convertPoint(location)
        if success {
            if let cookie = level.cookieAt(column, row: row) {
                swipeFromColumn = column
                swipeFromRow = row
                showSelectionIndicatorForCookie(cookie)
            }
        }
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if swipeFromColumn == nil { return }
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        let (success, column, row) = convertPoint(location)
        
        if success {
            
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
            
            if horzDelta != 0 || vertDelta != 0 {
                let swipeToColumn = swipeFromColumn + horzDelta
                let swipeToRow = swipeFromRow + vertDelta
                
                let from = level.cookieAt(swipeFromColumn, row: swipeFromRow)!
                if let to = level.cookieAt(swipeToColumn, row: swipeToRow){
                    
                    if let handler = swipeHandler {
                        let sw = Swap(cf: from, ct: to)
                        
                        handler(sw)
                        //hideSelectionIndicator(tm: 0.3)
                    }
                    
                }
                //hideSelectionIndicator(tm: 0.3)
                swipeFromColumn = nil
            }
        }
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
//        if selectionSprite.parent != nil && swipeFromColumn != nil {
//            hideSelectionIndicator(tm: 0)
//        }
        swipeFromColumn = nil
    }
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
    // 其实是覆盖原先的图片了
    func showSelectionIndicatorForCookie(cookie: Cookie) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1
        }
    }
    // 消失后删除
    func hideSelectionIndicator(tm: NSTimeInterval = 0.2) {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(tm),
            SKAction.removeFromParent()]))
    }
}
// 交换动画
extension GameScene {
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cf.sprite
        let spriteB = swap.ct.sprite
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.15
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(moveA)
        spriteB.runAction(moveB)
        hideSelectionIndicator(tm: 0.15)
        runAction(SKAction.waitForDuration(Duration), completion: completion)
        
    }
    func tryAnimateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cf.sprite
        let spriteB = swap.ct.sprite
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.1
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        //spriteA.runAction(, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteA.runAction(SKAction.sequence([moveA, moveB]))
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        runAction(SKAction.waitForDuration(Duration), completion: completion)

    }
}
// 消失动画
extension GameScene {
    func animateRemoveCookies(cookies: Set<Cookie>, completion: () -> ()){
        let duration: NSTimeInterval = 0.15
        for cookie in cookies {
            if let sprite = cookie.sprite {
                if sprite.actionForKey("removing") == nil {
                    let scaleAction = SKAction.scaleTo(0.1, duration: duration)
                    scaleAction.timingMode = .EaseOut
                    sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                        withKey:"removing")
                }
            }
        }
        //completion()
        runAction(SKAction.waitForDuration(duration), completion: completion)
    }
}
// 下落动画
extension GameScene {
    func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, cookie) in enumerate(array) {
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                let delay = 0.05 + 0.05 * NSTimeInterval(idx)
                let sprite = cookie.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        moveAction]))
            }
        }
        runAction(SKAction.waitForDuration(longestDuration * 0.5), completion: completion)
    }
    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            let startRow = array[0].row + 1
            for (idx, cookie) in enumerate(array) {
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.position = pointForColumn(cookie.column, row: startRow)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite
                let delay = 0.05 + 0.1 * NSTimeInterval(array.count - idx - 1)
                let duration = NSTimeInterval(startRow - cookie.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
            
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
