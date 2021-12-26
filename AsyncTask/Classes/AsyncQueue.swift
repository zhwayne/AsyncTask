//
//  AsyncQueue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public final class AsyncQueue {
    
    private var pendingQueue = Queue<AsyncTask>()
    private var executingQueue = Queue<AsyncTask>() // only one task
    
    private var thread: Thread!
    private var isWorking = true
    private var runloop: CFRunLoop!
    
    private let lock = Lock()
    
    public private(set) var isSuspended = false
    
    deinit {
        pendingQueue.forEach { $0.cancel() }
        isWorking = false
        CFRunLoopStop(runloop)
    }
    
    public init() {
        thread = Thread(block: { [weak self] in
            print("Runloop start.")
            let runloop = CFRunLoopGetCurrent()
            self?.runloop = runloop
            var pendingTaskCount = 0
            var sourceCtx = CFRunLoopSourceContext()
            let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceCtx)
            
            CFRunLoopAddSource(runloop, source, .commonModes)
            defer {
                CFRunLoopRemoveSource(runloop, source, .commonModes)
                print("Runloop destroyed, and all pending \(pendingTaskCount) task(s) has been canceled.")
            }
            
            while case let working = self?.isWorking, working == true {
                CFRunLoopRunInMode(.defaultMode, 0.01, true)
                print("Async queue will going to execute next task.")
                if let ret = self?.executeNext(), ret == true {
                    print("Runloop is about to be paused.")
                    CFRunLoopRun()
                    print("Runloop is resumed.")
                }
                if let length = self?.pendingQueue.length {
                    pendingTaskCount = length
                }
            }
        })
        thread.name = "AsyncTaskThread"
        thread.start()
    }
    
    /// Add tasks.
    /// - Parameter tasks: A set of tasks to be performed
    public func add(tasks: [AsyncTask]) {
        lock.withLockVoid { [unowned self] in
            tasks.forEach { task in
                guard task.state == .idle else { return }
                task.ready()
                print("Add task \(task).")
                pendingQueue.enqueue(task)
            }
            if runloop != nil, !isSuspended {
                CFRunLoopStop(runloop)
            }
        }
    }
    
    /// Add task
    /// - Parameter task: A task to be performed.
    public func add(task: AsyncTask) {
        lock.withLockVoid { [unowned self] in
            guard task.state == .idle else { return }
            task.ready()
            print("Add task \(task).")
            pendingQueue.enqueue(task)
            if runloop != nil, !isSuspended {
                CFRunLoopStop(runloop)
            }
        }
    }
    
    private func executeNext() -> Bool {
        return lock.withLock { [unowned self] in
            guard !isSuspended else {
                print("Async queue is suspended.")
                return true
            }
            
            if let task = executingQueue.peek() {
                if task.state == .runing || task.state == .canceled {
                    print("\(task) is still executing. this operation will be ignored.")
                    return false
                }
                executingQueue.dequeue()
                print("Execute \(task) completion block.")
                task.completion?()
                return false
            }
            
            pendingQueue.sort { $0 > $1 }
            guard let task = pendingQueue.dequeue() else {
                print("There are no tasks waiting to be executed.")
                return true
            }
            guard task.state == .ready else {
                print("\(task) has been canceled.")
                return false
            }
            
            print("\(task) is about to be executed.")
            
            executingQueue.enqueue(task)
            task.stateDidChange = { task in
                print("The state of \(task) has changed to \(task.state).")
                guard task.state == .finished else {
                    return
                }
                print("\(task) did finished.")
            }
            task.execute()
            print("\(task) is executing.")
            return false
        }
    }
    
    /// Cancel all waiting tasks.
    ///
    /// Please note that canceling a task does not stop the task being executed.
    public func cancelAll() {
        lock.withLockVoid { [unowned self] in
            pendingQueue.forEach {
                $0.cancel()
                print("\($0) canceled.")
            }
        }
    }
    
    public func suspend() {
        lock.withLockVoid { [unowned self] in
            isSuspended = true
        }
    }
    
    public func resume() {
        lock.withLockVoid { [unowned self] in
            isSuspended = false
            CFRunLoopStop(runloop)
        }
    }
}
