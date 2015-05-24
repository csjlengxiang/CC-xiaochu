//
//  GameViewController.swift
//  CC
//
//  Created by csj on 15/5/21.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    var scene: GameScene!
    var level: Level!
    override func viewDidLoad() {
        super.viewDidLoad()

            // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.multipleTouchEnabled = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        // 建model数据
        level = Level(filename: "Level_1")
        
        /* Set the scale mode to scale to fit the window */
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.level = level
        //绑定数据
        scene.addSpriteToScence()
        
        //绑定交换事件
        scene.swipeHandler = handleSwipe
        skView.presentScene(scene)
    }
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.tryAnimateSwap(swap) {
                self.view.userInteractionEnabled = true
                //level.detectPossibleSwaps()
            }
        }
    }
    func handleMatches() {
        //let chains = level.removeMatches()
        let cookies = level.getMatches()
        if cookies.count == 0{
            self.level.detectPossibleSwaps()
            self.view.userInteractionEnabled = true
            return 
        }
        level.removeCookies(cookies)
        
        scene.animateMatchedCookies(cookies) {
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topUpCookies()
                //self.level.detectPossibleSwaps()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()
                    //self.view.userInteractionEnabled = true
                }
            }
        }
    }
}
