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
    
    /// The block will be executed after the task is completed.
    public var completion: ((State) -> Void)?
    
    public var isReady: Bool { state == .ready }
    
    public var isExecuting: Bool { state == .runing }
    
    public var isCanceled: Bool { state == .canceled }
    
    public var isFinished: Bool { state == .finished }
    
    var stateDidChange: ((AsyncTask) -> Void)?
    
    private(set) var state: State = .idle {
        didSet { stateDidChange?(self) }
    }
    
    private var isExecuted = false
    
    private let code: ((AsyncTask) -> Void)?
    
    private let semaphore = DispatchSemaphore(value: 0)

    public init(priority: Priority, code: ((AsyncTask) -> Void)? = nil, completion: ((State) -> Void)? = nil) {
        self.priority = priority
        self.code = code
        self.completion = completion
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
