//
//  BleOperationQueue.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public final class AsyncTaskQueue {
    
    
    /// Enable log output.
    public static var isLogEnabled = false
    
    /// An identifier of the task queue.
    public let identifier = UUID().uuidString
    
    /// Mark the state of the task queue.
    public private(set) var isSuspended = false
    
    /// All pending tasks are queued here for execution.
    private var pendingQueue = Array<AsyncTask>()
    
    /// The queue in which the task is being executed. Just one task.
    private var executingQueue = Array<AsyncTask>()
    
    /// A resident thread used to perform tasks.
    private var thread: Thread!
    
    /// Runloop exit if set to false.
    private var isRunLoopWorking = true
    
    private var runloop: CFRunLoop!
    
    private let lock = Lock()
    
    deinit {
        // Cancels all outstanding tasks.
        cancelAll()
    }
    
    public init() {
        
    }
    
    /// Add a task to be executed. If there is an unfinished task in the execution queue or an unstarted
    /// task before it, this task will wait until the execution of the previous task is completed.
    /// - Parameter task: A task to be performed.
    public func addTask(_ task: AsyncTask) {
        lock.withLockVoid { [unowned self] in
            // Only idle tasks can be added.
            guard task.state == .idle else { return }
            
            // Check task duplication.
            let allTasks = Array(executingQueue + pendingQueue)
            if allTasks.contains(where: { $0.identifier == task.identifier }) {
                logger("\(task) duplicated. This operation will be ignored.")
                return
            }
            
            task.addListener(AsyncTask.StateListener(block: { state in
                logger("\(task) state changes to \(state).")
            }))
            
            // Change task state to ready.
            task.ready()
            task.delegate = self
            
            // Put the task in a pending queue.
            pendingQueue.append(task)
            
            // Reorder tasks waiting to be executed by priority.
            pendingQueue.sort { $0.priority > $1.priority }
        }
        
        logger("\(task) added.")
        
        if !isSuspended {
            start()
        }
    }
    
    private func fetchNextTask() throws -> AsyncTask {
        // Checking is runloop suspended.
        guard !isSuspended else { throw ExexutingError.suspend }
        
        
        // Check whether there is a task being executed. If there is, this execution will be ignored
        // until the task is executed.
        if let executingTask = executingQueue.first {
            if executingTask.state == .running { throw ExexutingError.ignore(executingTask) }
            // Remove the task from pending qeueu.
            executingQueue.removeFirst()
        }
        
        // Reorder tasks waiting to be executed by priority.
        pendingQueue.sort { $0.priority > $1.priority }
        
        // Checking has no tasks.
        guard !pendingQueue.isEmpty else { throw ExexutingError.noTask }
        
        let task = pendingQueue.removeFirst()
        
        // Check if the task has been canceled before execution
        guard task.state == .ready else { throw ExexutingError.taskHasCancelled(task) }
        
        return task
    }
    
    @discardableResult
    private func executeNext() throws -> AsyncTask {
        // Obtain the task to be performed.
        let task = try fetchNextTask()
        
        // Put the task in a executing queue.
        executingQueue.append(task)
        task.execute()
        return task
    }
    
    private func start() {
        do {
            try executeNext()
        } catch ExexutingError.suspend {
            logger("Queue is suspended.")
        } catch ExexutingError.ignore(let task) {
            logger("\(task) is still executing. this operation will be ignored. Waiting for the task to end.")
        } catch ExexutingError.noTask {
            logger("There are no tasks waiting to be executed. Waiting for new tasks to be added.")
        } catch ExexutingError.taskHasCancelled(let task) {
            logger("\(task) has been canceled.")
        } catch {
            logger("Catch unknown error: \(error)")
        }
    }
    
    /// Cancel all tasks.
    func cancelAll(error: Error? = nil) {
        lock.withLockVoid { [weak self] in
            guard let self else { return }
            pendingQueue.forEach {
                $0.cancel(error: error)
            }
            pendingQueue = []
            executingQueue.forEach {
                $0.cancel(error: error)
            }
            logger("All tasks canceled.")
        }
    }
    
    /// Suspends the execution queue, and the waiting tasks will be consistently blocked until the
    /// queue is resumed. Tasks in progress are not affected.
    func suspend() {
        lock.withLockVoid { [unowned self] in
            isSuspended = true
        }
    }
    
    /// Resume current suspended execution queue.
    func resume() {
        lock.withLockVoid { [unowned self] in
            if isSuspended {
                isSuspended = false
            }
        }
        start()
    }
}

extension AsyncTaskQueue: AsyncTaskDelegate {
    
    func taskDidFinishOrCancell(_ task: AsyncTask) {
        executingQueue = []
        start()
    }
}

extension AsyncTaskQueue: CustomStringConvertible {
    
    public var allTasks: [AsyncTask] {
        return lock.withLock { [unowned self] in
            return Array(executingQueue + pendingQueue)
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

extension AsyncTaskQueue {
    
    private enum ExexutingError: Error {
        case taskHasCancelled(AsyncTask)
        case noTask
        case suspend
        case ignore(AsyncTask)
    }
}


private func logger(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if AsyncTaskQueue.isLogEnabled {
        let time = String(format: "%.3f", CFAbsoluteTimeGetCurrent())
        print("\(time) [AsyncTask]", terminator: " ")
        print(items, separator: separator, terminator: terminator)
    }
}
