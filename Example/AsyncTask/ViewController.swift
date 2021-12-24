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
    
//    let queue1 = AsyncTaskQueue()
//    let queue2 = AsyncTaskQueue()
//    let queue3 = AsyncTaskQueue()
//    let queue4 = AsyncTaskQueue()
//    let queue5 = AsyncTaskQueue()
//
    var queue: AsyncTaskQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        queue = AsyncTaskQueue()

        let tasks = (0..<10).map { idx -> AsyncTask in
            return AsyncTask(priority: .custom(idx)) { task in
                task.completion = {
                    print("\(CFAbsoluteTimeGetCurrent()) t\(idx) end")
                }
                print("\(CFAbsoluteTimeGetCurrent()) t\(idx) start")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    print("\(CFAbsoluteTimeGetCurrent()) t\(idx) finish")
                    task.finish()
                }
            }
        }

        queue?.add(tasks: tasks)
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.queue = nil
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

