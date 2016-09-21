//
//  ViewController.swift
//  SwiftDemo
//
//  Created by TuLigen on 16/2/17.
//  Copyright (c) 2016年 TuLigen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var helloBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clicked(sender: AnyObject) {
        var alert = UIAlertController(title: "hello", message: "hello world", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        self.helloBtn.setTitle("CC", forState: UIControlState.Normal);
    }
}

