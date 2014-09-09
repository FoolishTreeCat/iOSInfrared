//
//  ViewController.swift
//  IosInfrared
//
//  Created by FoolishTreeCat on 9/9/14.
//  Copyright (c) 2014 FoolishTreeCat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var signalManager: SignalManager?
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.signalManager = (UIApplication.sharedApplication().delegate as AppDelegate).sm
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendSignal(sender: AnyObject) {
        if(self.signalManager != nil) {
            self.signalManager!.sendSignal(SignalFormat.sharedInstance.getNecSignalList(3))
        }
    }

}

