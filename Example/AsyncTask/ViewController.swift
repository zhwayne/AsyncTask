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
    
    var queue: AsyncTaskQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AsyncTaskQueue.isLogEnabled = true
        queue = AsyncTaskQueue()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let task = AlertTask(baseViewController: self, priority: .default)
            self.queue?.addTask(task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let task = AlertTask(baseViewController: self, priority: .low)
            self.queue?.addTask(task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let task = AlertTask(baseViewController: self, priority: .default)
            self.queue?.addTask(task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let task = AlertTask(baseViewController: self, priority: .hight)
            self.queue?.addTask(task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let task = AlertTask(baseViewController: self, priority: .default + 100)
            self.queue?.addTask(task)
            print(self.queue!)
        }
    }

    @IBAction func onAddButtonClick(_ sender: Any) {
        let task = AlertTask(baseViewController: self, priority: .default)
        queue?.addTask(task)
    }
    
    @IBAction func onDistroyButtonClick(_ sender: Any) {
        queue = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

