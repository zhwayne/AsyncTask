//
//  AsyncTask.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

open class AsyncTask {
    
    private let code: (AsyncTask) -> Void
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    public var completion: (() -> Void)?
    
    var finishHandler: (() -> Void)?
    
    var state: State = .idle {
        didSet { stateDidChange?(state) }
    }
    
    var stateDidChange: ((State) -> Void)?
    
    public let priority: Priority
    
    public init(priority: Priority = .default, _ code: @escaping (AsyncTask) -> Void = { _ in }) {
        self.priority = priority
        self.code = code
    }
    
    open func execute() {
        code(self)
    }
    
    open func finish() {
        guard state != .finished && state != .canceled else { return }
        state = .finished
        finishHandler?()
    }
    
    open func cancel() {
        guard state != .finished && state != .canceled else { return }
        state = .canceled
    }
}

extension AsyncTask: CustomStringConvertible {
    
    public var description: String {
        return "\(type(of: self))(priority: \(priority), state: \(state)"
    }
}
