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
        queue = AsyncQueue()

        queue?.add(tasks: makeTasks(count: 1000))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.queue?.add(tasks: self.makeTasks(count: 1000))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.queue?.add(tasks: self.makeTasks(count: 1000))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.queue = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func makeTasks(count: Int) -> [AsyncTask] {
        (0..<count).map { idx -> AsyncTask in
            return AsyncTask(priority: .custom(idx)) { task in
                //                let _ = (0..<200).map {
                //                    return (0..<$0).map { $0 * 2 }
                //                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    task.finish()
                }
            }
        }
    }
}

