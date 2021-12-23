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

        let tasks = (0..<10).map { idx -> AsyncTask in
            return AsyncTask(priority: .custom(idx)) { task in
                print("t\(idx) start")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("t\(idx) end")
                    task.finish()
                }
            }
        }

        queue.add(tasks: tasks)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

