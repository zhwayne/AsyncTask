//
//  AsyncTaskQueue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public final class AsyncTaskQueue {
    
    private var taskQueue = Queue<AsyncTask>()
    private var executeQueue = DispatchQueue(label: "AsyncTaskExecuteQueue")
    private let lockValue = 0
    
    public var isSuspended = false {
        didSet { if !isSuspended { willExecute() } }
    }
    
    public init() {}
    
    public func add(tasks: [AsyncTask]) {
        objc_sync_enter(lockValue)
        defer {
            objc_sync_exit(lockValue)
        }
        tasks.forEach {
            guard $0.state == .idle else { return }
            enqueue(task: $0)
            $0.state = .ready
        }
        sortQueueTasks()
        willExecute()
    }
    
    public func add(task: AsyncTask) {
        objc_sync_enter(lockValue)
        defer {
            objc_sync_exit(lockValue)
        }
        guard task.state == .idle else { return }
        enqueue(task: task)
        sortQueueTasks()
        task.state = .ready
        willExecute()
    }
    
    private func willExecute() {
        guard !isSuspended else { return }
        executeQueue.async { [weak self] in
            self?.execute()
        }
    }
    
    private func execute() {
        guard !isSuspended else { return }
        guard let task = taskQueue.peek() else { return }
        
        switch task.state {
        case .runing: return
        case .idle, .canceled, .finished:
            defer { execute() }
            dequeue()
            return
        case .ready:
            task.state = .runing
            task.stateDidChange = { [weak self, weak task] state in
                self?.executeQueue.async {
                    if state == .canceled || state == .finished {
                        defer {
                            self?.willExecute()
                        }
                        self?.dequeue()
                        task?.completion?()
                    }
                }
            }
            task.execute()
        }
    }
    
    public func cancelAll() {
        objc_sync_enter(lockValue)
        defer {
            objc_sync_exit(lockValue)
        }
        taskQueue.forEach { $0.cancel() }
    }
}

extension AsyncTaskQueue {
    
    private func enqueue(task: AsyncTask) {
        taskQueue.enqueue(task)
    }
    
    private func sortQueueTasks() {
        taskQueue.sort { $0.priority > $1.priority }
    }
    
    private func dequeue() {
        taskQueue.dequeue()
    }
}
