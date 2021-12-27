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
    
    public let identifier = UUID().uuidString
    
    public private(set) var isSuspended = false
    
    public static var isLogEnabled = false
    
    deinit {
        pendingQueue.forEach { $0.cancel() }
        isWorking = false
        CFRunLoopStop(runloop)
    }
    
    public init() {
        thread = Thread(block: { [weak self] in
            logger("Runloop start.")
            let runloop = CFRunLoopGetCurrent()
            self?.runloop = runloop
            var pendingTaskCount = 0
            var sourceCtx = CFRunLoopSourceContext()
            let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceCtx)
            
            CFRunLoopAddSource(runloop, source, .commonModes)
            defer {
                CFRunLoopRemoveSource(runloop, source, .commonModes)
                logger("Runloop destroyed, and all pending \(pendingTaskCount) task(s) has been canceled.")
            }
            
            while case let working = self?.isWorking, working == true {
                CFRunLoopRunInMode(.defaultMode, 0.01, true)
                logger("Async queue will going to execute next task.")
                do {
                    try self?.executeNext()
                    if let length = self?.pendingQueue.length {
                        pendingTaskCount = length
                    }
                } catch ExexutingError.suspend {
                    logger("Runloop is about to be paused.")
                    CFRunLoopRun()
                    logger("Runloop is resumed.")
                } catch {}
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
                logger("Add task \(task).")
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
            logger("Add task \(task).")
            pendingQueue.enqueue(task)
            if runloop != nil, !isSuspended {
                CFRunLoopStop(runloop)
            }
        }
    }
    
    private func executeNext() throws {
        return try lock.withLock { [unowned self] in
            guard !isSuspended else {
                logger("Async queue is suspended.")
                throw ExexutingError.suspend
            }
            
            if let task = executingQueue.peek() {
                if task.state == .runing || task.state == .canceled {
                    logger("\(task) is still executing. this operation will be ignored.")
                    throw ExexutingError.ignore
                }
                executingQueue.dequeue()
                logger("Execute \(task) completion block.")
                task.completion?()
                throw ExexutingError.ignore
            }
            
            pendingQueue.sort { $0 > $1 }
            guard let task = pendingQueue.dequeue() else {
                logger("There are no tasks waiting to be executed.")
                throw ExexutingError.suspend
            }
            guard task.state == .ready else {
                logger("\(task) has been canceled.")
                throw ExexutingError.ignore
            }
            
            logger("\(task) is about to be executed.")
            
            executingQueue.enqueue(task)
            task.stateDidChange = { task in
                logger("The state of \(task) has changed to \(task.state).")
                guard task.state == .finished else {
                    return
                }
                logger("\(task) did finished.")
            }
            task.execute()
            logger("\(task) is executing.")
        }
    }
    
    /// Cancel all waiting tasks.
    ///
    /// Please note that canceling a task does not stop the task being executed.
    public func cancelAll() {
        lock.withLockVoid { [unowned self] in
            pendingQueue.forEach {
                $0.cancel()
                logger("\($0) canceled.")
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

extension AsyncQueue: CustomStringConvertible {
    
    public var allTasks: [AsyncTask] {
        return lock.withLock { [unowned self] in
            return executingQueue.rawData + pendingQueue.rawData
        }
    }
    
    public var description: String {
        let tasks = allTasks.map { "\t\t\($0)" }.joined(separator: ",\n")
        return """
        \(type(of: self))<\(identifier)> : {
        \tisSuspended: \(isSuspended),
        \ttasks: [
        \(tasks)
        \t]
        }
        """
    }
}

extension AsyncQueue {
    
    private enum ExexutingError: Error {
        case suspend
        case ignore
    }
}


func logger(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if AsyncQueue.isLogEnabled {
        print(items, separator: separator, terminator: terminator)
    }
}
