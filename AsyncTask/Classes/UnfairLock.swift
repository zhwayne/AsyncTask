//
//  UnfairLock.swift
//  AsyncTask
//
//  Created by iya on 2021/12/25.
//

import Foundation

final class UnfairLock {
    
    private let unfairLock: os_unfair_lock_t
    
    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    private func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    private func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}

extension UnfairLock {
    
    @inlinable
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
    
    @inlinable
    func withLockVoid(_ body: () throws -> Void) rethrows {
        try self.withLock(body)
    }
}
