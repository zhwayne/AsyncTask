//
//  AsyncTask.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

protocol AsyncTaskDelegate: AnyObject {
    
    func taskDidFinishOrCancell(_ task: AsyncTask)
}


open class AsyncTask {
    
    /// Priority of task.
    ///
    /// Tasks with high priority will be executed first. Once the task starts to execute, modifying the priority is invalid.
    let priority: Priority
    
    let identifier: String
    
    var listeners = [StateListener]()
    
    var isReady: Bool { state == .ready }
    
    var isExecuting: Bool { state == .running }
    
    var isCanceled: Bool { state == .canceled }
    
    var isFinished: Bool { state == .finished }
    
    private(set) var error: Error?
    
    weak var delegate: AsyncTaskDelegate?
    
    private(set) var state: State = .idle
    
    private var isExecuted = false
    
    private let code: ((AsyncTask) -> Void)?
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    public init(
        priority: Priority = .default,
        identifier: String = UUID().uuidString,
        code: ((AsyncTask) -> Void)? = nil
    ) {
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
        listeners.forEach { $0.block(self.state) }
    }
    
    /// Do not call this method manually, it will be executed automatically when appropriate.
    open func execute() {
        guard state == .ready else { return }
        isExecuted = true
        state = .running
        code?(self)
        listeners.forEach { $0.block(self.state) }
    }
    
    /// Mark the task as completed.
    ///
    /// Only tasks in execution can be marked. After the task is over, it will be removed from the queue.
    open func finish(error: Error? = nil) {
        guard state == .running else { return }
        self.error = error
        state = .finished
        delegate?.taskDidFinishOrCancell(self)
        listeners.forEach { $0.block(self.state) }
    }
    
    /// Canel this task.
    ///
    /// If the waiting task is cancelled, it will not be executed. Please note that canceling a task does not
    /// stop the task being executed.
    open func cancel(error: Error? = nil) {
        guard state != .finished && state != .canceled else { return }
        self.error = error
        state = .canceled
        delegate?.taskDidFinishOrCancell(self)
        listeners.forEach { $0.block(self.state) }
    }
}

extension AsyncTask: CustomStringConvertible {
    
    public var description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()), priority = \(priority.rawValue), state = \(state)>"
    }
}
