//
//  ViewController.swift
//  AsyncTask
//
//  Created by iya on 09/17/2021.
//  Copyright (c) 2021 iya. All rights reserved.
//

import UIKit
import AsyncTask

class ViewController: UIViewController {
    
    var queue: AsyncQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // AsyncQueue.isLogEnabled = true
        queue = AsyncQueue()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let task = AlertTask(baseViewController: self, priority: .default)
            self.queue?.add(task: task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let task = AlertTask(baseViewController: self, priority: .low)
            self.queue?.add(task: task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let task = AlertTask(baseViewController: self, priority: .default)
            self.queue?.add(task: task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let task = AlertTask(baseViewController: self, priority: .hight)
            self.queue?.add(task: task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let task = AlertTask(baseViewController: self, priority: .default + 100)
            self.queue?.add(task: task)
            print(self.queue!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

