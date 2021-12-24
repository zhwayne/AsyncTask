//
//  AsyncTask+Priority.swift
//  AsyncTask
//
//  Created by 张尉 on 2021/9/17.
//

import Foundation

public extension AsyncTask {
    
    /// 任务优先级
    enum Priority {
        case low
        case `default`
        case hight
        case custom(Int)
    }
}

extension AsyncTask.Priority {
    
    var value: Int {
        switch self {
        case .low:      return 250
        case .default:  return 500
        case .hight:    return 750
        case .custom(let priority): return priority
        }
    }
    
    public static func + (lhs: Self, rhs: Int) -> Self {
        return .custom(lhs.value + rhs)
    }
    
    public static func - (lhs: Self, rhs: Int) -> Self {
        return .custom(lhs.value - rhs)
    }
    
    public static func * (lhs: Self, rhs: Int) -> Self {
        return .custom(lhs.value * rhs)
    }
}

extension AsyncTask.Priority: Comparable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
    
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.value <= rhs.value
    }
    
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.value >= rhs.value
    }
    
    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.value > rhs.value
    }
}

extension AsyncTask: Comparable {
    public static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.priority == rhs.priority
    }
    
    public static func < (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.priority < rhs.priority
    }
    
    public static func <= (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.priority <= rhs.priority
    }
    
    public static func >= (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.priority >= rhs.priority
    }
    
    public static func > (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.priority > rhs.priority
    }
}
