//
//  AsyncTask+LifeCycle.swift
//  AsyncTask
//
//  Created by iya on 2022/12/16.
//

import Foundation

extension AsyncTask {
    
    public struct LifeCycle {
        
        let didCompletion: (() -> Void)?
        
        public init(didCompletion: (() -> Void)?) {
            self.didCompletion = didCompletion
        }
    }
}
