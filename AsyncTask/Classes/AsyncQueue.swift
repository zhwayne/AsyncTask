//
//  AsyncQueue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public final class AsyncQueue {
    
    /// Enable log output.
    public static var isLogEnabled = false
    
    /// An identifier of the task queue.
    public let identifier = UUID().uuidString
    
    /// Mark the state of the task queue.
    public private(set) var isSuspended = false
    
    /// All pending tasks are queued here for execution.
    private var pendingQueue = Queue<AsyncTask>()
    
    /// The queue in which the task is being executed. Just one task.
    private var executingQueue = Queue<AsyncTask>()
    
    /// A resident thread used to perform tasks.
    private var thread: Thread!
    
    /// Runloop exit if set to false.
    private var isRunLoopWorking = true
    
    private var runloop: CFRunLoop!
    
    private let lock = Lock()
    
    deinit {
        // Cancels all outstanding tasks.
        pendingQueue.forEach {
            $0.cancel()
            logger("\($0) canceled.")
        }
        logger("All pending \(pendingQueue.length) task(s) has been cancelled.")
        
        // Exit the runloop.
        isRunLoopWorking = false
        if let runloop = runloop {
            CFRunLoopStop(runloop)
        }
    }

    public init(qos: QualityOfService = .default) {
        thread = Thread(block: { [weak self] in
            logger("Runloop start.")
            let runloop = CFRunLoopGetCurrent()
            var sourceCtx = CFRunLoopSourceContext()
            let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceCtx)
            CFRunLoopAddSource(runloop, source, .commonModes)
            self?.runloop = runloop
            defer {
                CFRunLoopRemoveSource(runloop, source, .commonModes)
                logger("Runloop destroyed.")
            }
            
            while case let working = self?.isRunLoopWorking, working == true {
                CFRunLoopRunInMode(.defaultMode, 0.016, true)
                logger("Async queue will going to execute next task.")
                do {
                    try self?.executeNext()
                    logger("Runloop run...")
                    CFRunLoopRun()
                    logger("Runloop stop.")
                } catch ExexutingError.suspend {
                    logger("Async queue is suspended.")
                    logger("Runloop run...")
                    CFRunLoopRun()
                    logger("Runloop is stoped.")
                } catch ExexutingError.ignore(let task) {
                    logger("\(task) is still executing. this operation will be ignored.")
                    logger("Runloop run...")
                    CFRunLoopRun()
                    logger("Runloop is stoped.")
                } catch ExexutingError.noTask {
                    logger("There are no tasks waiting to be executed.")
                    logger("Runloop run...")
                    CFRunLoopRun()
                    logger("Runloop is stoped.")
                } catch ExexutingError.taskHasCancelled(let task) {
                    logger("\(task) has been canceled.")
                } catch {
                    logger("Catch unknown error: \(error)")
                }
            }
        })
        thread.name = "com.zhwayne.AsyncTaskThread"
        thread.qualityOfService = qos
        thread.start()
    }
    
    /// Add a task to be executed. If there is an unfinished task in the execution queue or an unstarted
    /// task before it, this task will wait until the execution of the previous task is completed.
    /// - Parameter task: A task to be performed.
    public func addTask(_ task: AsyncTask) {
        lock.withLockVoid { [unowned self] in
            // Only idle tasks can be added.
            guard task.state == .idle else { return }
            
            // Change task state to ready.
            task.ready()
            defer { logger("\(task) added.") }

            // Put the task in a pending queue.
            pendingQueue.enqueue(task)

            // If the runloop is suspended, execution resumes after the task is added.
            if let runloop = runloop, !isSuspended, executingQueue.isEmpty {
                CFRunLoopStop(runloop)
            }
        }
    }
    
    private func fetchNextTask() throws -> AsyncTask {
        // Checking is runloop suspended.
        guard !isSuspended else { throw ExexutingError.suspend }

        
        // Check whether there is a task being executed. If there is, this execution will be ignored
        // until the task is executed.
        if let executingTask = executingQueue.peek() {
            if executingTask.state == .runing { throw ExexutingError.ignore(executingTask) }
            // Remove the task from pending qeueu.
            executingQueue.dequeue()
        }
        
        // Reorder tasks waiting to be executed by priority.
        pendingQueue.sort { $0.priority > $1.priority }
        
        // Checking has no tasks.
        guard let task = pendingQueue.dequeue() else { throw ExexutingError.noTask }
        
        // Check if the task has been canceled before execution
        guard task.state == .ready else { throw ExexutingError.taskHasCancelled(task) }
        
        return task
    }
    
    private func executeNext() throws {
        // Obtain the task to be performed.
        let task = try fetchNextTask()
        logger("\(task) is about to be executed.")
        
        // Put the task in a executing queue.
        executingQueue.enqueue(task)
        
        task.stateDidChange = { [weak self] task in
            logger("\(task) has changed to \(task.state).")
            if task.state == .finished || task.state == .canceled {
                logger("Execute \(task) completion block.")
                task.completion?(task.state)
                if let runloop = self?.runloop {
                    CFRunLoopStop(runloop)
                }
            }
        }
        task.execute()
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
    
    /// Suspends the execution queue, and the waiting tasks will be consistently blocked until the
    /// queue is resumed. Tasks in progress are not affected.
    public func suspend() {
        lock.withLockVoid { [unowned self] in
            isSuspended = true
        }
    }
    
    /// Resume current suspended execution queue.
    public func resume() {
        lock.withLockVoid { [unowned self] in
            if isSuspended {
                isSuspended = false
                CFRunLoopStop(runloop)
            }
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
        case taskHasCancelled(AsyncTask)
        case noTask
        case suspend
        case ignore(AsyncTask)
    }
}


private func logger(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if AsyncQueue.isLogEnabled {
        let time = String(format: "%.3f", CFAbsoluteTimeGetCurrent())
        print("\(time) [AsyncTask]", terminator: " ")
        print(items, separator: separator, terminator: terminator)
    }
}
