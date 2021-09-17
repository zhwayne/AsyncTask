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
    
    let queue = AsyncTaskQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let t1 = AsyncTask { task in
            print("t1 start")
            Thread.sleep(forTimeInterval: 1)
            print("t1 end")
            task.finish()
        }
        
        let t2 = AsyncTask(priority: .hight)  { task in
            print("t2 start")
            Thread.sleep(forTimeInterval: 1)
            print("t2 end")
            task.finish()
        }
        
        let t3 = AsyncTask(priority: .custom(520))  { task in
            print("t3 start")
            Thread.sleep(forTimeInterval: 1)
            print("t3 end")
            task.finish()
        }
        
        queue.add(tasks: [t1, t2, t3])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

