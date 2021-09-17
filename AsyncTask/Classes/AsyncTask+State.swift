//
//  AsyncTask+State.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public extension AsyncTask {
    
    enum State {
        case idle
        case ready
        case runing
        case canceled
        case finished
    }
}
