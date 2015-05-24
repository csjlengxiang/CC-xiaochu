//
//  ViewController.swift
//  testtouch
//
//  Created by csj on 15/5/23.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let p = (touches.first as! UITouch).locationInView(self.view)
        
        lb.center = p
        
        println("\(p.x) \(p.y)")
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // println(touches.count)
        
        let p = (touches.first as! UITouch).locationInView(self.view)
        let pp = (touches.first as! UITouch).previousLocationInView(self.view)
        
        lb.center = p //CGPoint(lb.center.x +
    }
}

