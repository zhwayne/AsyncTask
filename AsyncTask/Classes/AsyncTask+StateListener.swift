//
//  AsyncTask+LifeCycle.swift
//  AsyncTask
//
//  Created by iya on 2022/12/16.
//

import Foundation

extension AsyncTask {
    
    public struct StateListener {
        
        let block: ((State) -> Void)
        
        public init(block: @escaping ((State) -> Void)) {
            self.block = block
        }
    }
}
