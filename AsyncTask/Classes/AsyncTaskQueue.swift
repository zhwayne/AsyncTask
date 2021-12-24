//
//  AsyncTaskQueue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public final class AsyncTaskQueue {
    
    private var pendingQueue = Queue<AsyncTask>()
    private var executingQueue = Queue<AsyncTask>() // only one task
    private var thread: Thread!
    private var isWorking = true
    private var runloop: CFRunLoop!
    
    public var isSuspended = false
    
    deinit {
        isWorking = false
    }
    
    public init() {
        thread = Thread(block: { [weak self] in
            guard let runloop = CFRunLoopGetCurrent() else {
                fatalError()
            }
            print("Runloop start.")
            self?.runloop = runloop
            var sourceCtx = CFRunLoopSourceContext()
            let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceCtx)
            CFRunLoopAddSource(runloop, source, .commonModes)
            
            while case let working = self?.isWorking, working == true {
                self?.execute()
                CFRunLoopRunInMode(.defaultMode, 0.01, false)
            }
            CFRunLoopRemoveSource(runloop, source, .commonModes)
            print("Runloop destroyed, and all task has been removed.")
        })
        thread.name = "AsyncTaskThread"
        thread.start()
    }
    
    public func add(tasks: [AsyncTask]) {
        tasks.forEach { add(task: $0) }
    }
    
    public func add(task: AsyncTask) {
        guard task.state == .idle else { return }
        task.state = .ready
        print("Add task \(task)")
        pendingQueue.enqueue(task)
    }
    
    private func execute() {
        guard !isSuspended else { return }
        
        if let task = executingQueue.peek() {
            guard task.state == .canceled || task.state == .finished else {
                return
            }
            executingQueue.dequeue()
            task.completion?()
        }
        
        guard !pendingQueue.isEmpty else { return }
        
        pendingQueue.sort { $0 > $1 }
        guard let task = pendingQueue.dequeue() else { return }
        
        guard task.state == .ready else {
            return
        }
        
        task.state = .runing
        executingQueue.enqueue(task)
        task.execute()
    }
    
    public func cancelAll() {
        pendingQueue.forEach { $0.cancel() }
    }
}
