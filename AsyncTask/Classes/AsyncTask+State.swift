//
//  AsyncTask+State.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public extension AsyncTask {
    
    /// 任务状态
    enum State {
        
        /// 初始状态
        case idle
        /// 任务就绪
        case ready
        /// 任务正在执行中
        case runing
        /// 任务已取消
        case canceled
        /// 任务已结束
        case finished
    }
}
