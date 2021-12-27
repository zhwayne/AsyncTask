//
//  AlertTask.swift
//  AsyncTask_Example
//
//  Created by iya on 2021/12/27.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncTask

class AlertTask: AsyncTask {
    
    let baseViewController: UIViewController?
    
    required init(baseViewController: UIViewController?, priority: AsyncTask.Priority) {
        self.baseViewController = baseViewController
        super.init(priority: priority)
    }
    
    override func execute() {
        super.execute()
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Task Info", message: "\(self)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                alertController.dismiss(animated: true) {
                    self?.finish()
                }
            }
            alertController.addAction(action)
            self.baseViewController?.showDetailViewController(alertController, sender: nil)
        }
    }
}
