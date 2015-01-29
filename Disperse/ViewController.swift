//
//  ViewController.swift
//  Disperse
//
//  Created by Dinndorf, Joshua C on 1/20/15.
//  Copyright (c) 2015 Dinndorf, Joshua C. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var controllerPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentDisperseViewController() {
        NSLog("presenting disperse view controller...")
        controllerPresented = true
        var dvc: DisperseViewController =
        DisperseViewController(parent: self)
        dvc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(dvc, animated: true, completion: {
            () -> Void in
            dvc.enterNewGame()
        })
    }

}

