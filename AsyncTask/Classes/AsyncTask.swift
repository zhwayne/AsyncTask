//
//  AsyncTask.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

open class AsyncTask {
    
    /// Priority of task.
    ///
    /// Tasks with high priority will be executed first. Once the task starts to execute, modifying the priority is invalid.
    public let priority: Priority
    
    public let identifier: String
    
    var listeners = [StateListener]()
    
    public var isReady: Bool { state == .ready }
    
    public var isExecuting: Bool { state == .runing }
    
    public var isCanceled: Bool { state == .canceled }
    
    public var isFinished: Bool { state == .finished }
        
    private(set) var state: State = .idle {
        didSet {
            listeners.forEach { $0.block(self.state) }
        }
    }
    
    private var isExecuted = false
    
    private let code: ((AsyncTask) -> Void)?
    
    private let semaphore = DispatchSemaphore(value: 0)

    public init(
        priority: Priority = .default,
        identifier: String = UUID().uuidString,
        code: ((AsyncTask) -> Void)? = nil) {
        self.priority = priority
        self.identifier = identifier
        self.code = code
    }
    
    public func addListener(_ listener: StateListener) {
        listeners.append(listener)
    }
    
    /// Mark task as ready.
    ///
    /// Only idle tasks can be marked.
    func ready() {
        guard state == .idle else { return }
        state = .ready
    }
    
    /// Do not call this method manually, it will be executed automatically when appropriate.
    open func execute() {
        guard state == .ready else { return }
        isExecuted = true
        state = .runing
        code?(self)
    }
    
    /// Mark the task as completed.
    ///
    /// Only tasks in execution can be marked. After the task is over, it will be removed from the queue.
    open func finish() {
        guard state == .runing else { return }
        state = .finished
    }
    
    /// Canel this task.
    ///
    /// If the waiting task is cancelled, it will not be executed. Please note that canceling a task does not
    /// stop the task being executed.
    open func cancel() {
        guard state != .finished && state != .canceled else { return }
        state = .canceled
    }
}

extension AsyncTask: CustomStringConvertible {
    
    public var description: String {
        return "\(type(of: self))(priority: \(priority), state: \(state))"
    }
}
